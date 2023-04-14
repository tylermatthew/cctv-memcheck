# cctv-memcheck
# A simple bash script to keep cctv-viewer running and displaying full screen
#
# Author: Tyler Johnson

# DEV BRANCH GOALS

# primary goal : maximize time displaying cameras on screen. 

# Refine setup; depricate rcv_install
# - enhance portability to all snap capable systems, because cctv-viewer is a snap package
# - refine, clean, simplify, and otherwise improve codebase
# - impliment standard output and error logging; eg. tailscale link extraction, etc.
# - eliminate rcv-install / merge features for single setup/install file. 
# - consider config file for rtsp targets, memory threshold settings, and other situation specific variables.
# - remove uneeded steps

# refine cctv-memcheck ; former restart_cctv-viewer
# - enhance portability to all snap capable systems, because cctv-viewer is a snap package
# - refine, clean, simplify, and otherwise improve codebase
# - generally improve logging
# - log delivery system
# - cron checks for cctv-viewer and cctv-memcheck; recognizing an infinite loop of scripts checking on scripts is not a graceful solution...
# - explore possibility of graceful memory cleaning ; long shot

# moving from DEV to PROD
# - ENSURE YOU ARE USING THE READY VERSION
# - ctl+f "dev" to find development branch raw urls, replace with PROD urls
# - Remove DEV headers
# - ctl+f "dev" and remove any misc labels
# - ARE YOU SURE THIS VERSION IS READY??
# - push it babyyy

