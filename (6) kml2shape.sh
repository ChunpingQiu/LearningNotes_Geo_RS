# @Date:   2020-06-18T21:04:12+02:00
# @Last modified time: 2020-06-25T10:59:31+02:00

#!/bin/bash
set -e

#################useage###############################
# convert all the kml files in a folder into shape files

# the dir of the kml files
Dir='/data/qiu/LCZ_wudpat_train/files4shTest/kml/*/'

# the dir to save the output shape files
saveFolder='/data/qiu/LCZ_wudpat_train/files4shTest/shapeFile/'
#################useage###############################

files=$(find $Dir -name '*.km*')

for f in $files; do
	echo $f

	city0=${f%/*}
	#cut f: delete the first (starting from right) / and everything rightwards.
	#echo $city0
  city=${city0##*/}
  #cut city0: delete the first (starting from left) / and everything leftwards.
	#echo $city

	rm -r -f  $saveFolder$city

	#ogrmerge.py -o $saveFolder$city $f -nln $city'_'{LAYER_NAME}
	#the output are multiple files for multiple subdir in the kml file

	#only one shape file output
	ogrmerge.py -single -o $saveFolder$city $f -nln $city -src_layer_field_name class -src_layer_field_content {LAYER_NAME}

done;
#-nln $city sets the output name of the shape files
# Only used with -single. If specified, the schema of the target layer will be extended with a new field ‘name’, whose content is determined by -src_layer_field_content.
