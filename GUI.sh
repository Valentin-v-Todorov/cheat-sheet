#!/bin/bash

start_dialog(){

    # Color codes:
    RED='\e[31m'
    RESET='\e[0m'
    MAGENTA='\e[35m'
    WHITE='\e[37m'

    gui_box(){
        while true; do

        # creating the dialog, clears the screen, sets the title,  displays a menu, set dynamic dimensions, listing menu options. 

        # 2> menuchoice will capture the user's menu choice (stderr) in the file menuchoice. This is not only for the Exit option but for all the opton from 1 - 4. 2> menuchoice records the user choice, but it also captures any potential error messages

        # !!! There must be no empty rows between the >> \ << below !!!

        dialog --clear --title "Dialog Box 2000" --menu "Choose an epic option:" 0 0 0 \
        1 "Information Box" \
        2 "Yes/No Box" \
        3 "Text Input Box" \
        4 "Exit" 2> menuchoice

        # Write the content of the "menuchoice" file into the variable $choice, which will store the user's choice so they can be used in the case statement below.
        choice=$(cat menuchoice)

        # For every case we are starrting with dialog and then we add the type of the dialog box 
        case "$choice" in
            1)
                dialog --msgbox "This is an information box. I can enter big text like : \n \n Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.\n \n Isn't that cool or what ?!?" 0 0
                ;;
            2)
                dialog --yesno "Do you want to continue?" 0 0 
                if [ $? -eq 0 ]; then
                    dialog --msgbox "You chose 'Yes' because you are awesome !" 0 0 
                else
                    dialog --msgbox "You chose 'No' just because." 0 0 
                fi
                ;;
            3)
                # Creating a var >> text << that will contain the input from --inputbox and then displaying it with --msgbox

                # Programs can read from >> /dev/tty << to get user input or write to it to display output on the terminal.
                text=$(dialog --inputbox "Enter text:" 0 0  2>&1 >/dev/tty)
                dialog --msgbox "You entered: $text" 0 0 
                ;;
            4)
                echo "Exiting."
                exit
                ;;
        esac
    done
    }


    check_for_dialog(){

        # Check if dialog is installed
        command -v dialog
        if [ $? -eq 0 ]; then
            # If the dialog is installed - starts the dialog box
            gui_box
        else
            echo -e "\n❌ ${RED}Dialog is not installed.${RESET}"
            echo ""
            ask_to_install_dialog
        fi
    }

# add arch linux <<<<<<<<<<<<<<<<

    ask_to_install_dialog() {
        
        while true; do
        
            echo -e "${MAGENTA}You need Dialog installed in order to proceed. Do you wish to install Dialog?${RESET}"
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
            echo -e "1. ${WHITE}APT  (Debian/Ubuntu/Kali Linux/Linux Mint)${RESET}"
            echo -e "2. ${WHITE}YUM  (Fedora/RHEL/CentOS/Oracle)${RESET}"
            echo -e "3. ${WHITE}APK  (Alpine Linux)${RESET}"
            echo -e "4. ${WHITE}None of the listed${RESET}"
            echo -e "5. ${WHITE}Stop installing Dialog${RESET}"
            echo ""

            read -p "$(echo -e "${MAGENTA}Enter your choice: ${RESET}")" choice

            case $choice in
                1)
                    # install Dialog with apt-get
                    sudo apt-get update
                    sudo apt-get install -y dialog
                    check_for_dialog
                    break
                    ;;
                2)
                    # install Dialog with yum
                    sudo yum install -y dialog
                    check_for_dialog
                    break
                    ;;
                3)
                    # install Dialog with dnf
                    sudo dnf install -y dialog
                    check_for_dialog
                    break
                    ;;           
                4)
                    # exit the script
                    echo ""
                    echo -e "${WHITE}Please research how to install Dialog on your distribution and rerun the script.${RESET}"
                    echo ""
                    exit 0
                    ;;                      
                5)
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


    check_for_dialog

}

start_dialog