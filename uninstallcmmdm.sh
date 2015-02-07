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
rmdir -rf /root/tools/cmmdm
rm -f /root/tools/cmmdm.sh
rm -f /usr/bin/cmmdm
##########################

##########################
# - script installation completed
echo "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"
echo "Okay: cmmdm.sh Installation Completed."
echo "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"
##########################
