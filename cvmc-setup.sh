#!/bin/bash
#
# CVMC-SETUP-SCRIPT
# 
# attended installation script for -- cctv-memcheck -- and other things to meet
# Netlink's spec of unattended playback machine for unifi protect systems.
#  
# version 	0.3.0 - DEV
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
	   \ |  _ \ __| | | __ \  |  / 	Version: 0.3.0
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
    echo -e "$(date '+%F %I:%M:%S') - line$BASH_LINENO: current vars:$service, $snap, $curlname\n" >> "$slog"
}

datmeins() {
    echo -e "$(date '+%F %I:%M:%S') - line$BASH_LINENO: beginning install. current vars:$service, $snap, $curlname\n" >> "$slog"
}

datmefail() {
    echo -e "$(date '+%F %I:%M:%S') - line$BASH_LINENO: Error: anticipated fail. current vars:$service, $snap, $curlname\n" >> "$slog"
}

# User input prompt
user.response() {
    echo -e -n "\n$bhash Press ${cbol}Enter${cend} to continue, or ${sita}any other key${cend} to stop\n\n" && read -n 1 -s -r -p ' ' key
    if [[ "$key" = "" ]]; then echo -e "$ghash Continuing..." && sleep 1 && clear
    else echo -e "$ghash stopping..." && sleep 1; clear; echo -e "The cvmc-setup log is at $slog" && sleep 1
		exit 1
    fi
}

# service handling

service="service"

service.check.version() {
	instv=$(apt-cache policy $service | grep Inst | awk '{print $2}')
	candv=$(apt-cache policy $service | grep Cand | awk '{print $2}')
}

service.update() {
	datemeins
	apt install --only-upgrade $service -y &> "$slog"
}

service.install() {
	datmeins
	apt install $service -y && wait
}

service.check() {
	echo -e "$bhash Checking on $service..."
	if [ "$(which $service)" ]; then service.check.version
		echo -e "$bhash $service is installed, checking version...\n"; sleep 1
		if [ ! "$instv" = "$candv" ]; then echo -e "$bhash Updating $service from $instv to $candv\n"
			service.update
			service.check.version
			if [ "$instv" = "$candv" ]; then echo -e "$ghash $service updated! \n"; return 69
			else echo -e "$rhash $berr failed updating $service\n"; datmefail
			fi
		else echo -e "$bhash $service is already installed and up to date!\n"; return 69
		fi
	else echo -e "$bhash $service is not installed, installing now...\n"
		service.install
		service.service.check
		if [ "$(which $service)" ]; then echo -e "$bhash $service $instv successfully installed\n"
		else echo -e "$rhash $berr failed installing $service\n"; datmefail
		fi
	fi
}

# snap handling

snap="snap"

snap.install() {
	datmeins
	snap install "$snap"
}

snap.check() {
	datme; echo -e "$bhash Checking on $snap..."
	if snap list | grep -q "^$snap"; then
		echo -e "$bhash $snap is installed already"; return 69 # signal don't stop
	else snap.install
		echo -e "$bhash $snap is not installed. Installing now...\n"
		if snap list | grep -q "^$snap"; then
			echo -e "$bhash $snap installed successfully!\n"; return 69
		else echo -e "$rhash $berr failed installing $snap\n"; datmefail
		fi
	fi
}

#second function

curltarget="curl"
curlname="curlname"
curl.install() {
	curl_dir="$PWD/$curlname"
	datme; echo -e "$bhash Installing $curlname...\n"
    if command -v "$curlname" &> /dev/null; then
        echo -e "$bhash $curlname is already installed. \n"; return 69 # signal don't stop
    else echo -e "$bhash $curlname is not installed. Attempting to install...\n"
	datmeins; curl -fL "$curltarget" -o "$curl_dir"
	fi
	if bash "$curl_dir"; then wait
		echo -e "\n$bhash $curlname installed successfully!\n"
	else echo -e "$rhash $berr failed installing $curlname\n"; datmefail
    fi
}

servicef() {
	service.check
	if [ ! $? = 69 ]; then
		user.response 
	fi
	sleep 1 && clear
}


otherf() {
	if [ ! $? = 69 ]; then
		user.response 
	fi
	sleep 1 && clear
}
# gotta make this a function to return2

sshcheck() {
	echo -e "$bhash Checking ssh...\n"; datme; echo "checking ssh ports..." >> "$slog"
	ufw status | grep "22" | grep "ALLOW" >/dev/null ||	{
		dhclient && echo -e "$bhash resetting DHCP..."
		ufw enable &> "$slog"; wait
		ufw allow ssh &> "$slog"; wait
		ufw status | grep "22" | grep "ALLOW" >/dev/null || echo -e "$rhash $berr unable to start ssh\n" && return 2
		echo -e "$ghash SSH has been enabled!\n"
	}
	echo -e "$ghash enabled!\n"; return 69 # signal don't stop
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
	user.response 
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
user.response 

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
	user.response 
fi

# lets install cctv-viewer
snap="cctv-viewer"
snap.check
otherf

# now let's get our curl scripts, and install the software requiring them
curltarget="https://tailscale.com/install.sh"
curlname="Tailscale"
curl.install
otherf

curltarget="https://raw.githubusercontent.com/tylermatthew/cctv-memcheck/main/cvmc_install.sh"
curlname="cvmc_install.sh"
curl.install
otherf

hdrgre
echo -e "setup script complete!"
echo -e -n "\n$bhash Press ${cbol}Enter${cend} to run $curlname, or ${sita}any other key${cend} to stop\n\n" && read -n 1 -s -r -p ' ' key
if [[ "$key" = "" ]]; then
	echo -e "$ghash Starting cctv-memcheck..."
	/usr/local/bin/cctv-memcheck
	sleep 2
	pgrep cctv-m >/dev/null ||	{
		echo -e "$rhash $berr cctv-memcheck is not running! did the $curlname fail?"
	}
	echo -e "$curlname successfully started! Exiting..." && sleep 1; clear; echo -e "The cvmc-setup log is at $slog" && sleep 1
	rm cvmc_install.sh &> /dev/null
	exit 0
else
	echo -e "$ghash Exiting..." && sleep 1; clear; echo -e "The cvmc-setup log is at $slog" && sleep 1
	rm cvmc_install.sh &> /dev/null
	exit 0
fi
