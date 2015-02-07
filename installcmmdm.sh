#!/bin/bash
##################################################
# cmmdm installer
# Michael Atkinson
# v. 0.1
##################################################
# https://github.com/handsomechap/cmmdm
# set of commandline tools to enable easier domain
# management within centminmod hosting environment
##################################################
# install:
# chmod +x installcmmdm.sh
# ./installcmmdm.sh
##################################################

##########################
# - welcome message
echo "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"
echo "starting cmmdm installation"
echo "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"
##########################

##########################
# - pull cmmdm.sh from github, if pull fails then error out
wget -cnv --no-check-certificate https://raw.githubusercontent.com/handsomechap/cmmdm/master/cmmdm.sh -q /root/tools/cmmdm.sh --tries=3
ERROR=$?
if [[ "$ERROR" != '0' ]]; then
echo "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"
echo "Error: cmmdm.sh download from github failed."
echo "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"
exit $ERROR
else
echo "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"
echo "Okay: cmmdm.sh download from github successful."
echo "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"
fi
# - modify script permissions to be runnable
chmod 0700 /root/tools/cmmdm.sh
mkdir /root/tools/cmmdm
##########################

##########################
# - create suspended domain page to redirect to, set your own if you want to
echo "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"
echo "Okay: Creating suspension page for redirects."
echo "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"
CMMDMDIR='/home/nginx/domains/cmmdm'
mkdir -p $CMMDMDIR/suspendedpage
touch $CMMDMDIR/suspendedpage/index.html
chown -R nginx $CMMDMDIR 
##########################

##########################
# - add alias for interacting with cmmdm
echo "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"
echo "Okay: Creating new command: cmmdm."
echo "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"
echo 'bash /root/tools/cmmdm.sh' >/usr/bin/cmmdm
chmod +x /usr/bin/cmmdm
##########################


##########################
# - script installation completed
echo "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"
echo "Okay: cmmdm.sh Installation Completed."
echo "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"
##########################
