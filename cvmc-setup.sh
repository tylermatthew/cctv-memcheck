#!/bin/bash
#
# CVMC-SETUP-SCRIPT
# 
# attended installation script for -- cctv-memcheck -- and other things to meet
# Netlink's spec of unattended playback machine for unifi protect systems.
#  
# version 	0.2.2 - DEV
# author	Tyler Johnson

### ASSUMED TO BE ATTENDED ###	### ASSUMED TO BE ATTENDED ###	### ASSUMED TO BE ATTENDED ###

# LOADING FUNCTIONS

script_logo() {
  cat << "EOF"

	This is the
             __                                            __              __  
  __________/ /__   __      ____ ___  ___  ____ ___  _____/ /_  ___  _____/ /__
 / ___/ ___/ __/ | / /_____/ __ `__ \/ _ \/ __ `__ \/ ___/ __ \/ _ \/ ___/ //_/
/ /__/ /__/ /_ | |/ /_____/ / / / / /  __/ / / / / / /__/ / / /  __/ /__/ ,<   
\___/\___/\__/ |___/     /_/ /_/ /_/\___/_/ /_/ /_/\___/_/ /_/\___/\___/_/|_|.bash 
                                                                               
	Setup & Installation Script! 		aka: cvmc
	Made by, and for:	
	
	  \  |      |   |_)       |    	License: GNU General Public License v3.0
	   \ |  _ \ __| | | __ \  |  / 	Version: 0.1.0
	 |\  |  __/ |   | | |   |   <  	Author: Tyler Johnson
	_| \_|\___|\__|_|_|_|  _|_|\_\	only tested on Ubuntu... so far
	Checks for needed conditions and installs needed packages. 

EOF
}

cend='\e[0m'        # end format
cred='\e[31m'       # red
cgre='\e[1;32m'     # green
cblu='\e[34m'       # blue
cbol='\e[1m'        # bold
sita='\e[3m'        # italics

hdrblu() {
    clear
    clear
    echo -e "${cblu}############################################################################${cend}\n"
}

hdrred() {
    clear
    clear
    echo -e "${cred}############################################################################${cend}\n"
}

hdrgre() {
    clear
    clear
    echo -e "${cgre}############################################################################${cend}\n"
}

bhash=${cblu}#${cend}
rhash=${cred}#${cend}
ghash=${cgre}#${cend}
berr=${cbol}Error:${cend}

datme() {
    echo -e "$(date '+%F %I:%M:%S') - line$BASH_LINENO: current vars:$service, $snap, $curl_name\n" >> "$slog"
}

datmeins() {
    echo -e "$(date '+%F %I:%M:%S') - line$BASH_LINENO: beginning install. current vars:$service, $snap, $curl_name\n" >> "$slog"
}

datmefail() {
    echo -e "$(date '+%F %I:%M:%S') - line$BASH_LINENO: Error: anticipated fail. current vars:$service, $snap, $curl_name\n" >> "$slog"
}

# Put all of our functions in first, we may need them in some of the troubleshooting steps

# First, a call and response for the attending user
user_response() {
    echo -e -n "\n$bhash Press ${cbol}Enter${cend} to continue, or ${sita}any other key${cend} to stop\n\n" && read -n 1 -s -r -p ' ' key
    if [[ "$key" = "" ]]; then
        echo -e "$ghash Continuing..." && sleep 1 && clear
    else
        echo -e "$ghash stopping..." && sleep 1; clear; echo -e "The cvmc-setup log is at $slog" && sleep 1
		exit 1
    fi
}

# then to the installer functions
# we start with apt
service="service"
service_check () {
	echo -e "$bhash Checking on $service..."
	if [ "$(which $service)" ]; then
		echo -e "$bhash $service is installed, checking version...\n"; sleep 1
		instv=$(apt-cache policy $service | grep Inst | awk '{print $2}')
		candv=$(apt-cache policy $service | grep Cand | awk '{print $2}')
		if [ ! "$instv" = "$candv" ]; then
			echo -e "$bhash Updating $service from $instv to $candv\n" ; datmeins; sleep 1		# Logging before apt
			if ! apt install --only-upgrade $service -y &> "$slog"; then
				echo -e "$ghash $service updated from $instv to $candv \n"
			else
				echo -e "$rhash $berr failed updating $service\n"; datmefail
			fi
		else
			echo -e "$bhash $service is already installed and up to date!\n"; return 69 # code used to signal don't stop
		fi
	else
		echo -e "$bhash $service is not installed, installing now...\n"; datmeins; sleep 1	# Logging before apt
		if ! apt install $service -y &> "$slog"; then
			instv=$(apt-cache policy $service | grep Installed | awk '{print $2}')
			echo -e "$bhash $service $instv successfully installed\n"
		else
			echo -e "$rhash $berr failed installing $service\n"; datmefail
		fi
	fi
}

# now lets do the same for snap snaps

#first function

snap="snap"
snap_check () {
	echo -e "$bhash Checking on $snap..."
	datme; echo -e "snap func begin: $snap" >> "$slog"
	if snap list | grep -q "^$snap"; then
		echo -e "$bhash $snap is installed, checking for updates\n"; datmeins; sleep 1
		if ! snap refresh "$snap" &> "$slog"; then
			echo -e "$bhash $snap is already up to date\n"; return 69 # code used to signal don't stop
		else
			echo -e "$bhash $snap updated successfully\n"
		fi
	else
		echo -e "$bhash $snap is not installed. Attempting to install...\n"; datmeins; sleep 1
		if ! snap install "$snap" &> "$slog"; then
			echo -e "$bhash $snap installed successfully!\n"
		else
			echo -e "$rhash $berr failed installing $snap\n"; datmefail
		fi
	fi
}

#second function

curl_target='curl_target'
curl_name='curl_name'
curl_install () {
	echo -e "$bhash Installing Tailscale...\n"; wait
	datme; echo -e "Curl func begin: $curl_name" >> "$slog"
    if command -v "$curl_name" &> /dev/null; then
        echo -e "$bhash $curl_name is already installed. \n"; return 69 # code used to signal don't stop
    else
        echo -e "$bhash $curl_name is not installed. Attempting to install...\n"; datmeins; sleep 1
		curl_dir="$PWD/$curl_name"
	fi
	curl -fL "$curl_target" -o "$curl_dir"
	if bash "$curl_dir"; then
		sleep 1
		echo -e "\n$bhash $curl_name installed successfully!\n"
	else
		echo -e "$rhash $berr failed installing $curl_name\n"; datmefail
    fi
}

# now, lets clean up the repeated installing services

servicef() {
	datme; echo -e "apt func begin: $service..." >> "$slog"
	service_check
	if [ ! $? = 69 ]; then
		user_response
	fi
	sleep 1 && clear
}


otherf() {
	if [ ! $? = 69 ]; then
		user_response
	fi
	sleep 1 && clear
}
# gotta make this a function to return2

sshcheck() {
	echo -e "$bhash Checking the ssh port...\n"; datme; echo "checking ssh ports..." >> "$slog"
	ufw status | grep "22" | grep "ALLOW" >/dev/null ||	{
		dhclient && echo -e "$bhash resetting DHCP..."
		ufw enable &> "$slog"; wait
		ufw allow ssh &> "$slog"; wait
		ufw status | grep "22" | grep "ALLOW" >/dev/null || echo -e "$rhash $berr unable to start ssh\n" && return 2
		echo -e "$ghash has been enabled!\n"
	}
	echo -e "$ghash enabled!\n"; return 69 # code used to signal don't stop
}

##################################################################################### FIRST COMMANDS
# now for some troubleshooting before we start

# Check for root (SUDO).
if [[ "$EUID" -ne 0 ]]; then
	hdrred
	echo -e "The script need to be run as root...\n\nRun the command below to login as root\n${cbol}sudo -i${cend}\n"
 	exit 1
fi

# setup our log files for the script
slog="/var/log/cvmc-setup.log"

if [ ! -f "$slog" ]; then
	echo '# This is the log file for the cctv-memcheck setup script!\n# Created: '"$(date)"'by the setup script.\n' >> "$slog"
else
	datme
	echo "script ran again." >> "$slog"
fi

# Check DNS

brokedns() 	{
	echo -e "$rhash $berr DNS is still broken.\n$rhash ${cbol}This must be fixed for the script to work!${cend}"
	datme
	echo -e "Setup Error: DNS still Broken. Script aborted." >> "$slog"
	exit 1
}

host -t srv _ldap._tcp.google.com | grep "has SRV record" >/dev/null ||	{
	echo -e "${rhash}$berr DNS is broken.\n${sita}Allow the script to resolve?${cend}\n"; datme; echo -e "Setup Error: Had to repair DNS..." >> "$slog"
	user_response
    	echo -e "$bhash adding cloudflare dns..."; sleep 1
    	sed -i /127.0.0.53/a"nameserver 1.1.1.1" /etc/resolv.conf;
    	if [ $? -eq 0 ]; then
		echo -e "${cgre}#${cend} added!\n"; datme; echo -e "Added 1.1.1.1 to /etc/resolv.conf..." >> "$slog"
	else
		brokedns # this exit's the script!
	fi
	echo -e "$bhash Checking DNS again...\n"; sleep 1
	host -t srv _ldap._tcp.google.com | grep "has SRV record" >/dev/null ||     {
		brokedns # this exit's the script!
	}
	echo -e "${cgre}#Success!${cend}"; sleep 1
}

##################################################################################### BEGIN FRFR
# start screen

hdrblu
script_logo; sleep 1
user_response

# Now, lets start installing the software.
# curl
service="curl"
servicef

# htop
service="htop"
servicef

# nano
service="nano"
servicef

# openssh-server
service="ssh"
servicef

# open the ssh port
sshcheck
otherf
if [ $? = 2 ]; then
	datme; echo -e "ERROR: unable to configure ufw for ssh." >> "$slog"
	user_response
fi

# lets install cctv-viewer
snap="cctv-viewer"
snap_check
otherf

# now let's get our curl scripts, and install the software requiring them
curl_target="https://tailscale.com/install.sh"
curl_name="Tailscale"
curl_install
otherf

curl_target="https://raw.githubusercontent.com/tylermatthew/cctv-memcheck/main/cvmc_install.sh"
curl_name="cctv-memcheck"
curl_install
otherf

hdrgre
echo -e "setup script complete!"
echo -e -n "\n$bhash Press ${cbol}Enter${cend} to run $curl_name, or ${sita}any other key${cend} to stop\n\n" && read -n 1 -s -r -p ' ' key
if [[ "$key" = "" ]]; then
	echo -e "$ghash Starting cctv-memcheck..."
	/usr/local/bin/cctv-memcheck
	sleep 2
	pgrep cctv-m >/dev/null ||	{
		echo -e "$rhash $berr cctv-memcheck is not running! did the $curl_name fail?"
	}
	echo -e "$curl_name successfully started! Exiting..." && sleep 1; clear; echo -e "The cvmc-setup log is at $slog" && sleep 1
	rm cvmc_install.sh &> /dev/null
	exit 0
else
	echo -e "$ghash Exiting..." && sleep 1; clear; echo -e "The cvmc-setup log is at $slog" && sleep 1
	rm cvmc_install.sh &> /dev/null
	exit 0
fi
