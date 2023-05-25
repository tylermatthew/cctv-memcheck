#!/bin/bash

# cctv-vconf.sh
# This script writes rtsp url's to the appropriate location in the "CCTV Viewer.conf" file. 

filename="/home/jot3/snap/cctv-viewer/1032/.config/CCTV Viewer/CCTV Viewer.conf" # where the config file is

echo "we got here"

# set all the rtsps paths for the unifi cams

rtsp1="rtsps://10.10.11.10:7441/1wen6vyo8C4bBPdW?enableSrtp"
rtsp2="rtsps://10.10.11.10:7441/grPUH83laJdV4KES?enableSrtp"
rtsp3="rtsps://10.10.11.10:7441/tVu4UZ5uP3lseFxd?enableSrtp"
rtsp4="rtsps://10.10.11.10:7441/Y8Toll6Pl3CTpxgG?enableSrtp"
rtsp5="rtsps://10.10.11.10:7441/rkeISfWiLpWQBv2I?enableSrtp"
rtsp6=''
rtsp7=''
rtsp8=''
rtsp9=''

echo "variables set"

sed -i "s%url.....%&$rtsp1%" "$filename"
sed -i "s%url.....%&$rtsp2%2" "$filename"
sed -i "s%url.....%&$rtsp3%3" "$filename"
sed -i "s%url.....%&$rtsp4%4" "$filename"
sed -i "s%url.....%&$rtsp5%5" "$filename"
sed -i "s%url.....%&$rtsp6%6" "$filename"
sed -i "s%url.....%&$rtsp7%7" "$filename"
sed -i "s%url.....%&$rtsp8%8" "$filename"
sed -i "s%url.....%&$rtsp9%9" "$filename"
