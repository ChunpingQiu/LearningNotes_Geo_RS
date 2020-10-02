
# A small list

- Crop tiff file based on kml file

`gdalwarp -of GTiff -cutline 'xx.kml' -crop_to_cutline 'original.tif' 'cropped.tif'`

- Mosaics/Stacking a set of images

`python ./bin/gdal_merge.py -o 'output.tif' -n 250 -a_nodata 0 './1.tif' './2.tif' './3.tif' './4.tif'`

`python ./bin/gdal_merge.py -separate -q  $bands*B02.tif $bands*B02.tif $bands*B03.tif $bands*B04.tif $bands*B05.tif $bands*B06.tif $bands*B07.tif $bands*B08.tif $bands*B08a.tif  $bands*B11.tif $bands*B12.tif $bands*B11.tif $bands*B12.tif -o $city'.tif'`

-n <nodata_value>

    Ignore pixels from files being merged in with this pixel value.

-a_nodata <output_nodata_value>

    Assign a specified nodata value to output bands.

-separate

    Place each input file into a separate band.

# Important Reference

- https://github.com/dwtkns/gdal-cheat-sheet
