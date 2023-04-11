#! /bin/bash
#
# script to get the machine up to standard with required apps and configs

# version 		0.1.0
# author		Tyler Johnson

# check for root

# Check for root (SUDO).
if [[ "$EUID" -ne 0 ]]; then
  
	echo -e "The script need to be run as root...\\n\\n"
	echo -e "Run the command below to login as root"
	echo -e "sudo -i\\n"
	exit 1
fi

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

script_logo

read -n 1 -s -r -p "Press any key to continue"

# First let's get some basic apps using a function we can re-call with new variables
service="service"

service_check () {

	if [ -x "$(command -v $service)" ]; then
		echo "$service is installed, checking version"
		installed_version=$(apt-cache policy $service | grep Installed | awk '{print $2}')
		candidate_version=$(apt-cache policy $service | grep Candidate | awk '{print $2}')
		if [ "$candidate_version" -gt "$installed_version" ]; then
			echo "Updating $service from $installed_version to $candidate_version"
			apt-get install --only-upgrade $service -y; echo "installing $service"
			
			if [ $? -eq 0 ]; then
				echo "$service updated from $installed_version to $candidate_version"
			else
				echo "Error updating $service"
			fi
		else
			echo "$service is already installed and up to date!"
		fi
	else
		echo "$service is not installed"
		apt-get install $service -y; echo "installing $service"
		if [ $? -eq 0 ]; then
			installed_version=$(apt-cache policy $service | grep Installed | awk '{print $2}')
			echo "$service $installed_version successfully installed"
		else
			echo "Error installing $service"
		fi
	fi

}

# now lets do the same for snap snaps
snap="snap"

snap_check () {

	if snap list | grep -q "^$snap"; then
		echo "$snap is installed, checking for updates"
		snap refresh "$snap"; echo "updating $snap"
		if [ $? -eq 0 ]; then
			echo "$snap updated successfully"
		else
			echo "$snap is already up to date"
		fi
	else
		echo "$snap is not installed"
		snap install "$snap"; echo "installing $snap"
		if [ $? -eq 0 ]; then
			echo "$snap installed successfully"
		else
			echo "Error installing $snap"
		fi
	fi

}

# htop
service="htop"
service_check

# nano
service="nano"
service_check

# curl
service="curl"
service_check

# openssh-server
service="openssh-server"
service_check

# open the ssh port
ufw allow ssh

# lets install cctv-viewer
snap="cctv-viewer"
snap_check

# Lets get this machine on tailscale to guarantee access
get_tailscale () {
	curl -fsSL https://tailscale.com/install.sh | sh
	if [ $? -eq 0 ]; then
			echo "tailscale successfully installed"
		else
			echo "Error installing tailscale"
	fi
	
}

get_tailscale

# Now, lets install restart_cctv-viewer.show

rcv_install () {
	curl -fL https://raw.githubusercontent.com/tylermatthew/cctv-viewer-memleak-fix/main/rcv_install.sh | sh
	if [ $? -eq 0 ]; then
			echo "rcv install script successfully installed"
		else
			echo "Error installing rcv install script"
	fi
	
}

rcv_install

echo 'Everything should be done!'
read -n 1 -s -r -p "Press any key to exit"
exit 0
