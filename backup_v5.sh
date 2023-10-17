#!/bin/bash

# Default values:
destination_path=/home/valentin/backups/

# Whiptail colors
export NEWT_COLORS='
    root=white,black
    border=black,lightgray
    window=lightgray,lightgray
    shadow=black,gray
    title=black,lightgray
    button=black,cyan
    actbutton=white,cyan
    compactbutton=black,lightgray
    checkbox=black,lightgray
    actcheckbox=lightgray,cyan
    entry=black,lightgray
    disentry=gray,lightgray
    label=black,lightgray
    listbox=black,lightgray
    actlistbox=black,cyan
    sellistbox=lightgray,black
    actsellistbox=lightgray,black
    textbox=black,lightgray
    acttextbox=black,cyan
    emptyscale=,gray
    fullscale=,cyan
    helpline=white,black
    roottext=lightgrey,black
'


start_whiptail(){

    # Color codes:
    RED='\e[31m'
    GREEN='\e[32m'
    CYAN='\e[36m'
    RESET='\e[0m'
    MAGENTA='\e[35m'
    WHITE='\e[37m'
    

    gui_box(){
        while true; do

        choice=$(whiptail --title "Backup application" --menu "Choose an option:" 0 0 0 \
        1 "Create a tar backup" \
        2 "Decompress tar" \
        3 "Exit" 3>&2 2>&1 1>&3)

        case "$choice" in
            1)
                choice=$(whiptail --title "Backup application" --menu "Choose an option:" 0 0 0 \
                    1 "Start the backup process" \
                    2 "Exit" 3>&2 2>&1 1>&3)

                case "$choice" in
                    1)
                        create_backup() {
                            backup_name=$(whiptail --inputbox "Enter the name for the backup:" 0 0 2>&1 >/dev/tty)

                            if [ -z "$backup_name" ]; then
                                whiptail --msgbox "Backup canceled. No backup name provided." 0 0
                                return
                            fi

                            backup_name="$(date +%Y-%m-%d)-${backup_name}"

                            (tar -cz -C "${source}" . 2>&1 | pv -petrbc) > "${destination}/${backup_name}.tar.gz" 2>&1

                            if [ $? -eq 0 ]; then
                                whiptail --msgbox "Backup completed successfully. The backup is saved to: $destination/$backup_name.tar.gz" 0 0
                            else
                                whiptail --msgbox "Backup failed. There was an issue with creating the archive." 0 0
                            fi
                        }

                        select_destination() {

                            folders=("files" "scripts" "big_backups")

                            for folder in "${folders[@]}"; do
                                if [ ! -d "${destination_path}${folder}" ]; then
                                    mkdir -p "${destination_path}${folder}"
                                    whiptail --msgbox "Folder '${folder}' created inside: ${destination_path}" 0 0
                                fi
                            done

                            while true; do
                                choice=$(whiptail --title "Select Destination" --menu "Select the destination path for the backup:" 0 0 0 \
                                1 "${destination_path}files" \
                                2 "${destination_path}scripts" \
                                3 "${destination_path}big_backups" \
                                4 "Create a new folder inside: ${destination_path}" \
                                5 "Quit" 3>&2 2>&1 1>&3)

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
                                        folder_name=$(whiptail --inputbox "Enter the name of the new folder:" 0 0 2>&1 >/dev/tty)
                                        if [ -z "$folder_name" ]; then
                                            whiptail --msgbox "Backup canceled. No folder name provided." 0 0
                                        else
                                            destination="${destination_path}${folder_name}"
                                            mkdir -p "$destination"
                                            whiptail --msgbox "Folder '$folder_name' created inside: $destination_path" 0 0
                                            break
                                        fi
                                        ;;
                                    5)
                                        whiptail --msgbox "Exiting..." 0 0
                                        exit 0
                                        ;;
                                    *)
                                        whiptail --msgbox "Invalid choice. Please try again." 0 0
                                        ;;
                                esac
                            done

                            whiptail --msgbox "You selected: $destination" 0 0
                        }

                        enter_source() {

                            current=$(pwd)

                            while true; do
                                source=$(whiptail --inputbox "Press >> ENTER << for the current directory  \n\n Enter the path for the directory you wish to make a backup:" 0 0 2>&1 >/dev/tty)

                                if [ -z "$source" ]; then           
                                    source="$current"
                                fi

                                if [ -d "$source" ]; then
                                    whiptail --msgbox "The directory exists. Continuing..." 0 0
                                    select_destination
                                    create_backup
                                    break
                                else
                                    whiptail --msgbox "The specified source directory does not exist. Please try again." 0 0
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
            
            2) ####################################################################################

                the_decompression(){
                    tar_file="$tar_file_path"
                    decompression_dir="$decompression_destination"

                    if [ ! -d "$decompression_dir" ]; then
                        mkdir -p "$decompression_dir"
                    fi

                    # Check if the tar file exists
                    if [ -f "$tar_file" ]; then
                        # Decompress the tar file to the specified destination
                        (tar -xzvf "$tar_file" -C "$decompression_dir" 2>&1 | pv -petrbc) > /dev/null 2>&1

                        if [ $? -eq 0 ]; then
                            whiptail --msgbox "Decompression completed successfully. Files are extracted to: $decompression_dir" 0 0
                        else
                            whiptail --msgbox "Decompression failed. There was an issue with extracting the archive." 0 0
                        fi
                    else
                        whiptail --msgbox "The specified tar file does not exist. Please try again." 0 0
                    fi
                }

                tar_decompression_destination(){

                    while true; do
                        decompression_destination_choice=$(whiptail --title "Select Destination" --menu "Select the destination path for the decompression:" 0 0 0 \
                        1 "${destination_path}files/decompressed" \
                        2 "${destination_path}scripts/decompressed" \
                        3 "${destination_path}big_backups/decompressed" \
                        4 "Enter a custom directory" \
                        5 "Quit" 3>&2 2>&1 1>&3)

                        case "$decompression_destination_choice" in
                            1)
                                decompression_destination="${destination_path}files/decompressed"
                                break
                                ;;
                            2)
                                decompression_destination="${destination_path}scripts/decompressed"
                                break
                                ;;
                            3)
                                decompression_destination="${destination_path}big_backups/decompressed"
                                break
                                ;;
                            4)
                                custom_directory=$(whiptail --inputbox "Enter the custom directory path:" 0 0 2>&1 >/dev/tty)
                                if [ -z "$custom_directory" ]; then
                                    whiptail --msgbox "Backup canceled. No directory provided." 0 0
                                else
                                    decompression_destination="$custom_directory"
                                    mkdir -p "$decompression_destination"
                                    whiptail --msgbox "Folder '$decompression_destination' created." 0 0
                                    break
                                fi
                                ;;
                            5)
                                whiptail --msgbox "Exiting..." 0 0
                                exit 0
                                ;;
                            *)
                                whiptail --msgbox "Invalid choice. Please try again." 0 0
                                ;;
                        esac
                    done

                    whiptail --msgbox "You selected: $decompression_destination" 0 0

                }


                select_tar() {
                    folders=($(ls -d "${destination_path}"*/))
                    folder_options=()

                    for folder in "${folders[@]}"; do
                        folder_name=$(basename "$folder")
                        num_files=$(find "$folder" -maxdepth 1 -type f | wc -l)
                        if [ "$num_files" -eq 0 ]; then
                            folder_options+=("$folder_name" "No files inside")
                        else
                            folder_options+=("$folder_name" "$num_files files inside")
                        fi
                    done

                    if [ ${#folder_options[@]} -eq 0 ]; then
                        whiptail --msgbox "No folders found inside: $destination_path" 0 0
                        return
                    fi

                    selected_folder=$(whiptail --title "Select Destination Folder" --menu "Select a folder:" 0 0 0 "${folder_options[@]}" 3>&1 1>&2 2>&3)

                    if [ -z "$selected_folder" ]; then
                        whiptail --msgbox "No folder selected. Exiting..." 0 0
                        return
                    fi

                    folder_path="${destination_path}${selected_folder}"
                    tar_files=()

                    for file in "$folder_path"/*.tar.gz; do
                        tar_files+=("$(basename "$file")" "")
                    done

                    if [ ${#tar_files[@]} -eq 0 ]; then
                        whiptail --msgbox "No tar files found inside: $folder_path" 0 0
                        return
                    fi

                    selected_tar_file=$(whiptail --title "Select Tar File" --menu "Select a tar file:" 0 0 0 "${tar_files[@]}" 3>&1 1>&2 2>&3)

                    if [ -z "$selected_tar_file" ]; then
                        whiptail --msgbox "No tar file selected. Exiting..." 0 0
                        return
                    fi

                    tar_file_path="${folder_path}/${selected_tar_file}"

                    whiptail --msgbox "You selected the following tar file: $tar_file_path" 0 0 

                    tar_decompression_destination
                    the_decompression
                }
                select_tar
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

        # Check if whiptail is installed
        command -v whiptail && command -v pv
        if [ $? -eq 0 ]; then
            # If whiptail is installed - starts the whiptail interface
            gui_box
        else
            echo -e "\n❌ ${RED}Some required packages are missing!${RESET}"
            echo ""
            ask_to_install_packages
        fi
    }

    ask_to_install_packages() {
        
        while true; do
        
            echo -e "${MAGENTA}You need the packages whiptail and pv installed in order to proceed. Do you wish to install whiptail and pv?${RESET}"
            echo ""
            echo -e "1. ${WHITE}Yes${RESET}"
            echo -e "2. ${WHITE}No${RESET}"
            echo ""

            read -p "$(echo -e "${MAGENTA}Enter your choice: ${RESET}")" choice

            case $choice in
                1)
                    installing_whiptail
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

    installing_whiptail() {
        
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
            echo -e "6. ${WHITE}Stop installing Whiptail${RESET}"
            echo ""

            read -p "$(echo -e "${MAGENTA}Enter your choice: ${RESET}")" choice

            case $choice in
                1)
                    # install Whiptail with apt-get
                    sudo apt-get update
                    sudo apt-get install -y whiptail
                    sudo apt-get install -y pv
                    check_for_packages
                    break
                    ;;
                2)
                    # install Whiptail with yum
                    sudo yum install -y newt
                    sudo yum install -y pv
                    check_for_packages
                    break
                    ;;
                3)
                    # install Whiptail with apk
                    sudo apk add whiptail
                    sudo apk add pv
                    check_for_packages
                    break
                    ;;       
                4)
                    # install Whiptail with pacman
                    sudo pacman -S --noconfirm libnewt
                    sudo pacman -Syu --noconfirm pv
                    check_for_packages
                    break
                    ;;        
                5)
                    # exit the script
                    echo ""
                    echo -e "${WHITE}Please research how to install Whiptail on your distribution and rerun the script.${RESET}"
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

start_whiptail
