#!/bin/bash

#   The       __                                            __              __  
#  __________/ /__   __      ____ ___  ___  ____ ___  _____/ /_  ___  _____/ /__
# / ___/ ___/ __/ | / /_____/ __ `__ \/ _ \/ __ `__ \/ ___/ __ \/ _ \/ ___/ //_/
#/ /__/ /__/ /_ | |/ /_____/ / / / / /  __/ / / / / / /__/ / / /  __/ /__/ ,<   
#\___/\___/\__/ |___/     /_/ /_/ /_/\___/_/ /_/ /_/\___/_/ /_/\___/\___/_/|_|.bash
#
#		Installation Script!							aka: cvmc_install.sh
#		Made by:
#	  \  |      |   |_)       |    		License: GNU General Public License v3.0
#	   \ |  _ \ __| | | __ \  |  / 		Version: 0.2.1 - DEV
#	 |\  |  __/ |   | | |   |   <  		Author: Tyler Johnson
#	_| \_|\___|\__|_|_|_|  _|_|\_\		only tested on Ubuntu 22.04
#	Curl-able installation script for cctv-memcheck, to be called and deleted!

# Vars

usr=$(ls -l /home | awk '{print $3}' | tail -n +2)
script_name="cctv-memcheck"
slog="/var/log/cvmc-setup.log"
cvmc_url="https://raw.githubusercontent.com/tylermatthew/main/cctv-memcheck"

rchead() {
	echo '#!/bin/sh -e 
#  
# rc.local - executed at the end of each multiuser runlevel 
# 
# Make sure that the script will "exit 0" on success or any other 
# value on error.

/usr/local/bin/'"$script_name"' & 
 
 exit 0
 ' >> /etc/rc.local
 }
 errcnt=0
 verr() {
	echo "$(date '+%F %I:%M:%S') - line$BASH_LINENO: Verification Error!" >> "$slog"
	errcnt=$(expr $errstat + 1)
}
 
# Note this script running in the setup log, create cvmc's log file, and wget cvmc

echo -e "$(date '+%F %I:%M:%S') - line$BASH_LINENO: cvmc-install started" >> "$slog"
touch /usr/local/bin/"$script_name" &>> "$slog"
wget -P /usr/local/bin/ "$cvmc_url" &>> "$slog"; wait && sleep 1
chmod +x /usr/local/bin/"$script_name" &>> "$slog"; sleep 1

# Create an /etc/rc.local file if none exists, and add $script_name there so that it starts at system boot
if [ ! -f /etc/rc.local ]; then
    echo -e "$(date '+%F %I:%M:%S') - line$BASH_LINENO: creating rc.local..." >> "$slog"
    rchead
    chmod +x /etc/rc.local &>> "$slog"; sleep 1
fi

# Create the cctv-memcheck log file 
echo -e "$(date '+%F %I:%M:%S') - line$BASH_LINENO: creating log file and giving it to $usr..." >> "$slog"
touch /var/log/"$script_name".log &>> "$slog"
chown "$usr":"$usr" /var/log/"$script_name".log &>> "$slog"

echo -e "$(date '+%F %I:%M:%S') - line$BASH_LINENO: Verifying..." >> "$slog"
ls -l /usr/local/bin/ | grep cctv-m >/dev/null || verr
ls /var/log/ | grep cctv-m >/dev/null || verr
ls /etc | grep rc.local >/dev/null ||  verr
cat /etc/rc.local | grep $script_name >/dev/null ||	verr
log_own=$(ls -all /var/log/ | grep cctv | grep $usr | awk '{print $3}'); [[ $usr = $log_own ]] || verr

if [ $errcnt -gt 0 ]; then
	echo -e "Error: The script failed $errcnt verifications!\nPlease check $slog for more info."; sleep 2
	exit 1
else
	echo -e "Congratulations on installing cctv-memcheck!"; sleep 2
	exit 0
fi
