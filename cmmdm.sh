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
#done
mysqlpass=
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
####################################################################


####################################################################

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


#########################################################################
function funcdisassociatedb {
# This function will disassociate a database from a domain

# first lets choose a domain
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
    # okay first lets check if the domain currently has an association file, if not create one
    assocfile=/root/tools/cmmdm/cmmdmdbassoc/${cdarray[$choice]}
    if [ ! -f $assocfile ]; then
        touch $assocfile
    fi
    # okay now lets check if any databases are currently associated to the domain
    if [[ -s $assocfile ]] ; then
        # if there are some associations generate a menu to remove one

        # Load file into array.
        readarray -t dbinarray < $assocfile

        # insert Cancel choice
        dbinarray=( Cancel "${dbinarray[@]}" )

        for i in "${!dbinarray[@]}"; do
          printf '   %d %s\n' "$i" "${dbinarray[i]}"
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
              ((choice<${#dbinarray[@]})) && break
          fi
          printf 'Invalid choice, please start again.\n'
        done

        if ((choice==0)); then
          printf 'Going back to main menu.\n'

        else
           # remove the database line from the associations file
           # printf "here is where we will actually remove the database from the association file.\n"
           printf "Disassociating database ${dbinarray[$choice]} from domain ${cdarray[$choice]}.\n"
           sed -n "/${dbinarray[$choice]}/!p" $assocfile > tempfile; mv tempfile $assocfile
        fi



    else
        printf "Error: ${cdarray[$choice]} currently has no databases associated to it.\n"
    fi

fi

}
#########################################################################


#########################################################################
function funcviewassociations {
# okay lets view all the current database to domain associations

# use an array of all current domains

# Create domain array
if [[ -z $omitdir ]]; then
   cdassocarray=( "$basedir"/*/ )
else
   cdassocarray=( "$basedir"/!($omitdir)/ )
fi
# remove leading basedir:
cdassocarray=( "${cdassocarray[@]#"$basedir/"}" )
cdassocarray=( "${cdassocarray[@]%"/"}" )


# You should check that you have at least one domain in there:
if ((${#cdassocarray[@]}<=1)); then
    printf 'ERROR: No domains found.\n'
fi

# for each domain first print the domain name then print the assocation file for each domain

for i in "${!cdassocarray[@]}"; do
    printf "${cdassocarray[i]}\n"

    assocfile=/root/tools/cmmdm/cmmdmdbassoc/${cdassocarray[i]}
    if [ ! -f $assocfile ]; then
        touch $assocfile
    fi
    # next lets check if the domain already has any database associations listed
    if [[ -s $assocfile ]] ; then
 #       printf "${cdarray[$choice]} already has the following databases associated to it:\n\n"
        cat $assocfile | while read assocline
        do
          printf "   MySQL Database: $assocline\n"
        done
#        printf "\n"

    else
        printf "    currently has no databases associated to it.\n"
    fi

done
printf '\n'


}
#########################################################################


#########################################################################
function funcdeletedomain {
# printf "This function will delete a domain"

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
    # okay user chooses a domain, lets check they really do want to delete the domain
    printf "WARNING deletion is irreversible, check you need/have a backup!!\n\n"
    printf "   0 Cancel \n\n"
    printf "   1 Yes I really do want to delete ${cdarray[choice]} \n\n"
    printf "   2 Wait cancel, I dont want to delete ${cdarray[choice]} \n"
    printf "   3 Wait cancel, I dont want to delete ${cdarray[choice]} \n"
    printf "   4 Wait cancel, I dont want to delete ${cdarray[choice]} \n"
    printf "   5 Wait cancel, I dont want to delete ${cdarray[choice]} \n"
    printf "   6 Wait cancel, I dont want to delete ${cdarray[choice]} \n"
    printf "   7 Wait cancel, I dont want to delete ${cdarray[choice]} \n"
    printf "   8 Wait cancel, I dont want to delete ${cdarray[choice]} \n"
    printf "   9 Wait cancel, I dont want to delete ${cdarray[choice]} \n\n"


    # Now wait for user input
    while true; do
       read -e -r -p 'Your choice: ' deletechoice
        # Check that user's choice is a valid number
        if [[ $deletechoice = +([[:digit:]]) ]]; then
            # Force the number to be interpreted in radix 10
            ((deletechoice=10#$deletechoice))
            # Check that choice is a valid choice
            ((deletechoice<10)) && break
        fi
        printf 'Invalid choice, please choose again.\n'
    done

    # At this point, we are sure the variable choice contains
    # a valid choice.
    if ((deletechoice==1)); then
        # so user really wants to delete domain, lets do it
        printf "Okay, confirmed! Deleting domain.\n"
        # delete the domains conf file
        printf "Removing /usr/local/nginx/conf/conf.d/${cdarray[choice]} \n"
        rm -f /usr/local/nginx/conf/conf.d/${cdarray[choice]}
        printf "Removing /usr/local/nginx/conf/conf.d/${cdarray[choice]}.suspended \n"
        rm -f /usr/local/nginx/conf/conf.d/${cdarray[choice]}.suspended
        # delete the domain folder
        printf "Removing /home/nginx/domains/${cdarray[choice]} \n"
        rm -rf /home/nginx/domains/${cdarray[choice]}
        # remove the domains cmmdm database association file
        printf "Removing /root/tools/cmmdm/cmmdmdbassoc/${cdarray[choice]} \n"
        rm -f /root/tools/cmmdm/cmmdmdbassoc/${cdarray[choice]}

        # restart nginx
        ngxrestart

    else
        # sanity check, the user doesnt want to delete domain
        printf "Cancelled, going back to main menu.\n"
    fi

fi


}
#########################################################################


#########################################################################
function funcbackupdomain {
# This function will backup a domain and any associated databases

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
    # okay user chooses a domain, lets backup the domain
    # first make a temporary folder
    # mkdir /root/tools/cmmdm/cmmdmbackup/${cdarray[$choice]}

    # if its not suspended copy the domain and the conf file into temp folder
    # else if it is suspended take the .suspended conf file instead
    if [ ! -f /usr/local/nginx/conf/conf.d/${cdarray[$choice]}.conf.suspended ]; then
        cp /usr/local/nginx/conf/conf.d/${cdarray[$choice]}.conf /root/tools/cmmdm/cmmdmbackup/${cdarray[$choice]}.conf
    else
        cp /usr/local/nginx/conf/conf.d/${cdarray[$choice]}.conf.suspended /root/tools/cmmdm/cmmdmbackup/${cdarray[$choice]}.conf

    fi
    printf 'Copying configuration file\n'

    # next copy the domain folder
    cp -r /home/nginx/domains/${cdarray[$choice]} /root/tools/cmmdm/cmmdmbackup/
    printf 'Copying domain folder\n'

    # next extract and zip any associated mysql databases
    assocfile=/root/tools/cmmdm/cmmdmdbassoc/${cdarray[$choice]}
    if [ ! -f $assocfile ]; then
        touch $assocfile
    fi
    # okay now lets check if any databases are currently associated to the domain
    if [[ -s $assocfile ]] ; then
        # Load file into array.
        readarray -t dbinarray < $assocfile
        let i=0
        while (( ${#dbinarray[@]} > i )); do
#            printf "including associated MySQL Database: ${dbinarray[i++]}\n"
            mysqldump -u root -p$mysqlpass ${dbinarray[i]} | gzip -9 > ${dbinarray[i]}.sql.gz
            mv ${dbinarray[i]}.sql.gz /root/tools/cmmdm/cmmdmbackup/
            printf "including associated MySQL Database: ${dbinarray[i++]}\n"

        done
    else
        printf "No databases associated with domain, skipping MySQL Backups.\n"
    fi


    # next tar the folder and remove the temporary files
    tar -zcf /root/tools/cmmdm/cmmdm_backup_${cdarray[$choice]}_$now.tar.gz /root/tools/cmmdm/cmmdmbackup/
    printf "tar.gz conf file and domain folder\n"
    printf "backup successful\n"
    mv /root/tools/cmmdm/cmmdm_backup_${cdarray[$choice]}_$now.tar.gz /root/tools/cmmdm/completedbackups/
    printf "backup located: /root/tools/cmmdm/completedbackups/cmmdm_backup_${cdarray[$choice]}_$now.tar.gz\n"

    # finally lets remove the temporary files
    rm -f /root/tools/cmmdm/cmmdmbackup/${cdarray[$choice]}.conf
    rm -rf /root/tools/cmmdm/cmmdmbackup/${cdarray[$choice]}/
    rm -f /root/tools/cmmdm/cmmdmbackup/*.sql.gz

fi


}
#########################################################################


#########################################################################
function funcrestoredomain {
# This function will restore a domain and any associated databases from a backup file



# create an array with all the file inside backup folder
bubasedir=/root/tools/cmmdm/completedbackups
buarray=($bubasedir/*)

# remove leading bubasedir:
buarray=( "${buarray[@]#"$bubasedir/cmmdm_backup_"}" )
# buarray=( "${buarray[@]%%_*}" )
# insert Cancel choice
buarray=( Cancel "${buarray[@]%}" )

# You should check that you have at least one backup in there:
if ((${#buarray[@]}<=1)); then
    printf 'No backups found, exiting CMMDM.\n'
    exit 0
fi



# Display the menu:
printf 'Please choose from the following. 0 to cancel & return to main menu.\n'
for i in "${!buarray[@]}"; do
    printf '   %d %s\n' "$i" "${buarray[i]}"
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
        ((choice<${#buarray[@]})) && break
    fi
    printf 'Invalid choice, please choose again.\n'
done

# At this point, we are sure the variable choice contains
# a valid choice.
if ((choice==0)); then
    printf 'Going back to main menu.\n'

else
    # before we can proceed, check if domain already exists on server
    # we want to see if either conf file or domain folder already exist
    buarraytest=( "${buarray[choice]%%_*}" )
    printf "okay lets attempt to restore the domain $buarraytest\n\n"

    if [ ! -f /usr/local/nginx/conf/conf.d/$buarraytest.conf ]; then
        # okay the conf file doesnt exist, lets continue
        printf "Okay no current conf file found.\n"

        if [ ! -f /home/nginx/domains/$buarraytest/ ]; then
             # okay the domain folder doesnt exist either
             printf "Okay no current domain folder found.\n"
             # okay so domain really doesnt currently exist,
             # first clear any previous aborted backups
             rm -rf /root/tools/cmmdm/completedbackups/root/
             # okay lets get started extracting
             printf "Unzipping file: cmmdm_backup_${buarray[choice]} \n"
             tar -zxf $bubasedir/cmmdm_backup_${buarray[choice]} -C /root/tools/cmmdm
             # first move the conf file
             printf "Moving conf file \n"
             mv /root/tools/cmmdm/root/tools/cmmdm/cmmdmbackup/$buarraytest.conf /usr/local/nginx/conf/conf.d/
             chown nginx /usr/local/nginx/conf/conf.d/$buarraytest.conf
             chgrp nginx /usr/local/nginx/conf/conf.d/$buarraytest.conf
             # next move the domain folder
             printf "Moving domain folder \n"
             mv /root/tools/cmmdm/root/tools/cmmdm/cmmdmbackup/$buarraytest/ /home/nginx/domains/
             chown -R nginx /home/nginx/domains/$buarraytest
             chgrp -R nginx /home/nginx/domains/$buarraytest

             # next check if any sql files exist

             # create an array with all the file inside backup folder
             budbbasedir=/root/tools/cmmdm/root/tools/cmmdm/cmmdmbackup/
             # printf "$budbbasedir\n"
             budbarray=( "$budbbasedir"/* )

             # remove leading bubasedir:
             budbarray=( "${budbarray[@]#"$budbbasedir/"}" )
             # remove trailing .sql.gz
             budbarray=( "${budbarray[@]%".sql.gz"}" )


             # You should check that you have at least one database in there:
             if ((${#budbarray[@]}<=1)); then
                 printf 'No database backups found\n'

             else
                 # Display the menu:
                 printf "Okay Databases found, attempting to restore them:\n\n"
                 for i in "${!budbarray[@]}"; do
                     printf "   ${budbarray[i]}\n"
                     # test if mysql already exists
                     dbrestoreresult=$(mysql -s -N -e "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='${budbarray[i]}'");

                     if [ -z "$dbrestoreresult" ]; then
                     printf "   Okay db does not exist, restoring it now.\n\n"

                     gunzip < [$budbbasedir${budbarray[i]}.sql.gz] | mysql -u root -p$mysqlpass ${budbarray[i]}

                     else
                     printf "   ERROR: database already exists, unable to restore.\n\n"
                     fi



                 done
                 printf '\n'

             fi

             # finished restoring domain, restart nginx
             ngxrestart

             # remove temporarily extracted backup files
             rm -rf /root/tools/cmmdm/root/

        else
            printf 'ERROR: The domain cannot be restored, the domain folder already exists.\n'
        fi

    else
        printf 'ERROR: The domain cannot be restored, the conf file already exists.\n'
    fi

fi



}
#########################################################################



#########################################################################
function funcshowmysql {
mysql --user root --password=$mysqlpass --exec="SHOW DATABASES"
mysql --user root --password=$mysqlpass --exec="SELECT User,host FROM mysql.user"
}
#########################################################################


#########################################################################
function funceinsteinquote {
# using total quotes imported as upper bound of quote file
# randomly chose a quote to print


rnum=$(( RANDOM % ${#quotearray[@]}  ))
printf "\n  ${quotearray[$rnum]}\n   - Albert Einstein\n\n"

}

#########################################################################


#########################################################################
#########################################################################
# here is the start of the program itself

funcheader

while true; do

for i in "${!mmarray[@]}"; do
    printf '   %d %s\n' "$i" "${mmarray[i]}"
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
        ((choice<${#mmarray[@]})) && break
    fi
    printf 'Invalid choice, please start again.\n'
done


# At this point, we are sure the variable choice contains
# a valid choice.
if ((choice==0)); then
    printf 'Exiting CMMDM. Good Bye.\n'
    exit 0

elif  ((choice==1)); then
    printf 'Choose a domain to suspend.\n'
    funcsuspenddomain

elif  ((choice==2)); then
    printf 'Choose a domain to unsuspend.\n'
    funcunsuspenddomain

elif  ((choice==3)); then
    printf 'Choose a domain to associate a database to.\n'
    funcassociatedb


elif  ((choice==4)); then
    printf 'Choose a domain to disassociate a database from.\n'
    funcdisassociatedb

elif  ((choice==5)); then
    printf 'These are your current domain -> database associations.\n'
    funcviewassociations


elif  ((choice==6)); then
    printf 'Choose a domain to delete WARNING IRREVERSIBLE.\n'
    funcdeletedomain


elif  ((choice==7)); then
    printf 'Choose a domain to backup.\n'
    funcbackupdomain


elif  ((choice==8)); then
    printf 'Choose a domain to restore.\n'
    funcrestoredomain


elif  ((choice==9)); then
    printf 'These are your current databases and database users.\n'
    funcshowmysql

elif  ((choice==10)); then
    printf 'Heres a random insightful quote from the man himself.\n'
    funceinsteinquote

fi

done

# end of main program
#######################################################################
#######################################################################
# end of file, in the immortal words of bugs bunny, That's All Folks!
