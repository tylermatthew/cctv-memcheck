#! /bin/bash

# This is intended to be a curl-able script to fully install the restart_cctv-viewer.sh 
# and appropriately set up the viewing machine so that cctv-viewer is displayed at
# least 99% of the time. 

# Lets set some functions
script_name="restart_cctv-viewer"

raw_github_code_URL="https://raw.githubusercontent.com/tylermatthew/cctv-viewer-memleak-fix/main/restart_cctv-viewer.sh"

# Get code from $raw_github_code_URL and write it as a .sh file with $script_name to /usr/local/bin/
curl -o /usr/local/bin/"$script_name".sh "$raw_github_code_URL"

# Make it executable
chmod +x /usr/local/bin/"$script_name".sh

# Ensure it will run with permissions to start and kill services, and write new directories and files
chown root:root /usr/local/bin/"$script_name".sh
chmod u+s /usr/local/bin/"$script_name".sh

# Create an /etc/rc.local file if none exists, and add $script_name there so that it starts at system boot
if [ ! -f /etc/rc.local ]; then
    echo -en '#! /bin/sh -e \n # \n # rc.local - executed at the end of each multiuser runlevel \n # \n # Make sure that the script will "exit 0" on success or any other \n # value on error. \n \n \n exit 0' | sed 's/ //' >> /etc/rc.local
   
    chmod +x /etc/rc.local
fi
sed -i '$i/usr/local/bin/'"$script_name"'.sh &' /etc/rc.local

# Create the log file 
touch /var/log/"$script_name".log

# Run the restart script
/usr/local/bin/"$script_name".sh

# Print any errors to be visible to the attending user for troubleshooting, and print "Done!" upon success.
if [ $? -eq 0 ]; then
    echo "Done!"
else
    echo "An error occurred while running the script. Please check the log file for more information."
fi