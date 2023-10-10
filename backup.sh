#!/bin/bash

# Default values:
destination_path=/home/valentin/backups/

# Color codes:
RED='\e[31m'
GREEN='\e[32m'
CYAN='\e[36m'
RESET='\e[0m'
MAGENTA='\e[35m'
WHITE='\e[37m'

enter_source() {
    # Get the current directory
    current=$(pwd)

    while true; do
        # Prompt the user to enter the source directory
        echo -e "${MAGENTA}Press >> ENTER << for the current directory or type >> quit << to exit ${RESET}"
        read -p "Enter the path for the directory you wish to make a backup: " source


        # If no source is provided, use the current directory 
        if [ -z "$source" ]; then           
            source="$current"
        fi

        # If "quit" is entered, exit the script
        if [ "$source" = "quit" ]; then
            echo ""
            echo -e "${RED}Exiting...${RESET}"
            echo ""
            exit 1
        fi

        # If the source directory exists, break the loop and continue
        if [ -d "$source" ]; then
            echo ""
            echo -e "\n✅ ${GREEN}The directory exists. Continuing...${RESET}"
            echo ""
            echo __________________________________________________________
            echo ""
            break

        # If the source directory does not exist, display an error message and prompt again 
        else
            echo ""        
            echo -e "\n❌ ${RED}The directory does not exist. Please try again.${RESET}"
            echo ""
        fi

    done
}

select_destination() {
    
    # Prompt the user to select the destination path for the backup
    while true; do
    
        echo -e "${MAGENTA}Select the destination path for the backup:${RESET}"
        echo ""
        echo -e "1. ${WHITE}${destination_path}files${RESET}"
        echo -e "2. ${WHITE}${destination_path}scripts${RESET}"
        echo -e "3. ${WHITE}${destination_path}big_backups${RESET}"
        echo -e "4. ${WHITE}Or create a new folder inside: ${destination_path}${RESET}"
        echo -e "5. ${WHITE}Quit${RESET}"
        echo ""

        read -p "$(echo -e "${MAGENTA}Enter your choice: ${RESET}")" choice

        case $choice in
            1)
                destination="${destination_path}files"
                break
                ;;
            2)
                destination="${destination_path}scripts"
                break
                ;;
            3)
                destination="${destination_path}big_backups"
                break
                ;;
            4)
                echo ""
                read -p "$(echo -e "${MAGENTA}Enter the name of the new folder: ${RESET}")" folder_name
                destination="${destination_path}$folder_name"
                mkdir -p "$destination"
                break
                ;;
            5)
                # If "Quit" is selected, exit the script
                echo -e "${RED}Exiting...${RESET}"
                echo ""
                exit 0
                ;;
            *)
                # If an invalid choice is entered, display an error message and prompt again
                echo ""
                echo -e "\n❌ ${RED}Invalid choice. Please try again.${RESET}"
                echo ""
                ;;
        esac
    done

    echo ""
    echo -e "\n✅ You selected:${GREEN} $destination${RESET}"
    echo ""
    echo __________________________________________________________
    echo ""
}

create_backup() {
    
    # Prompt the user to enter the name for the backup
    read -p "$(echo -e "${MAGENTA}Enter the name for the backup: ${RESET}")" backup_name
    
    # Modify the backup name to include the current date
    backup_name="$(date +%Y-%m-%d)-${backup_name}"
    echo ""

    # Create a tar archive of the source directory and pipe it to gzip for compression
    tar -cz -C "${source}" . | pv -petrbc > "${destination}/${backup_name}.tar.gz"

    # Check if the tar compression was successful
    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${source} ${GREEN}has been successfully compressed and saved to${RESET} ${destination}!"
        echo ""
    else
        echo "\n❌ ${RED}Tar compression failed.${RESET}"
    fi
}


while true; do
    enter_source
    select_destination
    create_backup

    while true; do
        # Prompt the user to make another backup
        read -p "$(echo -e "${MAGENTA}Do you want to make another backup? (1: Yes, 2: No): ${RESET}")" choice
        echo ""

        case $choice in
            1)
                # Continue the loop for another backup
                break
                ;;
            2)
                # Exit the loop and end the script
                echo ""
                echo -e "${RED}Exiting...${RESET}"
                echo ""
                exit 0
                ;;
            *)
                echo -e "\n❌ ${RED}Invalid choice. Please try again.${RESET}\n"
                ;;
        esac
    done
done