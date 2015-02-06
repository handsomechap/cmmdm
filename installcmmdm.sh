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

# 1 - create suspended domain page to redirect to

SUSPDIR='/home/nginx/domains/suspendedpage'

# add aliases for suspend/unsuspend domains

