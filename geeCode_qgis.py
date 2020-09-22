# @Date:   2020-09-19T21:19:21+02:00
# @Last modified time: 2020-09-20T09:46:03+02:00



import colour
import ee
import geocoder
import ipyleaflet
import math
import os
import time
import ipywidgets as widgets
from bqplot import pyplot as plt
from ipyfilechooser import FileChooser
from ipyleaflet import *
from ipytree import Tree, Node
from IPython.display import display


# ALGORITHM SETTINGS
cloudThresh = 0.2;#Ranges from 0-1.Lower value will mask more pixels out. Generally 0.1-0.3 works well with 0.2 being used most commonly

irSumThresh = 0.3;#Sum of IR bands to include as shadows within TDOM and the shadow shift method (lower number masks out less)
ndviThresh = -0.1
dilatePixels = 2; #Pixels to dilate around clouds
contractPixels = 1;#Pixels to reduce cloud mask and dark shadows by to reduce inclusion of single-pixel comission errors
erodePixels = 1.5
dilationPixels = 3
cloudFreeKeepThresh = 5
cloudMosaicThresh = 50

# calcCloudStats: Calculates a mask for clouds in the image.
#        input: im - Image from image collection with a valid mask layer
#        output: original image with added stats.
#                - CLOUDY_PERCENTAGE: The percentage of the image area affected by clouds
#                - ROI_COVERAGE_PERCENT: The percentage of the ROI region this particular image covers
#                - CLOUDY_PERCENTAGE_ROI: The percentage of the original ROI which is affected by the clouds in this image
#                - cloudScore: A per pixel score of cloudiness
def calcCloudStats(img):
    imgPoly = ee.Algorithms.GeometryConstructors.Polygon(
              ee.Geometry( img.get('system:footprint') ).coordinates()
              )

    roi = ee.Geometry(img.get('ROI'))

    intersection = roi.intersection(imgPoly, ee.ErrorMargin(0.5))
    cloudMask = img.select(['cloudScore']).gt(cloudThresh).clip(roi).rename('cloudMask')

    cloudAreaImg = cloudMask.multiply(ee.Image.pixelArea())

    stats = cloudAreaImg.reduceRegion(reducer= ee.Reducer.sum(),
      geometry=roi, scale =10, maxPixels = 1e12)

    cloudPercent = ee.Number(stats.get('cloudMask')).divide(imgPoly.area(0.001)).multiply(100)
    coveragePercent = ee.Number(intersection.area()).divide(roi.area(0.001)).multiply(100)
    cloudPercentROI = ee.Number(stats.get('cloudMask')).divide(roi.area(0.001)).multiply(100)

    img = img.set('CLOUDY_PERCENTAGE', cloudPercent)
    img = img.set('ROI_COVERAGE_PERCENT', coveragePercent)
    img = img.set('CLOUDY_PERCENTAGE_ROI', cloudPercentROI)

    return img


def rescale(img, exp, thresholds):
    return img.expression(exp, {'img': img}) \
              .subtract(thresholds[0]) \
              .divide(thresholds[1] - thresholds[0])


def computeQualityScore(img):
    score = img.select(['cloudScore']).max(img.select(['shadowScore']))

    score = score.reproject('EPSG:4326', None, 20).reduceNeighborhood(
        reducer =  ee.Reducer.mean(),
        kernel = ee.Kernel.square(5))

    score = score.multiply(-1)

    return img.addBands(score.rename('cloudShadowScore'))


#**
 # Implementation of Basic cloud shadow shift
 #
 # Author: Gennadii Donchyts
 # License: Apache 2.0
 #
def projectShadows(image):
    meanAzimuth = image.get('MEAN_SOLAR_AZIMUTH_ANGLE')
    meanZenith = image.get('MEAN_SOLAR_ZENITH_ANGLE')

    cloudMask = image.select(['cloudScore']).gt(cloudThresh)

  #Find dark pixels
    darkPixelsImg = image.select(['B8','B11','B12']) \
                    .divide(10000) \
                    .reduce(ee.Reducer.sum())

    ndvi = image.normalizedDifference(['B8','B4'])
    waterMask = ndvi.lt(ndviThresh)

    darkPixels = darkPixelsImg.lt(irSumThresh)

    # Get the mask of pixels which might be shadows excluding water
    darkPixelMask = darkPixels.And(waterMask.Not())
    darkPixelMask = darkPixelMask.And(cloudMask.Not())

    #Find where cloud shadows should be based on solar geometry
    #Convert to radians
    azR = ee.Number(meanAzimuth).add(180).multiply(math.pi).divide(180.0)
    zenR = ee.Number(meanZenith).multiply(math.pi).divide(180.0)

    #Find the shadows

    def func_pjg(cloudHeight):
        cloudHeight = ee.Number(cloudHeight)

        shadowCastedDistance = zenR.tan().multiply(cloudHeight);#Distance shadow is cast
        x = azR.sin().multiply(shadowCastedDistance).multiply(-1)#.divide(nominalScale);#X distance of shadow
        y = azR.cos().multiply(shadowCastedDistance).multiply(-1);#Y distance of shadow
        return image.select(['cloudScore']).displace(ee.Image.constant(x).addBands(ee.Image.constant(y)))

    cloudHeights = ee.List.sequence(200,10000,250);#Height of clouds to use to project cloud shadows
    shadows = cloudHeights.map(func_pjg)


    shadowMasks = ee.ImageCollection.fromImages(shadows)
    shadowMask = shadowMasks.mean()

    # #Create shadow mask
    shadowMask = dilatedErossion(shadowMask.multiply(darkPixelMask))

    shadowScore = shadowMask.reduceNeighborhood(reducer=ee.Reducer.max(), kernel=ee.Kernel.square(1))

    image = image.addBands(shadowScore.rename(['shadowScore']))

    return image

def dilatedErossion(score):
    return score.reproject('EPSG:4326', None, 20) \
            .focal_min(radius = erodePixels, iterations = 3) \
            .focal_max(radius = dilationPixels, iterations = 3) \
            .reproject('EPSG:4326', None, 20)


# mergeCollection: Generates a single non-cloudy Sentinel 2 image from a processed ImageCollection
#        input: imgC - Image collection including "cloudScore" band for each image
#              threshBest - A threshold percentage to select the best image. This image is used directly as "cloudFree" if one exists.
#              threshMed - A max threshold to select all image which are to be merged to create the cloud free image
#        output: A single cloud free mosaic for the region of interest
def mergeCollection(imgC):
    # Select the best images, which are below the cloud free threshold, sort them in reverse order (worst on top) for mosaicing
    best = imgC.filterMetadata('CLOUDY_PERCENTAGE', 'less_than', cloudFreeKeepThresh).sort('CLOUDY_PERCENTAGE',False)
    filtered = imgC.qualityMosaic('cloudShadowScore')

    # Add the quality mosaic to fill in any missing areas of the ROI which aren't covered by good images
    newC = ee.ImageCollection.fromImages( [filtered, best.mosaic()] )

    return ee.Image(newC.mosaic())



# exportCloudFreeSen2: Exports a cloud free image for a specific date range to GCS in 3 GeoTIFFs (1 per band resolution)
#        input: season - A text name for the season. Used for naming the exported files.
#               dates - Array of the date range for the mosaicing [start, end]
#               roi - Region of interest to clip, for exporting
#               roiID - A unique identifier for the ROI, used for naming files
#               debug - A debugging level for displaying data on the map. (0-off, 2-everything)
#        output: None
def exportCloudFreeSen2(roi, start_date, end_date):

    def clipImg(x):
        return x.clip(roi)

    def setRoi(x):
        return x.set('ROI', roi)

    def computeS2CloudScore(img):
        toa = img.select(['B1','B2','B3','B4','B5','B6','B7','B8','B8A', 'B9','B10', 'B11','B12']) \
                  .divide(10000)

        toa = toa.addBands(img.select(['QA60']))

        # Compute several indicators of cloudyness and take the minimum of them.
        score = ee.Image(1)

        # Clouds are reasonably bright in the blue and cirrus bands.
        score = score.min(rescale(toa, 'img.B2', [0.1, 0.5]))
        score = score.min(rescale(toa, 'img.B1', [0.1, 0.3]))
        score = score.min(rescale(toa, 'img.B1 + img.B10', [0.15, 0.2]))

        # Clouds are reasonably bright in all visible bands.
        score = score.min(rescale(toa, 'img.B4 + img.B3 + img.B2', [0.2, 0.8]))

        #Clouds are moist
        ndmi = img.normalizedDifference(['B8','B11'])
        score=score.min(rescale(ndmi, 'img', [-0.1, 0.1]))

        # However, clouds are not snow.
        ndsi = img.normalizedDifference(['B3', 'B11'])
        score=score.min(rescale(ndsi, 'img', [0.8, 0.6]))

        # Clip the lower end of the score
        score = score.max(ee.Image(0.001))

        #print(score.getInfo())

        # Perform opening on the cloud scores
        score = dilatedErossion(score)

        # Remove small regions and clip the upper bound
        dilated = score.min(ee.Image(1.0))

        score = score.reduceNeighborhood(reducer=ee.Reducer.max(), kernel=ee.Kernel.square(1))

        return img.addBands(score.rename('cloudScore'))

        #Filter images of this period
    imgC = ee.ImageCollection("COPERNICUS/S2") \
              .filterDate(start_date, end_date) \
              .filterBounds(roi).map(clipImg).map(setRoi).map(computeS2CloudScore)

    #ss = calcCloudStats(imgC.median())

    imgC = ee.ImageCollection(imgC).map(calcCloudStats) \
              .map(projectShadows) \
              .map(computeQualityScore) \
              .sort('CLOUDY_PERCENTAGE')

    cloudFree = mergeCollection(imgC)

    return cloudFree
