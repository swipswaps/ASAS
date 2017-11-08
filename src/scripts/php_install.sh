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
#        &Updated:   11/08/2017 16:50 EDT                                       #
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

while [ 4 ]
do

SELECTPHP=$(
whiptail --title "PHP Installer" --radiolist "\nUse up/down arrows and space to select an operation\nUpon selection operation will begin without prompts" 18 78 10 \
        "1)" "Install PHP 7.2" OFF \
        "2)" "Install PHP 7.1 (Recommended)" ON \
        "3)" "Install PHP 7.0" OFF \
        "4)" "Configure PHP Settings" OFF \
        "5)" "Backup Config (php.ini)" OFF \
        "6)" "Remove PHP (Config Saved)" OFF \
        "7)" "Purge PHP (Wipe Clean)" OFF \
        "8)" "Return to Main Menu" OFF \
        "9)" "Exit" OFF 3>&1 1>&2 2>&3
)

case $SELECTPHP in
        "1)")

     if ! type php > /dev/null 2>&1; then
       phpDependencyCheck
       package() {
         printf "apt --yes install $PHP72_PACKAGES"
       }
       systemInstaller
       completeOperation
     else
       phpver=$(php -r \@phpinfo\(\)\; | grep 'PHP Version' -m 1)
       whiptail --title "PHP Check-Install" --msgbox "PHP Installed!\n\n$phpver" --ok-button "OK" 10 70
     fi
        ;;

        "2)")

     if ! type php > /dev/null 2>&1; then
       phpDependencyCheck
       package() {
         printf "apt --yes install $PHP71_PACKAGES"
       }
       systemInstaller
       completeOperation
     else
       phpver=$(php -r \@phpinfo\(\)\; | grep 'PHP Version' -m 1)
       whiptail --title "PHP Check-Install" --msgbox "PHP Installed!\n\n$phpver" --ok-button "OK" 10 70
     fi
        ;;

        "3)")

     if ! type php > /dev/null 2>&1; then
       phpDependencyCheck
       package() {
         printf "apt --yes install $PHP70_PACKAGES"
       }
       systemInstaller
       completeOperation
     else
       phpver=$(php -r \@phpinfo\(\)\; | grep 'PHP Version' -m 1)
       whiptail --title "PHP Check-Install" --msgbox "PHP Installed!\n\n$phpver" --ok-button "OK" 10 70
     fi
        ;;

        "4)")

     if ! type php > /dev/null 2>&1; then
       whiptail --title "PHP Check-Install" --msgbox "PHP not installed\nPress [Enter] to continue" --ok-button "OK" 10 70
     else
       source scripts/php_configure.sh
     fi
        ;;

        "5)")

     if ! type php > /dev/null 2>&1; then
       whiptail --title "PHP Check-Install" --msgbox "PHP not installed\nPress [Enter] to continue" --ok-button "OK" 10 70
     else
       phpBackupConf
     fi
        ;;


        "6)")

   if type php > /dev/null 2>&1; then
    if (whiptail --title "Remove PHP" --yesno "Warning! Removes PHP (Preserves Configurations)\n\nWould you like to remove PHP" --yes-button "Remove" --no-button "Cancel" 10 70) then
       package() {
         printf "apt --yes remove `dpkg -l | grep php| awk '{print $2}' |tr "\n" " "`"
       }
       systemInstaller
       sleep 1
       pkgcache() {
          printf "apt-get --yes autoremove"
       }
       updateSources
       sleep 1
       phpPurge
       sleep 1
       pkgcache() {
          printf "apt-get autoclean"
       }
       updateSources
       sleep 1
         whiptail --title "Remove PHP" --msgbox "PHP has been removed from system" --ok-button "OK" 10 70
      else
       cancelOperation
    fi
      else
       whiptail --title "Remove PHP" --msgbox "Nothing to do PHP not installed\nPress [Enter] to continue" --ok-button "OK" 10 70
   fi
        ;;

        "7)")

   if type php > /dev/null 2>&1; then
    if (whiptail --title "Purge PHP" --yesno "Warning! Wipes all traces of PHP from your system!\nAll configurations/logs/repos...etc deleted!\n\nWould you like to purge PHP?" --yes-button "Purge" --no-button "Cancel" 10 70) then
       package() {
         printf "apt --yes purge `dpkg -l | grep php| awk '{print $2}' |tr "\n" " "`"
       }
       systemInstaller
       sleep 1
       pkgcache() {
          printf "apt-get --yes autoremove"
       }
       updateSources
       sleep 1
       phpPurge
       sleep 1
       pkgcache() {
          printf "apt-get autoclean"
       }
       updateSources
       sleep 1
         whiptail --title "Purge PHP" --msgbox "PHP has been wiped from system\n\nPress [Enter] to return to PHP menu" --ok-button "OK" 10 70
    else
       cancelOperation
    fi
   else
         whiptail --title "Purge PHP" --msgbox "Nothing to do PHP not installed\nPress [Enter] to continue" --ok-button "OK" 10 70
   fi
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
