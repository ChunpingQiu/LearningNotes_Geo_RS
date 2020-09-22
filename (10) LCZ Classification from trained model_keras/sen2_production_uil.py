"""
Created on Fri June 29 15:09:53 2018

@author: hu jingliang
"""

# Last modified: 22.09.2020 CQ; add color table for the output lab tiffs

from __future__ import print_function
import os
import glob
import numpy as np
from osgeo import gdal
import sys
import glob2
gdal.UseExceptions()

'''
# load all relevent bands of a image file
# input:
        tiffPath: image file
        Bands: list of bands be extracted
        scale: pixel value is divided by scale
# output:
        prj: projection data
        trans: projection data
        matImg: matrix containing the bands of the image
'''
def getData(tiffPath, Bands, scale):

    try:
        src_ds = gdal.Open(tiffPath)
    except RuntimeError as e:
        print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
        print("ERROR:           the given data geotiff can not be open by GDAL")
        print("DIRECTORY:       "+tiffPath)
        print("GDAL EXCEPCTION: "+e)
        print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
        sys.exit(1)

    if src_ds is None:
      print('Unable to open INPUT.tif')
      sys.exit(1)

    prj=src_ds.GetProjection()
    trans=src_ds.GetGeoTransform()

    bandInd=0
    for band in Bands:
      band += 1
      srcband = src_ds.GetRasterBand(band)

      if srcband is None:
          print('srcband is None'+str(band)+imgFile)
          continue
      arr = srcband.ReadAsArray()

      if bandInd==0:
          R=arr.shape[0]
          C=arr.shape[1]
          matImg=np.zeros((len(Bands), R, C), dtype=np.float16);
      matImg[bandInd,:,:]=np.float16(arr)/scale

      bandInd += 1

    return matImg

  # '''
  #     # create a list of files dir for all the images in different seasons of the input city dir
  #     # input:
  #             fileD: the absolute path of one city
  #     # output:
  #             files: all the files corresponding to different seasons
  # '''

def createFileList(fileD):
      files = []
      # imgNum_city = np.zeros((1,1), dtype=np.uint8)

     #all tif files
      # file = sorted(glob2.glob(fileD +'/**/*_'  + '*.tif'))
      # files.extend(file)

      for sea in ["spring", "summer", "autumn", "winter"]:
        if os.path.isdir(fileD +'/'+sea):
            files.extend(glob2.glob(fileD +'/'+sea +'/*_'  + sea  + '.tif'))

      return files

# from softmax get label save label return a label with color table
def saveLabel_fromSoftmax(labPred,tiffPath):
# this function save the predicted label
    try:
        fid = gdal.Open(tiffPath)
    except RuntimeError as e:
        print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
        print("ERROR:           the given data geotiff can not be open by GDAL")
        print("DIRECTORY:       "+tiffPath)
        print("GDAL EXCEPCTION: "+e)
        print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
        sys.exit(1)

    row = fid.RasterYSize
    col = fid.RasterXSize
    bnd = fid.RasterCount
    proj = fid.GetProjection()
    geoInfo = fid.GetGeoTransform()
    del(fid)

    if labPred.shape[0] != row * col:
        print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
        print("ERROR:           number of patches does not suit the output size")
        print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
        sys.exit(1)

    print(labPred.shape)
    print(np.median(labPred[:]))
    prob = np.reshape(labPred,(row,col,17))
    print(prob.shape)
    print(np.median(prob[:]))
    lab = prob.argmax(axis=2).astype(np.uint8)+1
    print(lab.shape)
    print(np.median(lab[:]))


    LCZDriver = gdal.GetDriverByName('GTiff')
    LCZFile = LCZDriver.Create(tiffPath, col, row, bnd, gdal.GDT_Byte)#gdal.GDT_UInt16 he gdal documentation describes the GDT_Byte as an 8 bit unsigned integer (see here).
    LCZFile.SetProjection(proj)
    LCZFile.SetGeoTransform(geoInfo)

    # save file with predicted label
    outBand = LCZFile.GetRasterBand(1)

    # create color table
    colors = gdal.ColorTable()

    # set color for each value
    colors.SetColorEntry(1, (165,   0,       33))
    colors.SetColorEntry(2, (204,   0,        0))
    colors.SetColorEntry(3, (255,   0,        0))
    colors.SetColorEntry(4, (153,   51,       0))
    colors.SetColorEntry(5, (204,   102,      0))

    colors.SetColorEntry(6, (255,   153,      0))
    colors.SetColorEntry(7, (255,   255,      0))
    colors.SetColorEntry(8, (192,   192,    192))
    colors.SetColorEntry(9, (255,   204,    153))
    colors.SetColorEntry(10, (77,    77,     77))

    colors.SetColorEntry(11, (0,   102,      0))
    colors.SetColorEntry(12, (21,   255,     21))
    colors.SetColorEntry(13, (102,   153,      0))
    colors.SetColorEntry(14, (204,   255,    102))
    colors.SetColorEntry(15, (0,     0,    102))

    colors.SetColorEntry(16, (255,   255,    204))
    colors.SetColorEntry(17, (51,   102,    255))

    # set color table and color interpretation
    outBand.SetRasterColorTable(colors)
    outBand.SetRasterColorInterpretation(gdal.GCI_PaletteIndex)

    outBand.WriteArray(lab)
    outBand.FlushCache()
    del(outBand)

    return lab



# save label
def saveLabel(lab,tiffPath):
# this function save the predicted label
    try:
        fid = gdal.Open(tiffPath)
    except RuntimeError as e:
        print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
        print("ERROR:           the given data geotiff can not be open by GDAL")
        print("DIRECTORY:       "+tiffPath)
        print("GDAL EXCEPCTION: "+e)
        print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
        sys.exit(1)

    row = fid.RasterYSize
    col = fid.RasterXSize
    bnd = fid.RasterCount
    proj = fid.GetProjection()
    geoInfo = fid.GetGeoTransform()
    del(fid)

    if lab.shape[0] != row   or lab.shape[1] !=  col:
        print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
        print("ERROR:           number of patches does not suit the output size")
        print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
        sys.exit(1)

    # print(labPred.shape)
    # print(np.median(labPred[:]))
    # prob = np.reshape(labPred,(row,col,17))
    # print(prob.shape)
    # print(np.median(prob[:]))
    # lab = prob.argmax(axis=2).astype(np.uint8)+1
    # print(lab.shape)
    # print(np.median(lab[:]))

    LCZDriver = gdal.GetDriverByName('GTiff')
    LCZFile = LCZDriver.Create(tiffPath, col, row, bnd, gdal.GDT_UInt16)
    LCZFile.SetProjection(proj)
    LCZFile.SetGeoTransform(geoInfo)

    # save file with predicted label
    outBand = LCZFile.GetRasterBand(1)
    outBand.WriteArray(lab)
    outBand.FlushCache()
    del(outBand)

    #return lab
