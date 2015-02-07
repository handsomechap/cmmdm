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

# - welcome message
echo "starting cmmdm installation"

# - download cmmdm.sh
wget -cnv --no-check-certificate https://raw.github.com/cmmdm/cmmdm.sh -O /usr/bin/cmmdm --tries=3
ERROR=$?
if [[ "$ERROR" != '0' ]]; then
echo "Error: /usr/bin/wp download failed."
exit $ERROR
else
echo "Download done."
fi

# - create suspended domain page to redirect to, set your own if you want to
CMMDMDIR='/home/nginx/domains/cmmdm'
mkdir -p $CMMDMDIR/suspendedpage
touch $CMMDMDIR/suspendedpage/index.html
chown -R nginx $CMMDMDIR 

# - add alias for interacting with cmmdm
echo 'bash cmmdm.sh' >/usr/bin/cmmdm

