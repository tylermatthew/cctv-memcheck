#!/bin/bash
#
# This is the
#
#	  \  |      |   |_)       |    		License: GNU General Public License v3.0
#	   \ |  _ \ __| | | __ \  |  / 		Version: 0.1.1
#	 |\  |  __/ |   | | |   |   <  		Author: Tyler Johnson
#	_| \_|\___|\__|_|_|_|  _|_|\_\		only tested on Ubuntu 22.04
#
# 		  install script to be curl-ed
#			by the setup script.
# 		
# This is intended to be a curl-able script to fully install the restart_cctv-viewer.sh 
# and appropriately set up the viewing machine so that cctv-viewer is displayed at
# least 99% of the time. 

usr=$(ls -l /home | awk '{print $3}' | tail -n +2)
script_name="restart_cctv-viewer"

# Lets make the file and fill it. 

touch /usr/local/bin/"$script_name".sh
echo "getting $script_name..."; sleep 1
wget /usr/local/bin/"$script_name".sh https://raw.githubusercontent.com/tylermatthew/cctv-viewer-memleak-fix/main/restart_cctv-viewer.sh; wait && sleep 1

# Make it executable
echo "making it x..."
chmod +x /usr/local/bin/"$script_name".sh; sleep 1

# Create an /etc/rc.local file if none exists, and add $script_name there so that it starts at system boot
if [ ! -f /etc/rc.local ]; then
    echo "creating rc.local..."
    echo -en "#!  /bin/sh -e \n # \n # rc.local - executed at the end of each multiuser runlevel \n # \n # Make sure that the script will "exit 0" on success or any other \n # value on error. \n\n /usr/local/bin/'"$script_name"'.sh & \n\n exit 0" | sed 's/ //' >> /etc/rc.local
    chmod +x /etc/rc.local; sleep 1
fi

# Create the log file 
echo "creating log file and giving it to $usr..."
touch /var/log/"$script_name".log
chown "$usr":"$usr" /var/log/"$script_name".log

echo "verifying..." 

ls /usr/local/bin/ | grep restart >/dev/null ||	{
	echo "ERROR: No rcv in user's bin folder!"
	echo "$(date) ERROR: No rcv in user's bin folder!" >> /var/log/$script_name.log
}
ls /var/log/ | grep restart >/dev/null ||	{
	echo "ERROR: No $script_name log file!"
	echo "$(date) ERROR: No $script_name log file!" >> /var/log/$script_name.log
}
ls /etc | grep rc.local >/dev/null || 	{
	echo "ERROR: No rc.local file!"
	echo "$(date) ERROR: No rc.local file!" >> /var/log/$script_name.log
}
cat /etc/rc.local | grep $script_name >/dev/null ||	{
	echo "ERROR: $script_name not found in the rc.local file!"
	echo "$(date) ERROR: $script_name not found in the rc.local file!" >> /var/log/$script_name.log
}
log_own=$(ls -all /var/log/ | grep cctv | grep $usr | awk '{print $3}'); [[ $usr = $log_own ]] ||	{
	echo "ERROR: $script_name log isnt owned by $usr!"
	echo "$(date) ERROR: $script_name log isnt owned by $usr!" >> /var/log/$script_name.log
}

# Run the restart script
/usr/local/bin/"$script_name".sh

# Print any errors to be visible to the attending user for troubleshooting, and print "Done!" upon success.
if [ $? -eq 0 ]; then
    echo "Done!"
else
    echo "An error occurred while running the script. Please check the log file for more information."; exit 1
fi
exit 0
