#!/bin/bash
# ASAS 2.10
# @author: GCornell for devCU Software
# @contact: support@devcu.com
# Compatibility: Debian Core Systems (Tested on Ubuntu 14x-16x-17x & Debian 8/9)
# MAIN: https://www.devcu.com
# CODE: https://github.com/GaalexxC/ASAS
# REPO: https://www.devcu.net
# License: GNU General Public License v3.0
# Created:   06/15/2016
# Updated:   09/25/2017
# --------------START SOURCES
set -o allexport
source variables.conf
source functions.sh
# --------------END SOURCES

asd() {
cat <<"EOT"

    .-"^`\                                        /`^"-.
  .'   ___\                                      /___   `.
 /    /.---.                                    .---.\    \
|    //     '-.  ___________________________ .-'     \\    |
|   ;|         \/--------------------------//         |;   |
\   ||       |\_)      devCU Software      (_/|       ||   /
 \  | \  . \ ;  |         Presents         || ; / .  / |  /
  '\_\ \\ \ \ \ |                          ||/ / / // /_/'
        \\ \ \ \| Auto Server Admin Script |/ / / //
         `'-\_\_\         ASAS 2.10        /_/_/-'`
                '--------------------------'
EOT
}

asd

    echo -e "\nWelcome to Auto Server Admin Script [ASAS] 2.10\n"

    echo -e "Installer Version: ${CYAN}$INSTALLER_VERSION${NOCOL}"
    echo -e "Installer Revision: ${CYAN}$INSTALLER_REVISION${NOCOL}"
    echo -e "Installer MD5: ${CYAN}$INSTALLER_MD5${NOCOL}\n"
    sleep 1

    echo "*******************************************************************"
    echo "*       Licensed under the GNU General Public License v3.0        *"
    echo "* You are permitted to use this script for commercial and private *"
    echo "* use. You may modify, distribute, and use this application for   *"
    echo "* patent use. This program comes with ABSOLUTELY NO WARRANTY      *"
    echo "* and we assume NO LIABILITY. Use at your own risk.               *"
    echo "*******************************************************************"

    updateSources
    echo
    echo
    read -p "Press [Enter] to begin system check..."

    whiptailCheckInstall
    validateRoot
    systemDetect
    #updateSources
    systemUpdate

clear

while [ 1 ]
do
MAINNU=$(
NEWT_COLORS='
  root=,blue
  window=,lightgray
  border=,white
  listbox=black,lightgray
  actlistbox=black,yellow
  shadow=,gray
  button=lightgray,gray
' \
whiptail --title "Auto Server Installer 2.10" --menu "\nSelect the function you want to perform" 20 80 10 \
        "1)" "Nginx Installer (Stable/Mainline/Compiled)"   \
        "2)" "PHP Installer (PHP5 - PHP7)"  \
        "3)" "MySQL Installer (Percona-MariaDB-Oracle)" \
        "4)" "Bind9 DNS Installer (Configure-Secure)" \
        "5)" "vsFTPd Installer (Configure-Secure)" \
        "6)" "Mail Server Installer (Postfix-Dovecot)" \
        "7)" "Quick Web User & Domain Setup" \
        "8)" "Security Tools" \
        "9)" "System Tools" \
       "10)" "Exit"  3>&2 2>&1 1>&3
)

case $MAINNU in
        "1)")
                nginxCheckInstall
        ;;

        "2)")
                phpCheckInstall
        ;;

        "3)")
                mysqlCheckInstall
        ;;

        "4)")
                bindCheckInstall
        ;;

        "5)")
                vsftpdCheckInstall
        ;;

        "6)")
                emailCheckInstall
        ;;

        "7)")
                #clientCheckInstall
                source scripts/user_domain.sh
        ;;

        "8)")
                #kernelCheckInstall
                source scripts/security_tools.sh
        ;;

        "9)")
                #toolsCheckInstall
                source scripts/system_tools.sh
        ;;

        "10)")   exit

        ;;
esac

done
exit
