#!/bin/bash
#################################################################################
#                   *** ASAS 2.10 [Auto Server Admin Script] ***                #
#        @author: GCornell for devCU Software Open Source Projects              #
#        @contact: gacornell@devcu.com                                          #
#        $OS: Debian Core (Tested on Ubuntu 16x -> 17x / Debian 8.x -> 9.x)     #
#        $MAIN: https://www.devcu.com                                           #
#        $SOURCE: https://github.com/GaalexxC/ASAS                              #
#        $REPO: https://www.devcu.net                                           #
#        +Created:   06/15/2016 Ported from nginxubuntu-php7                    #
#        &Updated:   11/12/2017 05:23 EDT                                       #
#                                                                               #
#    This program is free software: you can redistribute it and/or modify       #
#    it under the terms of the GNU General Public License as published by       #
#    the Free Software Foundation, either version 3 of the License, or          #
#    (at your option) any later version.                                        #
#                                                                               #
#    This program is distributed in the hope that it will be useful,            #
#    but WITHOUT ANY WARRANTY; without even the implied warranty of             #
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              #
#    GNU General Public License for more details.                               #
#                                                                               #
#    You should have received a copy of the GNU General Public License          #
#    along with this program.  If not, see http://www.gnu.org/licenses/         #
#                                                                               #
#################################################################################
clear

while [ 2 ]
do

SELECTUSERDOMAIN=$(
whiptail --title "User Domain Installer" --radiolist "\nUse up/down arrows and space to select\nUpon selection operation will begin without prompts" 18 78 10 \
        "1)" "New User and Domain (Remote Server)" ON \
        "2)" "New User and localhost (Local Server)" OFF \
        "3)" "List Active vhosts" OFF \
        "4)" "List Active FPM confs" OFF \
        "5)" "List Available IPs" OFF \
        "6)" "Backup Users Root Directory" OFF \
        "7)" "Remove User/Web" OFF \
        "8)" "Return to Main Menu" OFF \
        "9)" "Exit"  OFF 3>&1 1>&2 2>&3
)


case $SELECTUSERDOMAIN in
        "1)")
          if ! type nginx > /dev/null 2>&1; then
           if (whiptail --title "Nginx Check-Install" --yesno "Nginx not installed and is required\n\nDo you want to install?" --yes-button "Install" --no-button "Cancel" 10 70) then
             source scripts/nginx_install.sh
           else
            return
           fi
          else
             ngxver=$(nginx -v 2>&1)
             whiptail --title "Nginx Check-Install" --msgbox "Nginx Installed!\n\n$ngxver" --ok-button "Continue" 10 70
          fi

          if ! type php > /dev/null 2>&1; then
           if (whiptail --title "PHP Check-Install" --yesno "PHP not installed and required\n\nDo you want to install?" --yes-button "Install" --no-button "Cancel" 10 70) then
             source scripts/php_install.sh
           else
            return
           fi
          else
             phpver=$(php -r \@phpinfo\(\)\; | grep 'PHP Version' -m 1)
             whiptail --title "PHP Check-Install" --msgbox "PHP Installed!\n\n$phpver" --ok-button "Continue" 10 70
          fi
          #createuserremotehost
        ;;

        "2)")
          if ! type nginx > /dev/null 2>&1; then
           if (whiptail --title "Nginx Check-Install" --yesno "Nginx not installed and is required\n\nDo you want to install?" --yes-button "Install" --no-button "Cancel" 10 70) then
             source scripts/nginx_install.sh
           else
            return
           fi
          else
             ngxver=$(nginx -v 2>&1)
             whiptail --title "Nginx Check-Install" --msgbox "Nginx Installed!\n\n$ngxver" --ok-button "Continue" 10 70
          fi

          if ! type php > /dev/null 2>&1; then
           if (whiptail --title "PHP Check-Install" --yesno "PHP not installed and required\n\nDo you want to install?" --yes-button "Install" --no-button "Cancel" 10 70) then
             source scripts/php_install.sh
           else
            return
           fi
          else
             phpver=$(php -r \@phpinfo\(\)\; | grep 'PHP Version' -m 1)
             whiptail --title "PHP Check-Install" --msgbox "PHP Installed!\n\n$phpver" --ok-button "Continue" 10 70
          fi
          createuserlocalhost
        ;;

        "3)")
          listvhostshosts
        ;;

        "4)")
          listfpmconfs
        ;;

        "5)")
          listavailips
        ;;

        "6)")
          #backupuserroot
          return
        ;;

        "7)")
          removeuserroot
        ;;

        "8)")

          return
        ;;

        "9)")

          exit 1
        ;;
  esac

 done

exit

