#!/bin/bash

os=/etc/os-release 

# color codes
GREEN='\033[0;32m'

if grep -q "Fedora" $os
then

    update_output=$(sudo dnf update --exclude=kernel* -y 2>&1)
    upgrade_output=$(sudo dnf upgrade --exclude=kernel* -y 2>&1)

        if   echo "$update_output$upgrade_output" | grep -q "Nothing to do"
        then echo -e "${GREEN}The system is up to date excluding the kernel"

        else echo "$update_output"
             echo "$upgrade_output"
             echo -e "${GREEN}System update and upgrade completed excluding the kernel"

        fi

fi

