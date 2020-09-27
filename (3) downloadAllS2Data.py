import subprocess
import urllib

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
import os.path
from os import path

def get_utm_epsg(lon, lat):
	#coords = feature.geometry().coordinates()
	lon = ee.Number(lon)
	lat = ee.Number(lat)
	epsg = ee.Number(32700).subtract(lat.add(45).divide(90).round().multiply(100)).add(lon.add(183).divide(6).round()).uint16()
	#print(epsg.getInfo())
	return ee.String("EPSG:").cat(ee.String(str(epsg.getInfo())))



roiFile=r".\files\Area_150_2.geojson"

with open(roiFile) as f:
    data = json.load(f)

#print(data)

roi =  data['features'][0]
#print(roi)

cor = roi['geometry']['coordinates']
#print(cor)
aoi = ee.Geometry.MultiPolygon(cor, None, False)


#aoi = aoi.buffer(100).bounds().simplify(ee.ErrorMargin(1, "meters"))
#Map.centerObject(aoi,10)
#Map.addLayer(aoi, {'color': 'FF0000'})

epsg = get_utm_epsg(cor[0][0][0][0], cor[0][0][0][1])

start_date = ee.Date.fromYMD(2018, 1, 1)

end_date = ee.Date.fromYMD(2020, 1, 1)

s2_bands_20 = ['B5', 'B6', 'B7', 'B8A', 'B11', 'B12']
s2_bands_10 = ['B2', 'B3', 'B4', 'B8']

def clipImg(x):
    return x.clip(aoi)
s2_all = ee.ImageCollection('COPERNICUS/S2').filterDate(start_date, end_date).filterBounds(aoi).map(clipImg)

print("the available s2 data for this roi and time: ", s2_all.size().getInfo())
#print(s2_all.get('id').getInfo())
#Map.addLayer(s2_all.median().clip(aoi), {'bands': ['B4', 'B3', 'B2'], 'min': 0, 'max': 4000})


s2_all_ = s2_all.toList(s2_all.size().getInfo())
for i in range(s2_all.size().getInfo()):
    print(ee.Image(s2_all_.get(i)).get('PRODUCT_ID').getInfo())

    saveFolder_ = os.path.join('D:\samples', ee.Image(s2_all_.get(i)).get('PRODUCT_ID').getInfo())

    if not os.path.exists(saveFolder_):
        os.mkdir(saveFolder_)
    else:
        continue
    #if path.exists(filename):
    #    continue

    s2_mosaic = ee.Image(s2_all_.get(i)).clip(aoi)

    filename = os.path.join(saveFolder_, '10GSD.tif')
    geemap.ee_export_image(s2_mosaic.select(s2_bands_10), filename=filename, scale=10, region=aoi, crs=ee.Projection(epsg),
                           file_per_band=False)
    os.remove(filename[:-4] + ".zip")

    filename = os.path.join(saveFolder_, '20GSD.tif')
    geemap.ee_export_image(s2_mosaic.select(s2_bands_20), filename=filename, scale=20, region=aoi, crs=ee.Projection(epsg),
                           file_per_band=False)
    os.remove(filename[:-4] + ".zip")

    # url = s2_mosaic.getDownloadURL({
        # 'name':citySeason,# +'B'+str(i),
        #'name': band,
    #     'scale': 10,
    #     'region': aoi,
    #     'crs': ee.Projection(epsg)
    # })
    # print(url)# //Print url in console
    # testfile = urllib.URLopener()
    # testfile.retrieve(url, cityDir + "/"+ citySeason +band  +".zip")
    # urllib.request.urlretrieve(url, filename)