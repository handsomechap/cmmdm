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


#######################################################################
function funcheader {
# generate an initial screen and display main menu
clear

printf '            _____________________________________________________\n'
printf '           /  _________________________________________________  \\ \n'
printf '          |  |                                                 |  |\n'
printf '          |  | [root]# CentMinMod Domain Manager  V 1.0        |  |\n'
printf '          |  | [root]# Michael Atkinson AKA HandsomeChap       |  |\n'
printf '          |  | [root]# https://github.com/handsomechap/cmmdm/  |  |\n'
printf '          |  |       _____ ___  ______  ___________  ___       |  |\n'
printf '          |  |      /  __ \|  \/  ||  \/  |  _  \  \/  |       |  |\n'
printf '          |  |      | /  \/| .  . || .  . | | | | .  . |       |  |\n'
printf '          |  |      | |    | |\/| || |\/| | | | | |\/| |       |  |\n'
printf '          |  |      | \__/\| |  | || |  | | |/ /| |  | |       |  |\n'
printf '          |  |       \____/\_|  |_/\_|  |_/___/ \_|  |_/       |  |\n'
printf '          |  |_________________________________________________|  |\n'
printf '           \_____________________________________________________/\n'
printf '                   \_______________________________________/\n'
printf '                _______________________________________________\n'
printf '             _-|    .-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.  --- |-_\n'
printf '          _-|.-.-. .---.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.--.  .-.-.|-_\n'
printf '       _-|.-.-.-. .---.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-|__|. .-.-.-.|-_\n'
printf '    _-|.-.-.-.-. .-----.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-----. .-.-.-.-.|-_\n'
printf ' _-|.-.-.-.-.-. .---.-. .-----------------------------. .-.---. .---.-.-.-.|-_\n'
printf '|-----------------------------------------------------------------------------|\n'
printf '|---._.-----------------------------------------------------------------._.---|\n'

sleep 2
clear

printf '+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+\n'
printf '                    Welcome to CentMinMod Domain Manager.\n'
printf '+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+\n'
printf '                         Okay please choose an option:\n'
printf '+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+\n'
}
#######################################################################


#######################################################################
function funcdomainchoice {
# use this function for any domain choices
# Display the menu:
printf 'Please choose from the following. 0 to cancel & return to main menu.\n'
for i in "${!cdarray[@]}"; do
    printf '   %d %s\n' "$i" "${cdarray[i]}"
done
printf '\n'

# Now wait for user input
while true; do
    read -e -r -p 'Your choice: ' choice
    # Check that user's choice is a valid number
    if [[ $choice = +([[:digit:]]) ]]; then
        # Force the number to be interpreted in radix 10
        ((choice=10#$choice))
        # Check that choice is a valid choice
        ((choice<${#cdarray[@]})) && break
    fi
    printf 'Invalid choice, please choose again.\n'
done

# At this point, we are sure the variable choice contains
# a valid choice.
if ((choice==0)); then
    printf 'Going back to main menu.\n'
fi

}
####################################################################



####################################################################
function funcsuspenddomain {

# Display the menu:
printf 'Please choose from the following. 0 to cancel & return to main menu.\n'
for i in "${!cdarray[@]}"; do
    printf '   %d %s\n' "$i" "${cdarray[i]}"
done
printf '\n'

# Now wait for user input
while true; do
    read -e -r -p 'Your choice: ' choice
    # Check that user's choice is a valid number
    if [[ $choice = +([[:digit:]]) ]]; then
        # Force the number to be interpreted in radix 10
        ((choice=10#$choice))
        # Check that choice is a valid choice
        ((choice<${#cdarray[@]})) && break
    fi
    printf 'Invalid choice, please choose again.\n'
done

# At this point, we are sure the variable choice contains
# a valid choice.
if ((choice==0)); then
    printf 'Going back to main menu.\n'

else

    # test if domain.conf.suspended file does not already exist

    if [ ! -f /usr/local/nginx/conf/conf.d/${cdarray[$choice]}.conf.suspended ]; then
        printf "Testing, okay domain is not currently suspended,\n"

        # rename the .conf file .conf.suspended
        mv /usr/local/nginx/conf/conf.d/${cdarray[$choice]}.conf /usr/local/nginx/conf/conf.d/${cdarray[$choice]}.conf.suspended

        # make new .conf file which will redirect all pages to suspended index.html
        printf "server {\n server_name ${cdarray[choice]} www.${cdarray[choice]};\n root /home/nginx/domains/cmmdm/suspendedpage;\n location / {\n"  >> /usr/local/nginx/conf/conf.d/${cdarray[choice]}.conf
        printf 'try_files $uri $uri/ /index.html;\n }\n}'  >> /usr/local/nginx/conf/conf.d/${cdarray[choice]}.conf
        # restart nginx
        ngxrestart
        printf "The domain ${cdarray[choice]} has been suspended.\n"

        # but domain.conf.suspended file does already exist
    else printf "This domain is already suspended.\n"
    fi

fi
}


function funcunsuspenddomain {

# Display the menu:
printf 'Please choose from the following. 0 to cancel & return to main menu.\n'
for i in "${!cdarray[@]}"; do
    printf '   %d %s\n' "$i" "${cdarray[i]}"
done
printf '\n'

# Now wait for user input
while true; do
    read -e -r -p 'Your choice: ' choice
    # Check that user's choice is a valid number
    if [[ $choice = +([[:digit:]]) ]]; then
        # Force the number to be interpreted in radix 10
        ((choice=10#$choice))
        # Check that choice is a valid choice
        ((choice<${#cdarray[@]})) && break
    fi
    printf 'Invalid choice, please choose again.\n'
done

# At this point, we are sure the variable choice contains
# a valid choice.
if ((choice==0)); then
    printf 'Going back to main menu.\n'


else
    # test if domain.conf.suspended file does not already exist

    if [ ! -f /usr/local/nginx/conf/conf.d/${cdarray[$choice]}.conf.suspended ]; then
       # if it doesnt exist, domain not suspended, give user message
       printf "This domain is not currently suspended.\n"

    else
       # the domain is suspended, so remove the .conf file and rename .conf.suspended back to .conf
       rm /usr/local/nginx/conf/conf.d/${cdarray[$choice]}.conf
       mv /usr/local/nginx/conf/conf.d/${cdarray[$choice]}.conf.suspended /usr/local/nginx/conf/conf.d/${cdarray[$choice]}.conf
       # restart nginx
       ngxrestart
       printf "The domain ${cdarray[choice]} has been unsuspended.\n"

    fi

fi
}

#########################################################################

#########################################################################
function funcassociatedb {
# This function will associate a domain and a database together
                                                                                                                                               # Display the menu:
printf 'Please choose from the following. 0 to cancel & return to main menu.\n'
for i in "${!cdarray[@]}"; do
    printf '   %d %s\n' "$i" "${cdarray[i]}"
done
printf '\n'

# Now wait for user input
while true; do
    read -e -r -p 'Your choice: ' choice
    # Check that user's choice is a valid number
    if [[ $choice = +([[:digit:]]) ]]; then
        # Force the number to be interpreted in radix 10
        ((choice=10#$choice))
        # Check that choice is a valid choice
        ((choice<${#cdarray[@]})) && break
    fi
    printf 'Invalid choice, please choose again.\n'
done

# At this point, we are sure the variable choice contains
# a valid choice.
if ((choice==0)); then
    printf 'Going back to main menu.\n'

else
    # okay user chooses a domain, lets associate a database to a domain
    # first lets check if the domain currently has an association file, if not create one
    assocfile=/root/tools/cmmdm/cmmdmdbassoc/${cdarray[$choice]}
    if [ ! -f $assocfile ]; then
        touch $assocfile
fi

# next lets check if the domain already has any database associations listed
if [[ -s $assocfile ]] ; then
    printf "${cdarray[$choice]} already has the following databases associated to it:\n\n"
    cat $assocfile | while read assocline
    do
      printf "   MySQL Database: $assocline\n"
    done
    printf "\n"

else
    printf "${cdarray[$choice]} currently has no databases associated to it.\n"
fi

# okay now we can go ahead and attempt to associate a new database
# first lets read the existing databases into an array for manipulation
read -ra dbarray <<< $(mysql  -u root -p$mysqlpass -se "SHOW DATABASES")
# insert Cancel choice
dbarray=( Cancel "${dbarray[@]}" )

printf "Please choose from the following. 0 to cancel & return to main menu.\n"

for i in "${!dbarray[@]}"; do
    printf '   %d %s\n' "$i" "${dbarray[i]}"
done
printf '\n'

    # Now wait for user input
    while true; do
        read -e -r -p 'Your choice: ' choice
        # Check that user's choice is a valid number
        if [[ $choice = +([[:digit:]]) ]]; then
            # Force the number to be interpreted in radix 10
            ((choice=10#$choice))
            # Check that choice is a valid choice
            ((choice<${#dbarray[@]})) && break
        fi
        printf 'Invalid choice, please start again.\n'
    done

    if ((choice==0)); then
        printf 'Going back to main menu.\n'

    else
        # okay so we have chosen a database, lets do a couple of checks
        # firstly is it already associated with the domain
        if grep -Fxq "${dbarray[$choice]}" $assocfile
        then
        # code if found
        printf "Error: Unable to proceed, the database is already associated to this domain\n"
        else
        # code if not found
        # printf "okay lets proceed, its not already associated\n"
        printf "associating MySQL Database: ${dbarray[$choice]} to domain: ${cdarray[$choice]} \n"
        echo "${dbarray[$choice]}" >> $assocfile

        fi

    fi


fi



}
#########################################################################
