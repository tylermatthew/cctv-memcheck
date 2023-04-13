! /bin/bash
#
# script to get the machine up to standard with required apps and configs - assumed to be attended

# version 		0.1.1
# author		Tyler Johnson

# A little formatting fun

cend='\e[0m'        # end format
cbla='\e[30m'       # black
cred='\e[31m'       # red
cgre='\e[1;32m'     # green
cbro='\e[33m'       # brown
cblu='\e[34m'       # blue
cpur='\e[35m'       # purple
ccya='\e[36m'       # cyan
cgra='\e[37m'       # gray
sbol='\e[1m'        # bold
sita='\e[3m'        # italics
cyel='\e[1;33m'     # yellow
cwhi='\e[1;37m'     # white

header() {
    clear
    clear
    echo -e "${cblu}############################################################################${cend}\n"
}

# Put all of our functions in first, we may need them in some of the troubleshooting steps

# First, a call and response for the attending user
user_response() {
    echo -e -n "\n${cblu}#${cend} Press ${sbol}Enter${cend} to continue, or ${sita}any other key${cend} to stop\n\n" && read -n 1 -s -r -p ' ' key

    if [[ "$key" = "" ]]; then    
        echo -e "${cgre}#${cend} Continuing..." && sleep 1 && clear
    else    
        echo -e "${cgre}#${cend} stopping..." && sleep 1 && exit 1
    fi
}

# then to the installer functions
# we start with apt 
service="service"
service_check () {

	if [ -x "$(command -v $service)" ]; then
		echo -e "${cblu}#${cend} $service is installed, checking version...\n"; sleep 1
		installed_vnum=$(apt-cache policy $service | grep Installed | awk '{print $2}' | sed 's/[^0-9]*//g')
		candidate_vnum=$(apt-cache policy $service | grep Candidate | awk '{print $2}' | sed 's/[^0-9]*//g')
		installed_version=$(apt-cache policy $service | grep Installed | awk '{print $2}')
		candidate_version=$(apt-cache policy $service | grep Candidate | awk '{print $2}')
		if [ "$candidate_vnum" -gt "$installed_vnum" ]; then
			echo -e "${cblu}#${cend} Updating $service from $installed_version to $candidate_version\n"; sleep 1
			su -c "apt install --only-upgrade $service -y"			
			if [ $? -eq 0 ]; then
				echo -e "${cblu}#${cend} $service updated from $installed_version to $candidate_version \n"
			else
				echo -e "${cred}#${cend} Error: failed updating $service\n"
			fi
		else
			echo -e "${cblu}#${cend} $service is already installed and up to date!\n"
		fi
	else
		echo -e "${cblu}#${cend} $service is not installed, installing now...\n"
		su -c "apt install $service -y"
		if [ $? -eq 0 ]; then
			installed_version=$(apt-cache policy $service | grep Installed | awk '{print $2}')
			echo -e "${cblu}#${cend} $service $installed_version successfully installed\n"
		else
			echo -e "${cred}#${cend} Error: failed installing $service\n"
		fi
	fi

}

# now lets do the same for snap snaps
snap="snap"
snap_check () {

	if snap list | grep -q "^$snap"; then
		echo -e "${cblu}#${cend} $snap is installed, checking for updates\n"
		snap refresh "$snap"; echo -e "${cblu}#${cend} updating $snap\n"
		if [ $? -eq 0 ]; then
			echo -e "${cblu}#${cend} $snap updated successfully\n"
		else
			echo -e "${cblu}#${cend} $snap is already up to date\n"
		fi
	else
		echo -e "${cblu}#${cend} $snap is not installed\n"
		snap install "$snap"; echo -e "${cblu}#${cend} installing $snap\n"
		if [ $? -eq 0 ]; then
			echo -e "${cblu}#${cend} $snap installed successfully\n"
		else
			echo -e "${cred}#${cend} Error: failed installing $snap\n"
		fi
	fi

}


# and one for software we need to curl in
curl_target='curl_target'
curl_name='curl_name'
curl_install () {

	curl -fL "$curl_target" | sh -i;
	if [ $? -eq 0 ]; then
			echo -e "${cblu}#${cend} $curl_name successfully installed\n"
		else
			echo -e "${cred}#${cend} Error installing $curl_name\n"
	fi
	
}

# now for some troubleshooting before we start

# Check for root (SUDO).
if [[ "$EUID" -ne 0 ]]; then
  
	echo -e "The script need to be run as root...\n\nRun the command below to login as root\n${sbol}sudo -i${cend}\n"
 	exit 1
fi

# Check DNS

host -t srv _ldap._tcp.google.com | grep "has SRV record" >/dev/null ||     {
    echo -e "${cred}#${cend}${sbol}Error:${cend} DNS is broken.\n${sita}Allow the script to resolve?${cend}\n"
    user_response
    echo -e "${cblu}#${cend} adding cloudflare dns..."
    sed -i /127.0.0.53/a"nameserver 1.1.1.1" /etc/resolv.conf; sleep 1
    if [ $? -eq 0 ]; then
		echo -e "${cgreen}#${cend} $snap installed successfully\n"
	else
		echo -e "${cred}#${cend}${sbol} Error:${cend} DNS is still broken.\n${cred}#${cend}${sbol} ${sbol}This must be fixed for the script to work!${cend}"
		exit 1
	fi
	echo -e "${cblu}#${cend}Checking DNS again...\n"; sleep 1
	host -t srv _ldap._tcp.google.com | grep "has SRV record" >/dev/null ||     {
		echo -e "${cred}#${cend}${sbol} Error:${cend} DNS is still broken.\n${cred}#${cend}${sbol} ${sbol}This must be fixed for the script to work!${cend}"
		exit 1
	}
	echo -e "${cgre}#Success!${cend}"; sleep 1
}

# show a cute little header
script_logo() {
  cat << "EOF"
		
	This is the
	
	  \  |      |   |_)       |    		License: GNU General Public License v3.0
	   \ |  _ \ __| | | __ \  |  / 		Version: 0.1.0
	 |\  |  __/ |   | | |   |   <  		Author: Tyler Johnson
	_| \_|\___|\__|_|_|_|  _|_|\_\		only tested on Ubuntu 22.04
	cctv-viewer live view kiosk setup script
	Includes restart_cctv-viewer script to mitigate memory leak
 
EOF
}

header
script_logo

# Let the user back out if they didn't want to execute yet. 

echo -e -n "${cblu}#${cend} Press ${sbol}Enter${cend} to begin, or ${sita}any other key${cend} to go back\n\n" && read -n 1 -s -r key

if [[ "$key" = "" ]]; then    
    echo -e "${cgre}#${cend} Here we go!" && sleep 1 && clear
else    
    echo -e "${cgre}#${cend} Going back..." && sleep 1 && exit 0
fi


# Now, lets start installing the software. 
# curl
service="curl"
service_check & echo -e "${cblu}#${cend} checking on ${service}...\n"; wait
user_response

sleep 1 && clear

# htop
service="htop"
service_check & echo -e "${cblu}#${cend} checking on ${service}...\n"; wait
user_response

sleep 1 && clear

# nano
service="nano"
service_check & echo -e "${cblu}#${cend} checking on ${service}...\n"; wait
user_response

sleep 1 && clear

# openssh-server
service="openssh-server"
service_check & echo -e "${cblu}#${cend} checking on ${service}...\n"; wait
user_response

sleep 1 && clear

# open the ssh port
echo -e "${cblu}#${cend} Checking the ssh port...\n"
if [ lsof -i -P -n | grep ssh | grep LISTEN >/dev/null ]; then
	echo -e "${cgre}#${cend} already enabled!\n"
else
	ufw allow ssh; lsof -i -P -n | grep ssh | grep LISTEN >/dev/null || echo -e "${cred}#${cend} Error: unable to start ssh\n" 
	echo -e "${cgre}#${cend} has been enabled!\n"
fi	

user_response

sleep 1 && clear
	
# lets install cctv-viewer
snap="cctv-viewer"
snap_check & echo -e "${cblu}#${cend} Now installing ${snap}...\n"; wait
user_response

sleep 1 && clear

# now let's get our curl scripts, and install the software requiring them
curl_target="https://tailscale.com/install.sh"
curl_name="Tailscale"
curl_install & echo -e "${cblu}#${cend} Installing Tailscale...\n"; wait

user_response

sleep 1 && clear

curl_target="https://raw.githubusercontent.com/tylermatthew/cctv-viewer-memleak-fix/main/rcv_install.sh"
curl_name="rcv install script"
curl_install & echo -e "${cblu}#${cend} Installing and running the rcv script\n${cblu}#${cend} to keep cctv-viewer running...\n"; wait
user_response

if [ pidof restart_cctv-viewer.sh >/dev/null ||	{
	echo -e "${cred}#${cend} Error: rcv is not running! did the $curl_name fail?"

sleep 1 && clear

echo -e "setup script complete!\n\nPress any key to exit" && read -n 1 -s -r

exit 0
