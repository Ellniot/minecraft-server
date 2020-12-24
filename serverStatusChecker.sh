#!/bin/bash

#####################################
#                                   #
#   This is a cron job script to    #
#   check the state of the mc       #
#   server. Edit the cron job with  #
#   $ crontab -e                    #
#                                   #
#####################################

MAX_BOOT_LOOP=10

# files
bootLoopCounterFile="./bootLoopCounter.txt"
bootLoopCounter=$(<"$bootLoopCounterFile")
serverOwnersEmail="./emailAddresses.txt"

echo "Boot counter = $bootLoopCounter"

# Check if the server has tried to boot > or == the max number of times
if [ "$bootLoopCounter" -ge "$MAX_BOOT_LOOP" ]; then

    echo "Boot counter hit max"

    # email the server admin
    message="Server boot count hit max boot count of $bootLoopCounter"
    echo "$message"  | mutt -s "MAX BOOT COUNT" "$serverOwnersEmail"

    # TODO - MAKE THE SCRIPT NO LONGER CALLABLE?
        # or maybe add a different counter to just send no more emails

    # exit the script
    exit -1
fi;

# check if there is a CovidCraft java process running
taskList=$(ps -fea | grep -i "/opt/minecraft/CovidCraft/server.jar --nogui")
# then turn it into a count
processCount=$(wc -l <<< "${taskList}")


## If the sever is not running...
if [ "${processCount}" < 2 ]; then

    echo "Server is not running"

    # add count to boot loop counter
        # echo "${bootLoopCounterFile}" == ./bootLoopCouter.txt
        # echo "${bootLoopCounter}" == 0 (contents of ^^^)
    bootLoopCounter=$((bootLoopCounter+1))
    echo $bootLoopCounter > $bootLoopCounterFile

    # email the admin that the server was down & is being relaunched
    echo "There were less than 2 /opt/minecraft/CovidCraft/server.jar --nogui processes running";
    message="Rebooting server - these were the running processes: ${taskList}"
    echo "$message"  | mutt -s "SERVER DOWN" "$serverOwnersEmail"

    # call start server script
    sh ./startServer.sh




# TODO - REMOVE THIS WHOLE ELIF BLOCK
### Java prevents this so this is not possible

## elif there are multiple instances are running...
elif [ "${processCount}" > 2 ]; then

    echo "Multiple instances running"

    # add count to boot loop counter
    bootLoopCounter=$((bootLoopCounter+1))
    echo $bootLoopCounter > $bootLoopCounterFile

    # email the admin that there were > 1 instances of the server
    echo "There were more than 2 /opt/minecraft/CovidCraft/server.jar --nogui processes running";
    message="Rebooting server - these were the running processes: ${taskList}"
    echo "$message"  | mutt -s "SERVER DOWN+" "$serverOwnersEmail"

    # call shutdown server script
    sh ./stopServer.sh
    # NOT calling startserver, that will be handled the next time this script is called

# else it is running
else
    echo "server is running, doing nothing"
    # reset the boot loop counter
    echo "0" > $bootLoopCounterFile

fi;
