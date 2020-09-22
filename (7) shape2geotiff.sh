
#################useage###############################
# convert all the shape files in a folder into utm geotiff files
# remember to set the pixel value and size accordinly in gdal_rasterize

#the dir of shape files
shpDir='/data/qiu/LCZ_wudpat_train/files4shTest/shapeFile/'

#the dir of the output tif files (in utm projection)
tifDir='/data/qiu/LCZ_wudpat_train/files4shTest/tifUTM/'
#################useage###############################

files=$(ls -tr -d $shpDir*/)

cd $shpDir

for f in $files; do
	echo $f

	city0=${f%/*}
  city=${city0##*/}
	echo $city

	# kmlFile=$Dir$city/*.km*
	# echo $kmlFile

	#option 1 find the projection file from a shape file
	utmProj="$(python ./util/readROI2UTM.py $f/$city.shp)"
	# echo $utmProj

	#option 2 "find the projection file from a geotif"
	# lczF=$(find $lczDir -maxdepth 1 -iname "*$city*")
	# echo $lczF
	#
	# desProLine=$(gdalsrsinfo $lczF | grep PROJ.4 -m 1)
	# desProLine=${desProLine% *}
	# desPro=${desProLine#*\'}
	# echo $desPro
	#ogr2ogr -t_srs "$desPro" $city/utm.shp $city/$city.shp

	ogr2ogr -t_srs "$utmProj" $f/utm.shp $f/$city.shp

	gdal_rasterize -a class -a_nodata 0 -tr 300 300 -ot UInt16 -l utm $f/utm.shp $tifDir$city.tif


done;
#-a class sets the column to get the pixel value
#python /data/qiu/LCZ_wudpat_train/util/readROI2UTM.py /data/qiu/LCZ_wudpat_train/shapeFile/Tandil/Tandil.shp
