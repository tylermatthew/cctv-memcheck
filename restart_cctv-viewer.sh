#!/bin/bash
#
# This is the
#
#	  \  |      |   |_)       |    		License: GNU General Public License v3.0
#	   \ |  _ \ __| | | __ \  |  / 		Version: 0.1.1
#	 |\  |  __/ |   | | |   |   <  		Author: Tyler Johnson
#	_| \_|\___|\__|_|_|_|  _|_|\_\		only tested on Ubuntu 22.04
#
# 		  simple loop trying to keep 
# 				cctv-viewer 
#	displaying camera feeds, no matter what! 
# 		assumed to be unattended

# first, we need to set the username for whatever machine this runs on, 
# since snaps annoyingly fail to run when started by root
# this is a pretty roundabout way to do it, but hey I avoided sed, so there's that.

usr=$(ls -l /home | awk '{print $3}' | tail -n +2) 
threshold=2500000 # Set the memory threshold for stopping the service (in kilobytes)
restart_threshold=1000000 # Set the memory threshold for restarting the service (in kilobytes)
service_name="cctv-viewer" # Set the name of the service to monitor
log_file="/var/log/restart_cctv-viewer.log" # Set the path to the log file
logfilesize_threshold=5000 # Define the highest number of lines the log file should be allowed to reach
logfilesize_retain=500 # Define the number of lines to retain in the log file during its re-write

# before we get into our loop, let's do some housekeeping
# first off, lets log the script starting up

# Check if the log file exists, of not make it and own it
if [ ! -f "$log_file" ]; then
    touch "$log_file"
	chown "$usr":"$usr" "$log_file"
fi

# Check if the log file has reached the threshold
# If it has, remove all but the last number of entries specified
if [ $(wc -l < "$log_file") -gt $logfilesize_threshold ]; then
	tail -n $logfilesize_retain "$log_file" > "$log_file.tmp"
    mv "$log_file.tmp" "$log_file"
fi

# Start our primary infinite loop of checking, stopping, and starting
while true; do
	mem_usage=$(free | awk '/Mem/{print $3}') # Get the current memory usage
	if [ $mem_usage -gt $threshold ]; then # Check if the memory usage is above the threshold
	
        # Log that we're stopping the service due to high memory usage
        echo "$(date): Stopping $service_name due to memory exceeding $(expr $threshold \/ 1000000) Gb" >> "$log_file"
		(killall $service_name 2>&1 | sed "s/^/$(date): /" >> $log_file) # Kill the service and log any output or errors

        # Wait for the memory usage to drop below the restart threshold
        while [ $mem_usage -gt $restart_threshold ]; do 
            sleep 2
			mem_usage=$(free | awk '/Mem/{print $3}')
        done
		
		# Start the service in fullscreen and log any output or errors
		su -c "$service_name" "$usr" 2>&1 | sed "s/^/$(date): /" >> "$log_file" &
		echo "$(date): Starting $service_name in kiosk mode after memory usage dropped below $(expr $restart_threshold \/ 1000000) Gb" >> "$log_file"
    fi
	sleep 10

        # Check if the cctv-viewer program is running, and Start the cctv-viewer program in Kiosk mode
    if ! pgrep -x "$service_name" > /dev/null; then
		su -c "$service_name" "$usr" 2>&1 | sed "s/^/$(date): /" >> "$log_file" &
		echo "$(date): Error - Started $service_name in kiosk mode after finding it not running" >> "$log_file"
    fi
	sleep 60 # Sleep for 1 minute before checking again
done
exit 0
