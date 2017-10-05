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
#        &Updated:   10/05/2017 08:50 EDT                                       #
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
# Check Nginx/PHP

   if ! type nginx > /dev/null 2>&1; then
     if (whiptail --title "Nginx Check" --yesno "Nginx not installed and is required\nDo you want to install?" --yes-button "Install" --no-button "Cancel" 10 70) then
        source scripts/nginx_install.sh
    else
         return
     fi
   else
        ngxver=$(nginx -v 2>&1)
        whiptail --title "Nginx Check" --msgbox "$ngxver is currently installed\nPress [Enter] to continue" --ok-button "Continue" 10 70
   fi

   if ! type php > /dev/null 2>&1; then
     if (whiptail --title "PHP Check" --yesno "PHP not installed and required\nDo you want to install?" --yes-button "Install" --no-button "Cancel" 10 70) then
        source scripts/php_install.sh
    else
         return
     fi
   else
        phpver=$(php -r \@phpinfo\(\)\; | grep 'PHP Version' -m 1)
        whiptail --title "PHP Check" --msgbox "$phpver is currently installed\nPress [Enter] to continue" --ok-button "Continue" 10 70
   fi

      echo -e "\nJust double checking your setup, /$HOME_PARTITION partition with $ROOT_DIRECTORY as your root ?"

      read -p "If yes then hit [Enter] and lets go..."
      echo""

# Local or remote server and create domain
     echo -e "\nCreate Web and User"
     echo "Is this a remote server accessible via yourdomain.com? (y/n) Choose no if creating local server accessible via hostname"
     read REMOTE
   if [ $REMOTE == "y" ]; then
     echo "Please Specify The Domain IE: yourdomain.com"
     read DOMAIN
     PATTERN="^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$";
   if [[ "$DOMAIN" =~ $PATTERN ]]; then
     DOMAIN=`echo $DOMAIN | tr '[A-Z]' '[a-z]'`
     echo "Creating Hosting For:" $DOMAIN
# Configure IP Address for Server
#IP Validation TODO v2.11
     echo -n "Available Server IP Addresses "
     hostname -I
     echo -n "Enter IP Address for Domain > "
     read IP
     echo "You Entered: $IP"
   else
     echo "Invalid Domain Name"
     exit 1
   fi
   else
     echo "Local vhost name must be unique per user/web IE: localhost, localhost1, localhost2, etc"
     echo "Current vhost files currently in use:"
   if [ ! -f /etc/nginx/sites-available/*.vhost ]; then
     echo "There are none"
     echo "Create new unique vhost"
   else
     find /etc/nginx/sites-available/*.vhost  -exec  basename {} .vhost  \;
     echo "Create new unique vhost"
   fi
     read LOCAL
     echo "Hostname of local server. This is how you will access via the web IE: testserver:8080"
     echo "Your hostname on this machine is:"
     cat /etc/hostname
     read SERVER
     PATTERN="^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$";
   if [[ "$SERVER" =~ $PATTERN ]]; then
     SERVER=`echo $SERVER | tr '[A-Z]' '[a-z]'`
     echo "Creating Hosting For:" $SERVER
# Configure Port 8080+ - Local Server
     echo -n "Enter Port - Local Server ex: 8080, 8081, 8090, etc > "
     read PORT
     echo "You Entered: $PORT"
   else
     echo "Invalid Hostname"
     exit 1
   fi
fi

# Create a new user
     echo "Please Specify The Username then Password For This Site"
     read USERNAME
     HOME_DIR=$USERNAME
     adduser $USERNAME

# Create directories - files
     echo "Would You Like To Change The Web Root Directory, default is /$HOME_PARTITION/$HOME_DIR/$ROOT_DIRECTORY/ no (y/n)?"
     read CHANGEROOT
   if [[ $CHANGEROOT == "y" ]]; then
     echo "Enter the new web root dir (/$HOME_PARTITION/$HOME_DIR/???/)"
     read DIR
     PUBLIC_HTML_DIR=/$DIR
   else
     PUBLIC_HTML_DIR=/$ROOT_DIRECTORY
   fi

# Create a new domain vhost
   if [ $REMOTE == "y" ]; then
     CONFIG=$NGINX_SITES_AVAILABLE/$DOMAIN.vhost
     cp $CURDIR/templates/remote.vhost.template $CONFIG 2> /dev/null
     echo -e "\nInstalled vhost conf\n"

$SED -i "s/@@HOSTNAME@@/$DOMAIN/g" $CONFIG
$SED -i "s/@@IPADD@@/$IP/g" $CONFIG
$SED -i "s#@@PATH@@#\/$HOME_PARTITION\/"$USERNAME$PUBLIC_HTML_DIR"#g" $CONFIG
$SED -i "s/@@LOG_PATH@@/\/$HOME_PARTITION\/$USERNAME\/logs/g" $CONFIG
$SED -i "s/@@SSL_PATH@@/\/$HOME_PARTITION\/$USERNAME\/ssl/g" $CONFIG
$SED -i "s#@@SOCKET@@#/var/run/"$USERNAME"_fpm.sock#g" $CONFIG
   else
     CONFIG=$NGINX_SITES_AVAILABLE/$LOCAL.vhost
     cp $CURDIR/templates/local.vhost.template $CONFIG 2> /dev/null
     echo -e "\nInstalled vhost conf\n"

$SED -i "s/@@HOSTNAME@@/$SERVER/g" $CONFIG
$SED -i "s/@@PORT@@/$PORT/g" $CONFIG
$SED -i "s#@@PATH@@#\/$HOME_PARTITION\/"$USERNAME$PUBLIC_HTML_DIR"#g" $CONFIG
$SED -i "s/@@LOG_PATH@@/\/$HOME_PARTITION\/$USERNAME\/logs/g" $CONFIG
$SED -i "s/@@SSL_PATH@@/\/$HOME_PARTITION\/$USERNAME\/ssl/g" $CONFIG
$SED -i "s#@@SOCKET@@#/var/run/"$USERNAME"_fpm.sock#g" $CONFIG
   fi

     echo "FPM max children, must be higher then max servers, try 8:"
     read MAX_CHILDREN
     echo -e "\n# start FPM servers, start servers must not be less than min spare servers and not greater than max spare servers, try 4:"
     read FPM_SERVERS
     echo -e "\nMin # spare FPM servers, try 2:"
     read MIN_SERVERS
     echo -e "\nMax # spare FPM servers, try 6:"
     read MAX_SERVERS

# Create a new php fpm pool config
   if [ $REMOTE == "y" ]; then
     echo -e "\nInstall PHP FPM conf file\n"
     FPMCONF="$PHP7_FPM_DIR/$DOMAIN.conf"
     cp $CURDIR/templates/conf.template $FPMCONF 2> /dev/null
$SED -i "s/@@USER@@/$USERNAME/g" $FPMCONF
$SED -i "s/@@GROUP@@/$USERNAME/g" $FPMCONF
$SED -i "s/@@HOME_DIR@@/\/$HOME_PARTITION\/$USERNAME/g" $FPMCONF
$SED -i "s/@@MAX_CHILDREN@@/$MAX_CHILDREN/g" $FPMCONF
$SED -i "s/@@START_SERVERS@@/$FPM_SERVERS/g" $FPMCONF
$SED -i "s/@@MIN_SERVERS@@/$MIN_SERVERS/g" $FPMCONF
$SED -i "s/@@MAX_SERVERS@@/$MAX_SERVERS/g" $FPMCONF
   else
     echo -e "\nInstall PHP FPM conf file\n"
     FPMCONF="$PHP7_FPM_DIR/$LOCAL.conf"
     cp $CURDIR/templates/conf.template $FPMCONF 2> /dev/null
$SED -i "s/@@USER@@/$USERNAME/g" $FPMCONF
$SED -i "s/@@GROUP@@/$USERNAME/g" $FPMCONF
$SED -i "s/@@HOME_DIR@@/\/$HOME_PARTITION\/$USERNAME/g" $FPMCONF
$SED -i "s/@@MAX_CHILDREN@@/$MAX_CHILDREN/g" $FPMCONF
$SED -i "s/@@START_SERVERS@@/$FPM_SERVERS/g" $FPMCONF
$SED -i "s/@@MIN_SERVERS@@/$MIN_SERVERS/g" $FPMCONF
$SED -i "s/@@MAX_SERVERS@@/$MAX_SERVERS/g" $FPMCONF
   fi

     echo -e "\nSet System Permissions\n"
     usermod -aG $USERNAME $WEB_SERVER_GROUP
     chmod g+rx /$HOME_PARTITION/$HOME_DIR
     chmod 600 $CONFIG
   if [ $REMOTE == "y" ]; then
     ln -s $NGINX_SITES_AVAILABLE/$DOMAIN.vhost $NGINX_SITES_ENABLED/
   else
     ln -s $NGINX_SITES_AVAILABLE/$LOCAL.vhost $NGINX_SITES_ENABLED/
   fi

# set file perms and create required dirs!
     echo -e "\nInstall web directories\n"
     mkdir -p /$HOME_PARTITION/$HOME_DIR$PUBLIC_HTML_DIR
     mkdir -p /$HOME_PARTITION/$HOME_DIR/logs
     mkdir -p /$HOME_PARTITION/$HOME_DIR/ssl
     mkdir -p /$HOME_PARTITION/$HOME_DIR/_sessions
     mkdir -p /$HOME_PARTITION/$HOME_DIR/backup

# Create a index.php placeholder page to avoid 403 error
     CONFIG=/$HOME_PARTITION/$HOME_DIR$PUBLIC_HTML_DIR/
     cp $CURDIR/skel/index.php $CONFIG 2> /dev/null
     echo -e "\nInstalled basic index.php placeholder\n"

     echo -e "\nSet Web Directory Permissions\n"
     chmod 750 /$HOME_PARTITION/$HOME_DIR -R
     chmod 700 /$HOME_PARTITION/$HOME_DIR/_sessions
     chmod 770 /$HOME_PARTITION/$HOME_DIR/ssl
     chmod 770 /$HOME_PARTITION/$HOME_DIR/logs
     chmod 770 /$HOME_PARTITION/$HOME_DIR/backup
     chmod 750 /$HOME_PARTITION/$HOME_DIR$PUBLIC_HTML_DIR
     chmod 644 /$HOME_PARTITION/$HOME_DIR$PUBLIC_HTML_DIR/index.php
     chown $USERNAME:$USERNAME /$HOME_PARTITION/$HOME_DIR/ -R
     chown root:root /$HOME_PARTITION/$HOME_DIR/ssl -R
     chown root:root /$HOME_PARTITION/$HOME_DIR/backup -R
     echo -e "\nPermissions Set\n"

     echo -e "\nRestart Services\n"
     $NGINX_INIT 2> /dev/null
     echo
     $PHP_FPM_INIT 2> /dev/null

     echo -e "\nLooks like we are done!"
   if [ $REMOTE == "y" ]; then
     echo -e "\nWeb Created for $DOMAIN for user $USERNAME with PHP support. Access the domain @ $DOMAIN"
     else
     echo -e "\nWeb Created for $LOCAL for user $USERNAME with PHP support. Access the domain @ $SERVER:$PORT"
   fi
     read -p "Press [Enter] key to return to main menu..."
     return
