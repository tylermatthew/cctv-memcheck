#!/bin/bash

# cctv-vconf.sh
# This script writes rtsp url's to the appropriate location in the "CCTV Viewer.conf" file. 

filename="/home/jot1/snap/cctv-viewer/1017/.config/CCTV Viewer/CCTV Viewer.conf" # where the config file is

echo "we got here"

# set all the rtsps paths for the unifi cams

rtsp1="rtsps://192.168.1.83:7441/su91uLbgB6SYKXIc?enableSrtp"
rtsp2="rtsps://192.168.1.83:7441/RCn9FH1Wwb0ibSBm?enableSrtp"
rtsp3="rtsps://192.168.1.83:7441/Q5BIkG8nWgvkiSZQ?enableSrtp"
rtsp4="rtsps://192.168.1.83:7441/ZRHQTrCYUGaELgTr?enableSrtp"
rtsp5="rtsps://192.168.1.83:7441/KFyxBxhBBT4h3JbR?enableSrtp"
rtsp6="rtsps://192.168.1.83:7441/0AuthAAZy4pLxMQ7?enableSrtp"
rtsp7="rtsps://192.168.1.83:7441/e9jUTacnNYDv69aN?enableSrtp"
rtsp8="rtsps://192.168.1.83:7441/WoFrGw3nTJFXqdK1?enableSrtp"
rtsp9="rtsps://192.168.1.83:7441/xjrUOAreToVsbP7F?enableSrtp"
rtsp10="rtsps://192.168.1.83:7441/yGYPhkDHBoEwrVvf?enableSrtp"
rtsp11="rtsps://192.168.1.83:7441/uTxWjXRi0bvDchwX?enableSrtp"
rtsp12="rtsps://192.168.1.83:7441/ni3dInDpeiD8G5re?enableSrtp"
rtsp13=''
rtsp14=''
rtsp15=''
rtsp16=''

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
sed -i "s%url.....%&$rtsp12%12" "$filename"
sed -i "s%url.....%&$rtsp13%13" "$filename"
sed -i "s%url.....%&$rtsp14%14" "$filename"
sed -i "s%url.....%&$rtsp15%15" "$filename"
sed -i "s%url.....%&$rtsp16%16" "$filename"
