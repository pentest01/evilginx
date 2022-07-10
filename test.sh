
#!/usr/bin/env bash
# Version         : 3.0
# Created date    : 12/09/2019
# Last update     : 07/05/2022
# Author          : pentest.01
# Description     : Automated script to install evilginx with letsencrypt


if [ "$EUID" -ne 0 ]
  then echo "${blue}${bold}[*] Script must be run as root...${clear}"
  exit
fi


### Colors
red=`tput setaf 1`;
green=`tput setaf 2`;
yellow=`tput setaf 3`;
blue=`tput setaf 5`;
magenta=`tput setaf 4`;
cyan=`tput setaf 6`;
bold=`tput bold`;
clear=`tput sgr0`;

banner() {
cat <<EOF
${blue}${bold}
             _ _       _            
            (_) |     (_)           
   _____   ___| | __ _ _ _ __ __  __
  / _ \ \ / / | |/ _` | | '_ \\ \/ /
 |  __/\ V /| | | (_| | | | | |>  < 
  \___| \_/ |_|_|\__, |_|_| |_/_/\_\
                  __/ | {pentest.01}         
                 |___/              
        /|
       / |   /|        in God i trust
   <===  |=== | --------------------------------
       \ |   \|
        \|
${clear}
EOF

}

usage() {
  local ec=0

  if [ $# -ge 2 ] ; 
    then
    ec="$1" ; shift
    printf "%s\n\n" "$*" >&2
  fi

  banner
  cat <<EOF
A quick Bash script to install Evilginx server. 
${bold}Usage: ${blue}./$(basename $0) [-e] [-d <domain name> ] [-c] [-h]${clear}
One shot to set up:
  - Evilginx Server
  - Evilxinx Server
  - SSL Cert for Phishing Domain (LetsEncrypt)
Options:
  -e        Setup Email Phishing Gophish Server
  -d <domain name>      SSL cert for phishing domain
         ${red}${bold}[WARNING] Configure 'A' record before running the script${clear}
  -c        Cleanup for a fresh install
  -h                 This help menu
Examples:
  ./$(basename $0) -e               Setup Evilginx
  ./$(basename $0) -d <domain name>       Configure SSL cert for your phishing Domain
  ./$(basename $0) -e -d <domain name>       Evilginx + SSL cert for Phishing Domain
EOF

exit $ec
 
}

### Exit
exit_error() {
   usage
   exit 1
}


echo
sleep 4


### Initial Update & Dependency Check
dependencyCheck() {
   ### Update Sources
   echo "${blue}${bold}[*] Updating source lists...${clear}"
   hwclock --hctosys 
   apt update ; apt-get -y upgrade ; apt-get -y dist-upgrade ; apt-get -y autoremove ; apt-get -y autoclean ; echo
   
   echo
   sleep 4
      
   ### Checking/Installing go
   gocheck=$(which go)

   if [[ $gocheck ]];
     then
      echo "${green}${bold}[+] Golang already installed${clear}"
   else
      echo "${blue}${bold}[*] Installing Golang...${clear}"
      apt install golang-go -y
   fi
   
   echo
   sleep 4

   ### Checking/Installing git
   make=$(which make)

   if [[ $make ]];
     then
      echo "${green}${bold}[+] Make already installed${clear}"
   else
      echo "${blue}${bold}[*] Installing Make...${clear}"
      apt-get install make -y
   fi

   echo
   sleep 4
   
   
}


### Setup Evilginx
setupEmail() {
   ### Cleaning Port 80
   lsof -t -i tcp:80 | xargs kill
   
 #  ufw disable
   
   ### Deleting Previous Gophish Source (*Need to be removed to update new rid)
   rm -rf /opt/evilginx2/
   echo
   sleep 3
   
   echo "${blue}${bold}[*] Creating Evilginx folder: /opt/evilginx${clear}"
   mkdir -p /opt/evilginx

   echo
   sleep 3
     
   ### Installing Evilginx
   if [ -d /opt/evilginx/.git ]; then
      echo -e "${blue}${bold}[*] Updating Evilginx....."
      cd /opt/evilginx; git pull
      echo
    else
      echo -e "${blue}${bold}[*] Downloading Evilginx...${clear}"
      git clone https://github.com/eth3real/evilginx2.git /opt/evilginx2
      echo
   fi

   sleep 2

#   # Stripping Evilginx 

# check what we are about to remove
      sed -n -e '183p;350p;377,379p;381p;407p;562,566p;580p;1456,1463p' core/http_proxy.go
      
# remove + backup original
      sudo sed -i.bak -e '183d;350d;377,379d;381d;407d;562,566d;580d;1456,1463d' core/http_proxy.go

      cd /opt/evilginx2 && make && make install
      
}

### Setup SSL Cert
letsEncrypt() {
   ### Clearning Port 80
   lsof -t -i tcp:80 | xargs kill
  
         
   ### Installing certbot-auto
   certbot=$(which certbot)

	if [[ $certbot ]];
	  then
	   echo "${green}${bold}[+] Certbot already installed${clear}"
	else
	   echo "${blue}${bold}[*] Installing Certbot...${clear}"
	   apt-get install certbot -y >/dev/null 2>&1
	fi

echo 

   ### Installing SSL Cert 
   echo "${blue}${bold}[*] Installing SSL Cert for $domain...${clear}"
   
   ### Manual
   #./certbot-auto certonly -d $domain --manual --preferred-challenges dns -m example@gmail.com --agree-tos && 
   ### Auto
   certbot certonly --manual --server https://acme-v02.api.letsencrypt.org/directory --agree-tos --email example@edumail.icu --preferred-challenges dns -d $domain 

   echo "${blue}${bold}[*] Configuring New SSL cert for $domain...${clear}"
   cp /etc/letsencrypt/live/$domain/fullchain.pem /root/.evilginx/crt/fullchain.pem &&
   cp /etc/letsencrypt/live/$domain/privkey.pem /root/.evilginx/crt/privkey.pem 
   systemctl stop systemd-resolved

   echo
}


      #check open ports
      lsof -nP -iTCP -sTCP:LISTEN
      echo
   else
      exit 1
   fi

cleanUp() {
   echo "${green}${bold}Cleaning...1...2...3...${clear}"
   rm -rf /opt/evilginx2/ 2>/dev/null
   rm /etc/letsencrypt/keys/* 2>/dev/null
   rm /etc/letsencrypt/csr/* 2>/dev/null
   rm -rf /etc/letsencrypt/archive/* 2>/dev/null
   rm -rf /etc/letsencrypt/live/* 2>/dev/null
   rm -rf /etc/letsencrypt/renewal/* 2>/dev/null
   rm -rf /etc/letsencrypt/  2>/dev/null
   echo "${green}${bold}[+] Done!${clear}"
}

domain=''
rid=''

while getopts ":r:esd:ch" opt; do
   case "${opt}" in
      e)
         banner
         dependencyCheck
         setupEmail ;;
      d) 
         domain=${OPTARG} 
         letsEncrypt && 
         evilginx ;;
      c)
         cleanUp ;;
      h | * ) 
         exit_error ;;
      :) 
         echo "${red}${bold}[-] Error: -${OPTARG} requires an argument (e.g., -e or -d domain.com)${clear}" 1>&2
         exit 1;;
   esac
done

if [[ $# -eq 0 ]];
  then
   exit_error
fi
