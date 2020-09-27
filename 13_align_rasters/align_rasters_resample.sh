
tifDir=$1
ref=$2
tifUtmDir=$3

"usage example:"
#./align_rasters_resample.sh '/data/qiu/sampleData4test/00017_22007_Lagos_wgs84/summer/22007_summer.tif' '/data/qiu/sampleData4test/00017_22007_Lagos_s1_utm.tif' '/data/qiu/sampleData4test/00017_22007_Lagos_wgs84/summer/22007_summer_rsmd.tif'
# # the original tif files (in WGS82 projection)
# tifDir='/data/qiu/sampleData4test/00017_22007_Lagos_wgs84/summer/22007_summer.tif'
#
# #the dir of LCZ files (in UTM projection)
# ref='/data/qiu/sampleData4test/00017_22007_Lagos_s1_utm.tif'
#
# #the dir of the output tif files
# tifUtmDir='/data/qiu/sampleData4test/00017_22007_Lagos_wgs84/summer/22007_summer_rsmd.tif'

echo "tifDir: $1"
echo "ref: $2"
echo "tifUtmDir: $3"

#get the projection file
srsProLine=$(gdalsrsinfo $tifDir | grep PROJ.4 -m 1)
#find the line including 'PROJ.4 -m 1' in the output of (gdalsrsinfo $tifDir/$f)
echo $srsProLine

srsProLine=${srsProLine% *}
#cut srsProLine: delete the first (starting from right) space and everything rightwards.
echo $srsProLine

srsPro=${srsProLine#*\'}
#cut srsProLine: delete the first (starting from left) ' and everything leftwards.
echo $srsPro

desProLine=$(gdalsrsinfo $ref | grep PROJ.4 -m 1)
desProLine=${desProLine% *}
desPro=${desProLine#*\'}
echo $desPro


#get the extent
info=$(gdalinfo $ref | grep Lower -m 2)
# echo $info

info=${info#*(}
LowerLX=${info%%,*}
LowerLX=${LowerLX#* }
LowerLX=${LowerLX#* }

LowerLY=${info#*,}
LowerLY=${LowerLY%%)*}

info=$(gdalinfo $ref | grep Right -m 1)
# echo $info
info=${info#*(}
UpperRightX=${info%%,*}

UpperRightY=${info#*,}
UpperRightY=${UpperRightY%%)*}

echo $LowerLX
echo $LowerLY
echo $UpperRightX
echo $UpperRightY

buffer=0;
xmin=`echo "$LowerLX - $buffer" | bc`
ymin=`echo "$LowerLY - $buffer" | bc`
xmax=`echo "$buffer + $UpperRightX" | bc`
ymax=`echo "$buffer + $UpperRightY" | bc`
echo $xmin
echo $ymin
echo $xmax
echo $ymax


#this can show what the executed command look like
echo "gdalwarp -s_srs  "$srsPro" -t_srs "$desPro" -tr 10 10 $tifDir/$f $tifUtmDir/$f"
#"$srsPro" is to make the whole $srsPro as one variables

gdalwarp -s_srs "$srsPro" -t_srs "$desPro" -tr 10 10 -r cubic -te $xmin $ymin $xmax $ymax $tifDir $tifUtmDir
