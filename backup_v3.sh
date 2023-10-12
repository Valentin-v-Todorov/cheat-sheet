#!/bin/bash

# Default values:
destination_path=/home/valentin/backups/

start_dialog(){

    # Color codes:
    RED='\e[31m'
    GREEN='\e[32m'
    CYAN='\e[36m'
    RESET='\e[0m'
    MAGENTA='\e[35m'
    WHITE='\e[37m'
    

    gui_box(){
        while true; do

        dialog --clear --title "Backup application" --menu "Choose an option:" 0 0 0 \
        1 "Create a tar backup" \
        2 "Decompress tar" \
        3 "Exit" 2> menuchoice
        
        choice=$(cat menuchoice)

        case "$choice" in
            1)
                dialog --clear --title "Backup application" --menu "Choose an option:" 0 0 0 \
                    1 "Start the backup process" \
                    2 "Exit" 2> menuchoice
                    
                    choice=$(cat menuchoice)

                    case "$choice" in
                        1)

                            create_backup() {
                                backup_name=$(dialog --inputbox "Enter the name for the backup:" 5 40 2>&1 >/dev/tty)

                                if [ -z "$backup_name" ]; then
                                    dialog --msgbox "Backup canceled. No backup name provided." 0 0
                                    return
                                fi

                                backup_name="$(date +%Y-%m-%d)-${backup_name}"

                                # This is here so I can track the exit code.
                                (tar -cz -C "${source_dir}" . 2>&1 | pv -petrbc) > "${destination}/${backup_name}.tar.gz" 2>&1

                                if [ $? -eq 0 ]; then
                                    dialog --msgbox "Backup completed successfully. The backup is saved to: $destination/$backup_name.tar.gz" 6 60
                                else
                                    dialog --msgbox "Backup failed. There was an issue with creating the archive." 0 0
                                fi
                            }

                            select_destination() {

                                folders=("files" "scripts" "big_backups")

                                for folder in "${folders[@]}"; do
                                    if [ ! -d "${destination_path}${folder}" ]; then
                                        mkdir -p "${destination_path}${folder}"
                                        dialog --msgbox "Folder '${folder}' created inside: ${destination_path}" 6 40
                                    fi
                                done

                                while true; do
                                    dialog --clear --title "Select Destination" --menu "Select the destination path for the backup:" 0 0 0 \
                                    1 "${destination_path}files" \
                                    2 "${destination_path}scripts" \
                                    3 "${destination_path}big_backups" \
                                    4 "Create a new folder inside: ${destination_path}" \
                                    5 "Quit" 2> menuchoice

                                    choice=$(cat menuchoice)

                                    case "$choice" in
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
                                            folder_name=$(dialog --inputbox "Enter the name of the new folder:" 5 40 2>&1 >/dev/tty)
                                            if [ -z "$folder_name" ]; then
                                                dialog --msgbox "Backup canceled. No folder name provided." 0 0
                                            else
                                                destination="${destination_path}${folder_name}"
                                                mkdir -p "$destination"
                                                dialog --msgbox "Folder '$folder_name' created inside: $destination_path" 6 40
                                                break
                                            fi
                                            ;;
                                        5)
                                            dialog --msgbox "Exiting..." 0 0
                                            exit 0
                                            ;;
                                        *)
                                            dialog --msgbox "Invalid choice. Please try again." 0 0
                                            ;;
                                    esac
                                done

                                dialog --msgbox "You selected: $destination" 0 0
                            }

                            enter_source() {

                                current=$(pwd)

                                while true; do
                                    source=$(dialog --inputbox "Press >> ENTER << for the current directory  \n\n Enter the path for the directory you wish to make a backup:" 0 0 2>&1 >/dev/tty)

                                    if [ -z "$source" ]; then           
                                        source="$current"
                                    fi

                                    if [ -d "$source" ]; then
                                        dialog --msgbox "The directory exists. Continuing..." 5 40
                                        select_destination
                                        create_backup
                                        break
                                    else
                                        dialog --msgbox "The specified source directory does not exist. Please try again." 5 80
                                    fi
                                done
                            }
                            
                            # Start all the functions listed above
                            enter_source
                            ;;
                        2)
                            echo "Exiting."
                            clear && printf '\033[3J'
                            exit
                            ;;
                    esac
                ;;
            
            2)
                dialog --msgbox "Sorry this option is not yet created. Check again soon. :)" 0 0
                ;;            
            3)
                echo "Exiting."
                clear && printf '\033[3J'
                exit
                ;;
        esac
    done
    }

    check_for_packages(){

        # Check if dialog is installed
        command -v dialog && command -v pv
        if [ $? -eq 0 ]; then
            # If the dialog is installed - starts the dialog box
            gui_box
        else
            echo -e "\n❌ ${RED}Some required packages are missing!${RESET}"
            echo ""
            ask_to_install_packages
        fi
    }

    ask_to_install_packages() {
        
        while true; do
        
            echo -e "${MAGENTA}You need the packages dialog and pv installed in order to proceed. Do you wish to install Dialog and pv?${RESET}"
            echo ""
            echo -e "1. ${WHITE}Yes${RESET}"
            echo -e "2. ${WHITE}No${RESET}"
            echo ""

            read -p "$(echo -e "${MAGENTA}Enter your choice: ${RESET}")" choice

            case $choice in
                1)
                    installing_dialog
                    break
                    ;;
                2)
                    # If "No" is selected, exit the script
                    echo ""
                    echo -e "${WHITE}OK, bye :)${RESET}"
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
    }


    installing_dialog() {
        
        # Prompt the user to select the destination path for the backup
        while true; do
            echo __________________________________________________________
            echo ""
            echo -e "${MAGENTA}Please select your Linux Distributions:${RESET}"
            echo ""
            echo -e "1. ${WHITE}APT     (Debian/Ubuntu/Kali Linux/Linux Mint)${RESET}"
            echo -e "2. ${WHITE}YUM     (Fedora/RHEL/CentOS/Oracle)${RESET}"
            echo -e "3. ${WHITE}APK     (Alpine Linux)${RESET}"
            echo -e "4. ${WHITE}PACMAN  (Arch Linux/Manjaro/EndeavourOS/Parabola)${RESET}"
            echo -e "5. ${WHITE}None of the listed${RESET}"
            echo -e "6. ${WHITE}Stop installing Dialog${RESET}"
            echo ""

            read -p "$(echo -e "${MAGENTA}Enter your choice: ${RESET}")" choice

            case $choice in
                1)
                    # install Dialog with apt-get
                    sudo apt-get update
                    sudo apt-get install -y dialog
                    sudo apt-get install -y pv
                    check_for_packages
                    break
                    ;;
                2)
                    # install Dialog with yum
                    sudo yum install -y dialog
                    sudo yum install -y pv
                    check_for_packages
                    break
                    ;;
                3)
                    # install Dialog with dnf
                    sudo dnf install -y dialog
                    sudo dnf install -y pv
                    check_for_packages
                    break
                    ;;       
                4)
                    # install Dialog with pacman
                    sudo pacman -S --noconfirm dialog
                    sudo pacman -Syu --noconfirm pv
                    check_for_packages
                    break
                    ;;        
                5)
                    # exit the script
                    echo ""
                    echo -e "${WHITE}Please research how to install Dialog on your distribution and rerun the script.${RESET}"
                    echo ""
                    exit 0
                    ;;                      
                6)
                    # exit the script
                    echo ""
                    echo -e "${WHITE}OK, bye :)${RESET}"
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
    }


    check_for_packages

}

start_dialog