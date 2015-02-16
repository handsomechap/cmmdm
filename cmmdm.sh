#!/bin/bash
#######################################################################
# CMMDM main script
# Michael Atkinson
# v. 1.0
#######################################################################
# https://github.com/handsomechap/cmmdm
# commandline tool to enable easier domain
# management within centminmod hosting environment
#######################################################################


#######################################################################
# set extended globs
shopt -s extglob nullglob
#######################################################################


#######################################################################
# set the date timestamp for backups
now=$(date +"%m_%d_%Y")
#######################################################################


#######################################################################
# attempt to retrieve root mysql password
#grep -h "MySQL root password" /root/centminlogs/centminmod_1.2.3-eva2000*install.log |
#while read mysqlpass ; do
#mysqlpass="${mysqlpass//MySQL root password: }"
#printf "$mysqlpass\n"
mysqlpass=
#done
#######################################################################


#######################################################################
# set the location of the domains
basedir=/home/nginx/domains

# if you want to leave out any domains
# the syntax is omitdir="cmmdm|not_this_+([[:digit:]])|ignore*"
# If you don't want to omit any domains, leave it as it is:
omitdir=cmmdm
#######################################################################


#######################################################################
# Create domain array
if [[ -z $omitdir ]]; then
   cdarray=( "$basedir"/*/ )
else
   cdarray=( "$basedir"/!($omitdir)/ )
fi
# remove leading basedir:
cdarray=( "${cdarray[@]#"$basedir/"}" )
# remove trailing backslash and insert Cancel choice
cdarray=( Cancel "${cdarray[@]%/}" )

# You should check that you have at least one domain in there:
if ((${#cdarray[@]}<=1)); then
    printf 'No domains found, exiting CMMDM.\n'
    exit 0
fi
#######################################################################


#######################################################################
# generate main menu
mmarray[0]='Exit'
mmarray[1]='Suspend A Domain'
mmarray[2]='Unsuspend A Domain'
mmarray[3]='Associate Database To Domain'
mmarray[4]='Disassociate Database From Domain'
mmarray[5]='View Current Database -> Domain Associations'
mmarray[6]='Delete Domain - WARNING BE SURE BEFORE USING THIS FUNCTION'
mmarray[7]='Backup Domain (Plus Any Associated Databases)'
mmarray[8]='Restore Domain From Backup File'
mmarray[9]='Show MySQL Databases & Users'
mmarray[10]='Random Einstein Quote'
#######################################################################


#######################################################################
# set quotes file
quotefile=/root/tools/cmmdm/quotes
# read quotes into array
readarray -t quotearray < $quotefile
#######################################################################
