#/bin/bash

# Settings
version="1.1"
program_longname="Linux Atom Updater"
program_shortname="atomupdater"

# Colors
white="\033[1;37m"
grey="\033[0;37m"
purple="\033[0;35m"
red="\033[1;31m"
green="\033[1;32m"
yellow="\033[1;33m"
blue="\033[1;34m"
transparent="\e[0m"

function version(){
  printf $version"\n"
  exit 1
}

# Use RPM or DEB?
if [ -x "$(command -v dpkg)" ]; then
    package_type="deb"
fi
if [ -x "$(command -v rpm)" ]; then
    package_type="rpm"
fi

# Figure out which package manager to use
package_manager=""
declare -A osInfo;
osInfo[/etc/redhat-release]=yum
osInfo[/etc/arch-release]=pacman
osInfo[/etc/gentoo-release]=emerge
osInfo[/etc/SuSE-release]=zypp
osInfo[/etc/debian_version]=apt-get
for f in ${!osInfo[@]}
do
    if [[ -f $f ]];then
        package_manager=${osInfo[$f]}
    fi
done

function banner(){
echo -e "$blue
     _        _   _   _
    | |      / \ | | | |
    | |     / _ \| | | |
    | |___ / ___ \ |_| |
    |_____/_/   \_\___/
$transparent
  ["$red"$program_longname "$blue"v$version"$transparent"]
      ["$red"By Jordan Hillis"$transparent"]
  ["$red"contact@jordanhillis.com"$transparent"]
______________________________
"
}

function install_program(){
  force_lua_update=false
  if [ -e /usr/local/sbin/$program_shortname ]; then
    lua_installed_version=$(/usr/local/sbin/$program_shortname -v | awk '{printf $0}')
    if [ $version != $lua_installed_version ]; then
      printf "[*] New version of "$blue"$program_longname"$transparent" (Installed: $lua_installed_version | New: $version).\n"
      printf "[*] Installing update...\n"
      force_lua_update=true
    fi
  fi
  if [ ! -f /usr/local/sbin/$program_shortname ] || [ $force_lua_update == true ]; then
    cp $(basename $0) /usr/local/sbin/$program_shortname
    chmod +x /usr/local/sbin/$program_shortname
    printf "[*] Installed program to "$blue"/usr/local/sbin"$transparent"\n"
    printf "[*] Run the command \""$blue"$program_shortname"$transparent"\" to begin using this program.\n\n"
    exit 1
  fi
}

function uninstall_program(){
  if [ -e /usr/local/sbin/$program_shortname ]; then
    printf "[*] Uninstalling "$blue"$program_longname"$transparent"...\n"
    rm -f /usr/local/sbin/$program_shortname
    printf "[*] Removed from system.\n\n"
    exit 1
  else
    printf "[*] This program is not installed on the system.\n\n"
    exit 1
  fi
}

function check_requirements(){
    # Check if user is root
    if [[ $EUID -ne 0 ]]; then
       printf $red"[*]"$transparent" This program must be run as root.\n\n"
       exit 1
    fi
    if [[ -z "$package_type" ]]; then
      printf $red"[*]"$transparent" It appears you are not on a Debian or Red Hat based distro. We cannot continue.\n\n"
      exit 1
    fi
    # Check if wget is installed
    if ! [ -x "$(command -v wget)" ]; then
      printf $red"[*]"$transparent" Error, wget does not appear to be installed.\n"
      printf "    Please install wget with the command 'sudo $package_manager install wget'\n\n"
      exit 1
    else
      if [ "$package_type" == "deb" ];then
          wget_version_current=$(dpkg -s wget | grep '^Version:' | awk '{print $2}')
      else
          wget_version_current=$(rpm -qi wget | grep '^Version' | awk '{print $3}')
      fi
      if [ "$(printf "1.16\n$wget_version_current" | sort -V | head -n1)" == "$wget_version_current" ] && [ "$wget_version_current" != "1.16" ]; then
          printf $red"[*]"$transparent" Error, wget version is currently $wget_version_current and it needs to be at least 1.16. Please update.\n\n"
          exit 1
      fi
    fi
    # Check if Atom is installed
    if ! [ -x "$(command -v atom)" ]; then
      printf $red"[*]"$transparent" Error, Atom does not appear to be installed.\n"
      read -r -p "[-] Would you like to install Atom? [y/N] " response
      case "$response" in
          [yY][eE][sS]|[yY])
              printf "[-] Downloading the latest Atom version...\n"
              wget -O /tmp/atom.$package_type https://atom.io/download/$package_type -q --show-progress
              printf "[*] Installing Atom...\n"
              if [ "$package_type" == "deb" ];then
                  dpkg -i /tmp/atom.$package_type
              else
                  yum localinstall /tmp/atom.$package_type
              fi
              printf "[*] Installation complete!\n"
              rm -f /tmp/atom.$package_type
              printf "\n    Enjoy!\n\n"
              ;;
          *)
              printf "\n    Exiting...Goodbye!\n\n"
              ;;
      esac
      exit 1
    fi
    # Check if cron is installed
    if ! [ -x "$(command -v crontab)" ]; then
      printf $red"[*]"$transparent" Error, cron does not appear to be installed.\n"
      printf "    Please install cron with the command 'sudo $package_manager install cron'\n\n"
      exit 1
    fi
}

function update_atom(){
    # Grab latest version from GitHub
    printf "[*] Checking for the latest version of Atom Editor released...\n"
    atom_version_latest=$(wget https://github.com/atom/atom/releases/latest -q -O - | grep -oE "<title>.*</title>" | sed 's/<title>//' | sed 's/<\/title>//' | awk '{printf $2}')
    if [ "$atom_version_latest" == "" ];then
        printf "[*] Error receiving the latest Atom Editor version. Retrying in 3 seconds...\n"
        update_atom
        exit 1
    fi
    if [ "$package_type" == "deb" ];then
        atom_version_current=$(dpkg -s atom | grep '^Version:' | awk '{print $2}')
    else
        atom_version_current=$(rpm -qi atom | grep '^Version' | awk '{print $3}')
    fi
    # Check current Atom version and compare it to the newest version downloaded
    if [ "$atom_version_current" == "$atom_version_latest" ]; then
        printf "[*] Atom appears to have the latest version installed! (v$atom_version_current)\n"
        printf "\n    Exiting...Goodbye!\n\n"
        exit 1
    fi
    printf "[-] Update found! (Latest: v$atom_version_latest) (Installed: v$atom_version_current)\n"
    printf "[-] Downloading the latest Atom version (v$atom_version_latest)...\n"
    wget -O /tmp/atom.$package_type https://atom.io/download/$package_type -q --show-progress
    printf "[-] Download complete.\n"
    printf "[-] Comparing installed version with downloaded version...\n"
    if [ "$package_type" == "deb" ];then
        atom_version_download=$(dpkg-deb -f /tmp/atom.deb Version)
    else
        atom_version_download=$(rpm -qip /tmp/atom.rpm | grep '^Version' | awk '{print $3}')
    fi
    printf "[-] Installed version: "$blue"$atom_version_current"$transparent"\n"
    printf "[-] Downloaded version: "$blue"$atom_version_download"$transparent"\n"
    if [ "$atom_version_current" == "$atom_version_download" ]; then
      printf "[*] Atom appears to have the latest version installed!\n"
      printf "[*] Removing downloaded \"atom.$package_type\" file..."
      rm -f /tmp/atom.$package_type
      printf "Done.\n"
      printf "\n    Exiting...Goodbye!\n\n"
      exit 1
    else
      printf "[*] Installing new version of Atom ($atom_version_download)...\n"
      if [ "$package_type" == "deb" ];then
          dpkg -i /tmp/atom.$package_type
      else
          yum localinstall /tmp/atom.$package_type
      fi
      printf "[*] Update complete!\n"
      printf "\n    Enjoy!\n\n"
    fi
}

function scheduler(){
    check_cron_exists=$(crontab -l | grep "$program_shortname")
    if [ -n "$check_cron_exists" ]; then
        cron_current=$(crontab -l | grep "$program_shortname" | sed "s/[^a-zA-Z']/ /g" | sed -e "s/\b\(.\)/\u\1/g" | awk '{print $1;}')
        read -r -p "[-] Would you like to remove the scheduled update? (Current: $cron_current) [y/N] " response
        case "$response" in
            [yY][eE][sS]|[yY])
                printf "[-] Removing the scheduled update from the system...\n"
                (crontab -l | grep -v "$program_shortname")| crontab -
                printf "[*] Successfully removed!\n"
                printf "\n    Enjoy!\n\n"
                ;;
            *)
                printf "\n    Exiting...Goodbye!\n\n"
                ;;
        esac
    else
        printf "[-] How often would you like Atom to check for updates and install them?\n    1) Daily\n    2) Weekly\n    3) Monthly\n\n  - Enter a number option above? "
        read -r -p "" response
        case "$response" in
            1)
                cron_time="daily"
                ;;
            2)
                cron_time="weekly"
                ;;
            3)
                cron_time="monthly"
                ;;
            *)
                printf "\n    Exiting...Goodbye!\n\n"
                exit 1
                ;;
        esac
        # Add the cronjob
        printf "\n[*] Adding scheduled update to the system...\n"
        (crontab -l ; echo "@$cron_time /usr/local/sbin/$program_shortname -u")| crontab -
        printf "[-] Scheduled $cron_time update added successfully!\n"
        printf "\n    Enjoy!\n\n"
    fi
}

function help_menu(){
  printf "Usage: $(basename $0) [OPTION]\n\n"
  printf "  -u,   --update        Updates Atom to the newest version\n"
  printf "  -s    --scheduler     Have Atom updated on a scheduled basis\n"
  printf "  -v,   --version       Shows current version of $program_longname\n"
  printf "  -r    --remove        Uninstall $program_longname from system\n"
  printf "\n"
}

if [ -z "$1" ]; then
    banner
    check_requirements
    install_program
    help_menu
    exit 1
fi
while true; do
    case "$1" in
        -u | --update )
            banner
            check_requirements
            install_program
            update_atom
            ;;
        -v | --version )
            version
            ;;
        -r | --remove )
           banner
           uninstall_program
           ;;
        -s | --scheduler )
           banner
           check_requirements
           install_program
           scheduler
           ;;
        -- ) ;;
        * ) if [ -z "$1" ]; then break; else banner; check_requirements; install_program; printf $red"$1 is not a valid option\n\n"$transparent; help_menu; exit 1; fi;;
    esac
    shift
done
