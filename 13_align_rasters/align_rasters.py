#!/usr/bin/env python
# -*- coding: utf-8 -*-
# File              : align_rasters.py
# Author            : Yuanyuan Wang <y.wang@tum.de>
# Date              : 22.03.2020 12:14:16
# Last Modified Date: 22.03.2020 12:14:16
# Last Modified By  : Yuanyuan Wang <y.wang@tum.de>import subprocess, os,  sys

# Last Modified By  : Chunping Qiu add comments and examples

try:
    from osgeo import gdal
    from osgeo import osr
except:
    import gdal
    import osr

import sys, os
import subprocess

ref_tif = sys.argv[1]
target_tif = sys.argv[2]
output_suffix = sys.argv[3]

############################################################################
"example to use"
#python align_rasters.py /data/qiu/sampleData4test/00017_22007_Lagos_s1_utm.tif /data/qiu/sampleData4test/00017_22007_Lagos_wgs84/spring/22007_spring.tif "_resampled.tif"
#sample data for test: https://drive.google.com/drive/folders/1EPsBIkESTRdo8-wh3eNvAQeZ4z9yFa8o?usp=sharing
############################################################################

def align_rasters(ref_raster, tar_raster, output_suffix):
    """
    Aligns a raster to have the same resolution and
    cell size for pixel based calculations.

    :param ref_raster: full path to the reference geotiff to get the information about resolution and
    cell size.

    :param tar_raster: raster path to be resampled.

    :param output_suffix: The output aligned rasters files suffix with extension.
    :type output_suffix: String

    :return: True if the process runs and False if the data couldn't be read.
    :rtype: Boolean
    """
    command = ["gdalbuildvrt", "-te"]
    hDataset = gdal.Open(ref_raster, gdal.GA_ReadOnly)
    if hDataset is None:
        return False
    adfGeoTransform = hDataset.GetGeoTransform(can_return_null=True)

    tif_file=tar_raster
    vrt_file = tif_file.replace('.tif', '.vrt')

    if adfGeoTransform is not None:
       dfGeoXUL = adfGeoTransform[0]
       dfGeoYUL = adfGeoTransform[3]
       dfGeoXLR = adfGeoTransform[0] + adfGeoTransform[1] * hDataset.RasterXSize + \
                  adfGeoTransform[2] * hDataset.RasterYSize
       dfGeoYLR = adfGeoTransform[3] + adfGeoTransform[4] * hDataset.RasterXSize + \
                  adfGeoTransform[5] * hDataset.RasterYSize
       xres = str(abs(adfGeoTransform[1]))
       yres = str(abs(adfGeoTransform[5]))

       subprocess.call(command + [str(dfGeoXUL), str(dfGeoYLR), str(dfGeoXLR),
                                  str(dfGeoYUL), "-q", "-tr", xres, yres,
                                  vrt_file, tif_file])

       output_file = tif_file.replace('.tif', output_suffix)

       print('gdal_translate -q {} {}'.format(vrt_file, output_file))

       cmd = 'gdal_translate -q {} {}'.format(vrt_file, output_file)

       #print(dfGeoXUL, dfGeoYLR, dfGeoXLR, dfGeoYUL, xres, yres)

       subprocess.call(cmd, shell=True)
       os.remove(vrt_file)

       return True

    else:

       return False

align_rasters(ref_tif, target_tif, output_suffix)
