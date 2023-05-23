#!/bin/bash

# cctv-vconf.sh
# This script writes rtsp url's to the appropriate location in the "CCTV Viewer.conf" file. 

filename="/home/jot3/snap/cctv-viewer/1032/.config/CCTV Viewer/CCTV Viewer.conf" # where the config file is

echo "we got here"

# set all the rtsps paths for the unifi cams

rtsp1="rtsps://192.168.1.253:7441/9uJXXN9m4vRwBLBT?enableSrtp"
rtsp2="rtsps://192.168.1.253:7441/mwuFcda1ojkLVnLK?enableSrtp"
rtsp3="rtsps://192.168.1.253:7441/U2gOCqELeSIpgC0C?enableSrtp"
rtsp4="rtsps://192.168.1.253:7441/GlJS5YbrDdF2XdHr?enableSrtp"
rtsp5="rtsps://192.168.1.253:7441/UIlT3EkrgmHtJMwf?enableSrtp"
rtsp6="rtsps://192.168.1.253:7441/AMGUetnZcsrBBfgu?enableSrtp"
rtsp7="rtsps://192.168.1.253:7441/RGrUtOGwfqR2GpP6?enableSrtp"
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
