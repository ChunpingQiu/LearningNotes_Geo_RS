import subprocess

try:
        import geemap
except ImportError:
        print('geemap package not installed. Installing ...')
        subprocess.check_call(["python", '-m', 'pip', 'install', 'geemap'])

# Authenticates and initializes Earth Engine
import ee

try:
        ee.Initialize()
except Exception as e:
        ee.Authenticate()
        ee.Initialize()

import json
import os
from geeCode_qgis import exportCloudFreeSen2

roiFile = r".\files\Multi_Class_Land_Cover_Change_AOIs.geojson"
s2_bands = ['B2', 'B3', 'B4', 'B5', 'B6', 'B7', 'B8', 'B8A', 'B11', 'B12']
#['Blue', 'Green', 'Red', 'Red Edge 1', 'Red Edge 2', 'Red Edge 3', 'NIR', 'Red Edge 4', 'SWIR1', 'SWIR2', 'QA60']

saveFolder= r".\files\s2_cd"

#########################################################
def get_utm_epsg(lon, lat):
	#coords = feature.geometry().coordinates()
	lon = ee.Number(lon)
	lat = ee.Number(lat)
	epsg = ee.Number(32700).subtract(lat.add(45).divide(90).round().multiply(100)).add(lon.add(183).divide(6).round()).uint16()
	#print(epsg.getInfo())
	return ee.String("EPSG:").cat(ee.String(str(epsg.getInfo())))
#########################################################
with open(roiFile) as f:
        data = json.load(f)

for feature in data['features']:

        print(feature['properties']['title'])

        if feature['properties']['title'] == "4666_2369_13" or feature['properties']['title'] == "8079_4130_13" :
                continue

        saveFolder_ = saveFolder + "/" + feature['properties']['title']
        if not os.path.exists(saveFolder_):
                os.mkdir(saveFolder_)
        else:
                continue

        cor = feature['geometry']['coordinates']

        aoi = ee.Geometry.Polygon([cor[0][0][0:2], cor[0][1][0:2], cor[0][2][0:2], cor[0][3][0:2], cor[0][4][0:2]],
                                  None, False)
        #buffer aoi
        aoi = aoi.buffer(100).bounds().simplify(ee.ErrorMargin(1, "meters"))

        epsg = get_utm_epsg(cor[0][0][0], cor[0][0][1])

        for year in [2018,2019]:

                for m in range(1, 12):
                        start_date = ee.Date.fromYMD(year, m, 1)
                        end_date = ee.Date.fromYMD(year, m + 1, 1)

                        s2_all = ee.ImageCollection('COPERNICUS/S2') \
                                .filterDate(start_date, end_date).filterBounds(aoi)

                        print("the available s2 data for this roi and time: ", s2_all.size().getInfo())

                        s2_masked = exportCloudFreeSen2(aoi, start_date, end_date)
                        s2_masked = s2_masked.select(s2_bands)

                        if m<10:
                                filename = os.path.join(saveFolder_,
                                                        feature['properties']['title'] + '_' + str(year) + '_0' + str(
                                                                m) + '.tif')
                        else:
                                filename = os.path.join(saveFolder_,
                                                feature['properties']['title'] + '_' + str(year) + '_' + str(
                                                        m) + '.tif')

                        geemap.ee_export_image(s2_masked, filename=filename, scale=10, region=aoi, crs=ee.Projection(epsg),
                                               file_per_band=False)

                        os.remove(filename[:-4] + ".zip")


                start_date = ee.Date.fromYMD(year, 12, 1)
                end_date = ee.Date.fromYMD(year + 1, 1, 1)

                #s2 = ee.ImageCollection('COPERNICUS/S2') \
                #        .filterDate(start_date, end_date).select(s2_bands) \
                #        .filterBounds(aoi).median().clip(aoi)

                s2_masked = exportCloudFreeSen2(aoi, start_date, end_date)
                s2_masked = s2_masked.select(s2_bands)

                filename = os.path.join(saveFolder_,
                                        feature['properties']['title'] + '_' + str(year) + '_' + str(m+1) + '.tif')

                geemap.ee_export_image(s2_masked, filename=filename, scale=10, region=aoi, crs=ee.Projection(epsg),
                                       file_per_band=False)

                os.remove(filename[:-4] + ".zip")
#8079_4130_13 4666_2369_13