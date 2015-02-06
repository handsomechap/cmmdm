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

# 1 - create suspended domain page to redirect to, set your own if you want to
CMMDMDIR='/home/nginx/domains/cmmdm'
mkdir -p $CMMDMDIR/suspendedpage
touch $CMMDMDIR/suspendedpage/index.html
chown -R nginx $CMMDMDIR 

# 2 -add aliases for suspend/unsuspend domains
echo 'bash suspend.sh' >/usr/bin/cmmdmsuspend
echo 'bash unsuspend.sh' >/usr/bin/cmmdmunsuspend
