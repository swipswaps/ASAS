#!/bin/bash
#################################################################################
#                   *** ASAS 2.10 [Auto Server Admin Script] ***                #
#        @author: GCornell for devCU Software Open Source Projects              #
#        @contact: gacornell@devcu.com                                          #
#        $OS: Debian Core (Tested on Ubuntu 14x -> 17x / Debian 8.x -> 9.x)     #
#        $MAIN: https://www.devcu.com                                           #
#        $SOURCE: https://github.com/GaalexxC/ASAS                              #
#        $REPO: https://www.devcu.net                                           #
#        +Created:   06/15/2016 Ported from nginxubuntu-php7                    #
#        &Updated:   10/03/2017 08:50 EDT                                       #
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

#Nginx Install Menu

while [ 3 ]
do

SELECTNGINX=$(
whiptail --title "Nginx Web Server Installer" --radiolist "\nUse up/down arrows and tab to select an Nginx version\nUpon selection operation will begin without prompts" 20 78 8 \
        "1)" "Nginx Latest Mainline (Recommended)" ON \
        "2)" "Nginx Latest Stable" OFF \
        "3)" "Build Nginx source with Openssl (Advanced)" OFF \
        "4)" "Remove Nginx (Preserves Configurations)" OFF \
        "5)" "Purge Nginx (WARNING! Removes Everything!)" OFF \
        "6)" "Generate 2048bit Diffie-Hellman (Required for Nginx SSL/TLS)" OFF \
        "7)" "Return to Main Menu" OFF \
        "8)" "Exit" OFF 3>&1 1>&2 2>&3
)

case $SELECTNGINX in
        "1)")
   if ! type nginx > /dev/null 2>&1; then
    if [ "$DISTRO" = "Ubuntu" ]; then
       echo "deb http://nginx.org/packages/mainline/ubuntu/ $CODENAME nginx" >> $APT_SOURCES
       echo "deb-src http://nginx.org/packages/mainline/ubuntu/ $CODENAME nginx" >> $APT_SOURCES
        elif [ "$DISTRO" = "Debian" ]; then
       echo "deb http://nginx.org/packages/mainline/debian/ $CODENAME nginx" >> $APT_SOURCES
       echo "deb-src http://nginx.org/packages/mainline/debian/ $CODENAME nginx" >> $APT_SOURCES
     else
       whiptail --title "System Check" --msgbox "System OS is not recognized\nPress [Enter] to exit..." --ok-button "OK" 10 70
        exit 1
    fi
       nginxRepoAdd
       pkgcache() {
         printf "apt update"
       }
       updateSources
       package() {
         printf "apt --yes --force-yes install nginx fcgiwrap"
       }
       systemInstaller
       sleep 1
     else
       ngxver=$(nginx -v 2>&1)
       whiptail --title "Nginx Check" --msgbox "$ngxver is already installed\nPress [Enter] to return to Nginx menu" --ok-button "OK" 10 70
   fi
        ;;

        "2)")
    if ! type nginx > /dev/null 2>&1; then
     if [ "$DISTRO" = "Ubuntu" ]; then
      echo "deb http://nginx.org/packages/ubuntu/ $CODENAME nginx" >> $APT_SOURCES
      echo "deb-src http://nginx.org/packages/ubuntu/ $CODENAME nginx" >> $APT_SOURCES
     elif [ "$DISTRO" = "Debian" ]; then
      echo "deb http://nginx.org/packages/debian/ $CODENAME nginx" >> $APT_SOURCES
      echo "deb-src http://nginx.org/packages/debian/ $CODENAME nginx" >> $APT_SOURCES
     else
      whiptail --title "System Check" --msgbox "System OS is not recognized\nPress [Enter] to exit..." --ok-button "OK" 10 70
      exit 1
     fi
      nginxRepoAdd
      pkgcache() {
         printf "apt update"
       }
      updateSources
      package() {
         printf "apt --yes --force-yes install nginx fcgiwrap"
       }
      systemInstaller
      sleep 1

# -------
# NGINX CONFIG:
# -------
        echo -e "\nMaking backup of original nginx.conf"
        mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
        echo -e "\nUpdating nginx.conf with cache optimization and secure rules\n"
        CONFIGCONF='/etc/nginx/'
        cp config/nginx/nginx.conf $CONFIGCONF 2>/dev/null
        sleep 1
        echo -e "\nCreate nginx $NGINX_SITES_AVAILABLE if doesnt exist"
      if [ -d "$NGINX_SITES_AVAILABLE" ]
      then
        echo -e "\nDirectory $NGINX_SITES_AVAILABLE exists."
      else
        mkdir -p $NGINX_SITES_AVAILABLE
        echo -e "\nFinished directory creation"
      fi
        sleep 1
        echo -e "\nCreate nginx $NGINX_SITES_ENABLED if doesnt exist"
      if [ -d "$NGINX_SITES_ENABLED" ]
      then
        echo -e "\nDirectory $NGINX_SITES_ENABLED exists."
      else
        mkdir -p $NGINX_SITES_ENABLED
        echo -e "\nFinished directory creation"
      fi
        sleep 1
        echo -e "\nCreate nginx $NGINX_CONFD if doesnt exist"
      if [ -d "$NGINX_CONFD" ]
      then
        echo -e "\nDirectory $NGINX_CONFD exists."
      else
        mkdir -p $NGINX_CONFD
        echo -e "\nFinished directory creation"
      fi
        sleep 1
# -------
# NGINX VHOST:
# -------
        echo -e "\nCreate nginx vhosts.conf if doesnt exist"
      if [ -f /etc/nginx/conf.d/vhosts.conf ]
      then
        echo -e "\nGreat! the file exists"
      else
        echo -e "\nThe file doesnt exist, creating..."
        touch /etc/nginx/conf.d/vhosts.conf
        echo "include /etc/nginx/sites-enabled/*.vhost;" >>/etc/nginx/conf.d/vhosts.conf
      fi
        echo -e "\nFinished vhosts.conf creation"
        sleep 1
# Create, chown and optimize nginx cache/gzip directories!
        echo -e "\nCreate, chown and optimize nginx cache/gzip directories"
        mkdir -p /var/cache/nginx
        mkdir -p /var/cache/nginx/fcgi
        mkdir -p /var/cache/nginx/tmp
        chown -R www-data:root /var/cache/nginx
        echo -e "\nRemove signing key"
        rm -rf ./nginx_signing.key
        echo -e "\nRestart Services\n"
         $NGINX_INIT
        sleep 3
        ngxver=$(nginx -v 2>&1)
        whiptail --title "Nginx Check" --msgbox "$ngxver sucessfully installed\nPress [Enter] to return to Nginx menu" --ok-button "OK" 10 70
      else
        ngxver=$(nginx -v 2>&1)
        whiptail --title "Nginx Check" --msgbox "$ngxver is already installed\nPress [Enter] to return to Nginx menu" --ok-button "OK" 10 70
      fi
        ;;

        "3)")
      if ! type nginx > /dev/null 2>&1; then
        return
      else
        ngxver=$(nginx -v 2>&1)
        whiptail --title "Nginx Check" --msgbox "$ngxver is already installed\nPress [Enter] to return to Nginx menu" --ok-button "OK" 10 70
      fi
        ;;

        "4)")
     if type nginx > /dev/null 2>&1; then
         apt --yes --force-yes remove nginx
         apt-get --yes --force-yes autoremove
         sed -i.bak '/nginx/d' $APT_SOURCES
         whiptail --title "Nginx Uninstall" --msgbox "Nginx has been removed, configurations preserved\n\nPress [Enter] to return to Nginx menu" --ok-button "OK" 10 70
     else
         whiptail --title "Nginx Check-Install" --msgbox "Nothing to do Nginx not installed\nPress [Enter] to continue" --ok-button "OK" 10 70
     fi
        ;;

        "5)")
     if type nginx > /dev/null 2>&1; then
      if (whiptail --title "Purge Nginx" --yesno "Warning! Wipes all traces of Nginx from your system!\nAll configurations/logs/repos...etc deleted!\n\nWould you like to purge Nginx?" --yes-button "Purge" --no-button "Cancel" 10 70) then

       package() {
         printf "apt --yes --force-yes purge nginx fcgiwrap spawn-fcgi"
       }
       systemInstaller
       sleep 1
       pkgcache() {
          printf "apt-get --yes --force-yes autoremove"
       }
       updateSources
       sleep 1
         echo "removing directories"
         rm -rf /etc/nginx
         rm -rf /var/log/nginx
         echo "Removing Nginx repos"
         sed -i.bak '/nginx/d' $APT_SOURCES
       pkgcache() {
          printf "apt-get autoclean"
       }
       updateSources
       sleep 1
         whiptail --title "Nginx Uninstall" --msgbox "Nginx has been removed from system\n\nPress [Enter] to return to Nginx menu" --ok-button "OK" 10 70
     else
         whiptail --title "Operation Cancelled" --msgbox "Operation Cancelled\nPress [Enter] to go back" --ok-button "OK" 10 70
     fi
     else
         whiptail --title "Nginx Check-Install" --msgbox "Nothing to do Nginx not installed\nPress [Enter] to continue" --ok-button "OK" 10 70
     fi
        ;;

        "6)")
      if [ -f /etc/ssl/certs/dhparam.pem ]
      then
        whiptail --title "Security Check-Modify" --msgbox "Diffie-Hellman cert already exists!\nPATH is configured in nginx vhost templates\n\nPress [Enter] to return to Nginx menu" --ok-button "OK" 10 70
      else
      secureCommand() {
         output='openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048'
         printf "$output"
       }
      secureApp() {
         printf "openssl"
       }
        secureCheckModify
        whiptail --title "Security Check-Modify" --msgbox "Diffie-Hellman cert @ /etc/ssl/certs/dhparam.pem\nPATH is configured in nginx vhost templates\n\nPress [Enter] to return to Nginx menu" --ok-button "OK" 10 70
      fi
        ;;

        "7)")
      return
        ;;

        "8)")
      exit 1
        ;;
    esac

  done

exit
