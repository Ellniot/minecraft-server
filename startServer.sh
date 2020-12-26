#!/bin/bash

# set the file variables
currentIPFile="./currentIP.txt"
lastIPFile="./lastIP.txt"
lastIP=$(head -n 1 "$lastIPFile")
serverOwnersEmail="./emailAddresses.txt"


# TODO - Make this email all emails on the list
# TODO - pull all email functionality into a separate utility
firstEmail=$(sed -n '1,1p' "${serverOwnersEmail}")


# grab the current ip address
currentIP=$(dig @resolver4.opendns.com myip.opendns.com +short)
#echo "Current IP = ${currentIP}"
# output it to a file to make comparison easier
echo "$currentIP" > "$currentIPFile"


# compare the two ip addresses
if cmp -s "$currentIPFile" "$lastIPFile"; then
    # no alert, files (ip addresses) are the same
    #printf 'The current ip: "%s" == the last ip: "%s"\n' "$currentIP" "$lastIP"
    # no need to update the lastIP file

else
    # files (ip addresses) are different
    #printf 'The current ip of: "%s" is different from the last ip: "%s"\n' "$currentIP" "$lastIP"

    # update the lastIP file
    echo "$currentIP" > "$lastIPFile"

    # send an email to alert server owner's email
    message="New IP address: $currentIP"
    echo "$message"  | mutt -s "IP CHANGE" "$firstEmail"
fi


# start the server w/ file log output
java -Xmx10G -Xms2G -jar /opt/minecraft/CovidCraft/server.jar --nogui &
