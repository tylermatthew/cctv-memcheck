#! /bin/bash
#
#   It's...   __                                            __              __  
#  __________/ /__   __      ____ ___  ___  ____ ___  _____/ /_  ___  _____/ /__
# / ___/ ___/ __/ | / /_____/ __ `__ \/ _ \/ __ `__ \/ ___/ __ \/ _ \/ ___/ //_/
#/ /__/ /__/ /_ | |/ /_____/ / / / / /  __/ / / / / / /__/ / / /  __/ /__/ ,<   
#\___/\___/\__/ |___/     /_/ /_/ /_/\___/_/ /_/ /_/\___/_/ /_/\___/\___/_/|_| 
#                                                                               
#	 
#	Made by, and for:	
#	
#	  \  |      |   |_)       |    	License: GNU General Public License v3.0
#	   \ |  _ \ __| | | __ \  |  / 	Version: 0.2.0
#	 |\  |  __/ |   | | |   |   <  	Author: Tyler Johnson
#	_| \_|\___|\__|_|_|_|  _|_|\_\	only tested on Ubuntu... so far
#	Keeps cctv-viewer up and running, at least we hope it does! 

# vars and functions. maybe a config file in the future?

usr=$(ls -l /home | awk '{print $3}' | tail -n +2) 
threshold=2500000 # Set the memory threshold for stopping the service (in kilobytes)
restart_threshold=1000000 # Set the memory threshold for restarting the service (in kilobytes)
service_name="cctv-viewer" # Set the name of the service to monitor
log_file="/var/log/restart_cctv-viewer.log" # Set the path to the log file
logfilesize_threshold=5000 # Define the highest number of lines the log file should be allowed to reach
logfilesize_retain=500 # Define the number of lines to retain in the log file during its re-write

datrep() {
    echo -e "$(date '+%F %I:%M:%S') - line$BASH_LINENO - MEM: $mem_usage\n - script trigger" >> "$log_file"
}

######################################################################## BEGIN CHECK LOOP

while true; do
	mem_usage=$(free | awk '/Mem/{print $3}') # current memory used
	if [ $mem_usage -gt $threshold ]; then # check if over threshold
        datrep; echo "Stopping $service_name due to memory exceeding $(expr $threshold \/ 1000) Mb" >> "$log_file" # logging
		(killall $service_name &>> "$log_file") # Kill it
        while [ $mem_usage -gt $restart_threshold ]; do sleep 2 # wait for memory to drop
			mem_usage=$(free | awk '/Mem/{print $3}') # re-check current memory used
        done
		su -c "$service_name" "$usr" &>> "$log_file" & #restart cctv-viewer
		datrep; echo "Starting $service_name in kiosk mode after memory usage dropped below $(expr $restart_threshold \/ 1000) Mb" >> "$log_file"
    fi
	
# Logfile Cleanup
	if [ $(wc -l < "$log_file") -gt $logfilesize_threshold ]; then
		head -n 5 "$log_file" && tail -n $logfilesize_retain "$log_file" > "$log_file.tmp"
		mv "$log_file.tmp" "$log_file"
	fi
# give cctv-viewer time to start if the memory statement started it...
	sleep 5
	
    if ! pgrep -x "$service_name" > /dev/null; then # Check if cctv-viewer is running
		su -c "$service_name" "$usr" &>> "$log_file" &
		echo "$(date): Error - Started $service_name in kiosk mode after finding it not running" >> "$log_file"
    fi
	if [ $mem_usage < $restart_threshold ]; then
		sleep 1200; datrep; echo -e "cctv-memcheck hibernating until $(date --date="+1200 seconds" '+%I:%M:%S')\n" >> "$log_file"
	fi
	mem_dif=$(expr $mem_usage - $restart_threshold)
	if [ $mem_dif -gt 1000000 ] 
		sleep 300; datrep; echo -e "cctv-memcheck napping until $(date --date="+300 seconds" '+%I:%M:%S')\n" >> "$log_file"
	sleep 60 # Sleep for 1 minute before checking again
done
exit 0
