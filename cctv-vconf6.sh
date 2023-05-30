#!/bin/bash

# cctv-vconf.sh
# This script writes rtsp url's to the appropriate location in the "CCTV Viewer.conf" file. 

filename="/home/jot6/snap/cctv-viewer/1032/.config/CCTV Viewer/CCTV Viewer.conf" # where the config file is

echo "we got here"

# set all the rtsps paths for the unifi cams

rtsp1="rtsps://192.168.1.195:7441/IA2Vh8ceJdTsw1i4?enableSrtp"
rtsp2="rtsps://192.168.1.195:7441/k2pgSv2lcX95WPJs?enableSrtp"
rtsp3="rtsps://192.168.1.195:7441/IuJpcEs5KonEeIY2?enableSrtp"
rtsp4="rtsps://192.168.1.195:7441/0aPr2fcf979HFuVm?enableSrtp"
rtsp5="rtsps://192.168.1.195:7441/Wld6SGW6qaC4pLjp?enableSrtp"
rtsp6="rtsps://192.168.1.195:7441/6qqbJg9kuYITlmsk?enableSrtp"
rtsp7="rtsps://192.168.1.195:7441/6qqbJg9kuYITlmsk?enableSrtp"
rtsp8="rtsps://192.168.1.195:7441/2Cv7gfVMXg35gEnV?enableSrtp"
rtsp9="rtsps://192.168.1.195:7441/Jskb1XrqVmziN0Rw?enableSrtp"
rtsp10="rtsps://192.168.1.195:7441/X6v4qIdXEkbBNkBl?enableSrtp"
rtsp11="rtsps://192.168.1.195:7441/X6v4qIdXEkbBNkBl?enableSrtp"

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
sed -i "s%url.....%&$rtsp10%10" "$filename"
sed -i "s%url.....%&$rtsp11%11" "$filename"
