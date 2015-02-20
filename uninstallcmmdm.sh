#!/bin/bash
##################################################
# cmmdm uninstaller
# Michael Atkinson
# v. 0.1
##################################################
# https://github.com/handsomechap/cmmdm
# set of commandline tools to enable easier domain
# management within centminmod hosting environment
##################################################

##########################
echo "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"
echo "performing uninstall routine now"
echo "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"
##########################
# first unsuspend all domains
echo "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"
echo "Unsuspending all domains"
echo "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"
# restart nginx
ngxrestart
##########################

##########################
echo "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"
echo "Removing all CMMDM files and folders"
echo "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"

# remove the domain folder for the suspended page
rm -rf /home/nginx/domains/cmmdm/

# remove the cmmdm tools folder
rm -rf /root/tools/cmmdm/


rm -f /root/tools/cmmdm.sh

# remove the cmmdm bind
rm -f /usr/bin/cmmdm
##########################

##########################
# - script installation completed
echo "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"
echo "Okay: CMMDM Removal Completed."
echo "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"
##########################
