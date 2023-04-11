#!/bin/bash
#
# first, we need to set the username for whatever machine this runs on, since snap's annoyingly fail to run when started by root

usr=$(ls -l /home | awk '{print $3}' | tail -n +2) # this is a pretty roundabout way to do it, but hey I avoided sed, so there's that.

# Set the memory threshold for stopping the service (in kilobytes)
threshold=2500000 # 2.5GB

# Set the memory threshold for restarting the service (in kilobytes)
restart_threshold=1000000 # 1GB

# Set the name of the service to monitor
service_name="cctv-viewer"

# Set the path to the log file
log_file="/var/log/restart_cctv-viewer.log"

# Define the highest number of lines the log file should be allowed to reach
logfilesize_threshold=5000

# Define the number of lines to retain in the log file during its re-write
logfilesize_retain=500

# Check if the log file exists
if [ ! -f "$log_file" ]; then

    # If it doesn't exist, create it
    touch "$log_file"
	
	# lets make sure the user owns the log file
	chown "$usr":"$usr" "$log_file"
fi

# Check if the log file has reached the threshold
if [ $(wc -l < "$log_file") -gt $logfilesize_threshold ]; then

    # If it has, remove all but the last number of entries specified
    tail -n $logfilesize_retain "$log_file" > "$log_file.tmp"
    mv "$log_file.tmp" "$log_file"
fi

# Start an infinite loop
while true; do

    # Get the current memory usage
    mem_usage=$(free | awk '/Mem/{print $3}')
    
    # Check if the memory usage is above the threshold
    if [ $mem_usage -gt $threshold ]; then
	
        # Log that we're stopping the service due to high memory usage
        echo "$(date): Stopping $service_name due to high memory usage" >> $log_file

        # Kill the service and log any output or errors
        (killall $service_name 2>&1 | sed "s/^/$(date): snap reply - /" >> $log_file)

        # Wait for the memory usage to drop below the restart threshold
        while [ $mem_usage -gt $restart_threshold ]; do
		
            # Sleep for 2 seconds before checking again
            sleep 2
			
            # Get the current memory usage again
            mem_usage=$(free | awk '/Mem/{print $3}')
        done
		
		# Start the service in fullscreen and log any output or errors
		(su -c "snap run $service_name -k 2>&1" "$usr" | sed "s/^/$(date): snap reply - /" >> "$log_file" &)
			
			# Log that we're starting the service in kiosk mode after memory usage dropped below threshold
        echo "$(date): Starting $service_name in kiosk mode after memory usage dropped below ($restart_threshold/1000000) Gb" >> "$log_file"
    fi

        # wait 10 seconds to give cctv-viewer time to start
        sleep 10

        # Check if the cctv-viewer program is running
    if ! pgrep -x "$service_name" > /dev/null; then

        # Start the cctv-viewer program in Kiosk mode
        (su -c "snap run $service_name -k 2>&1" "$usr" | sed "s/^/$(date): snap reply - /" >> "$log_file" &)

        # Write a log entry to the cctv-viewer.log file
        echo "$(date): Error - Started $service_name in fullscreen mode after finding it not running" >> "$log_file"
    fi
    
    # Sleep for 1 minute before checking again
    sleep 60
done
