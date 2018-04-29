#!/bin/bash
id="LC08_L1TP_138043_20180401_20180416_01_T1_B"
projection_code=32645
#Reproject each of the bands.

for BAND in 1 2 3 4 5 6 7 9 10 11
do
 projected_name="Band_$BAND"
 gdalwarp -t_srs EPSG:$projection_code "$id$BAND.TIF" "$projected_name.tif"

 #translate bands into the 8-bit format (0-255)
 gdal_translate -ot Byte -scale 0 65535 0 255 "$projected_name.tif" "$projected_name-scaled.tif"
done


# #merge the three reprojected band images into a single composite image
python3.6 gdal_merge.py -v -separate -of GTiff -co PHOTOMETRIC=RGB -o "merged.tiff" $(ls *-scaled*)

# #georeference the image
gdalwarp -t_srs EPSG:$projection_code "merged.tiff" "merged_projected.tiff"
# rm "merged.tiff"

# #remove black background
gdalwarp -srcnodata 0 -dstalpha "merged_projected.tiff" "final.tiff"

rm *Band_*
rm *merged*