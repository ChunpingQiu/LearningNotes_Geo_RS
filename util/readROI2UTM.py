#!/usr/bin/env python
# -*- coding: utf-8 -*-
# File              : ../util/readROI2UTM.py
# Author            : Jingliang Hu
# Date              : 09.07.2018 10:05:44
# Last Modified Date: 09.07.2018 10:05:44
# Last Modified By  : Yuanyuan Wang <y.wang@tum.de>

# Last modified: Chunping Qiu
# adapted for SEN2
"read a kml file; use a coordinate of it; to calculate utm projection file"

from osgeo import ogr,osr,gdal
import numpy as np
# import geopandas as gpd
import sys,os


def roiLatlon2UTM(WGSPoint):
    # This function transfers geographical coordinate (lon-lat) into WGS 84 / UTM zone coordinate using GDAL
    # Input:
    #       -- WGSPoint       - A N by M array of lon-lat coordinate; N is number of points, 1st col is longitude, 2nd col is latitude
    #
    # Output:
    #       -- UTMPoints      - A N by M array of WGS 84 /UTM zone coordinate; N is number of points, 1st col is X, 2nd col is Y
    #

    WGSPoint = np.array(WGSPoint)

    if len(WGSPoint.shape)==1:
        WGSPoint = np.stack((WGSPoint,WGSPoint),axis=0)
        nb,dim = np.shape(WGSPoint)
    elif len(WGSPoint.shape)==2:
        # number of WGSPoint
        nb,dim = np.shape(WGSPoint)

    elif len(WGSPoint.shape)==3:
        print('ERROR: DIMENSION OF POINTS SHOULD NO MORE THAN TWO')

    # geographic coordinate (lat-lon) WGS84
    inputEPSG = 4326
    # WGS 84 / UTM zone
    if WGSPoint[0][1]<0:
        outputEPSG = 32700
    else:
        outputEPSG = 32600

    outputEPSG = int(outputEPSG + np.floor((WGSPoint[0][0]+180)/6) + 1)

    # create coordinate transformation
    inSpatialRef = osr.SpatialReference()
    inSpatialRef.ImportFromEPSG(inputEPSG)

    outSpatialRef = osr.SpatialReference()
    outSpatialRef.ImportFromEPSG(outputEPSG)

    utmProjInfo = outSpatialRef.ExportToWkt()

    coordTransform = osr.CoordinateTransformation(inSpatialRef, outSpatialRef)

    # transform point
    UTMPoints = np.zeros(WGSPoint.shape)
    for i in range(0,np.size(WGSPoint,axis=0)):
        p = ogr.Geometry(ogr.wkbPoint)
        p.AddPoint(WGSPoint[i][0], WGSPoint[i][1])
        p.Transform(coordTransform)
        UTMPoints[i][0] = p.GetX()
        UTMPoints[i][1] = p.GetY()


    return UTMPoints, utmProjInfo

shp_path = sys.argv[1]

file = ogr.Open(shp_path)
shape = file.GetLayer(0)
#third feature of the shapefile
feature = shape.GetFeature(4)
pyl = feature.ExportToJson()
# print(pyl)
pyl = pyl.replace("null", "0")
# print(pyl)

#no idea why, but eval is necessary
pyl = eval(pyl)
cor=pyl["geometry"]['coordinates']
# print(cor)

# print(cor[0][0][0:2])
# from shapely.geometry import shape
# shp_geom = shape(pyl["geometry"])
# print(shp_geom)

utmPoints, utmProjInfo = roiLatlon2UTM(cor[0][0][0:2])

"the print results can be received in the .sh file"
print(utmProjInfo)
