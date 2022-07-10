#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "[*] Script must be run as root"
  exit
fi

cat << "EOF"
                                                _                
                                    _ __  _   _| |__   ___ _ __  
                                   | '_ \| | | | '_ \ / _ \ '_ \ 
                                   | | | | |_| | |_) |  __/ | | |
                                   |_| |_|\__, |_.__/ \___|_| |_|
                                          |___/                  
                                       -Script by pentest.01-
EOF

echo

# Do not use this script for assisting in illegal activity, I take no responsibility in your actions.
echo -e "\e[1m" "\e[31m[*] Do not use this script for assisting in illegal activity, I take no responsibility in your actions."
echo

### Initial Update & Dependency Check
echo -e "\e[1m" "\e[31m[*] Updating OS."
hwclock --hctosys
apt update ; apt-get -y upgrade ; apt-get -y dist-upgrade ; apt-get -y autoremove ; apt-get -y autoclean ; echo

echo
sleep 3
    
### Checking/Installing go
gocheck=$(which go)

if [[ $gocheck ]];
  then
  echo -e "\e[1m" "\e[32m[*] Golang already installed...\e[0m"
else
  echo -e "\e[1m" "\e[31m[*] Installing Golang ...\e[0m"
  apt install golang-go -y
fi
   
echo
sleep 3
   
### Checking/Installing make
make=$(which make)

if [[ $make ]];
then
  echo -e "\e[1m" "\e[32m[*] Make already installed...\e[0m"
else
  echo -e "\e[1m" "\e[31m[*] Installing Make...\e[0m"
  apt-get install make -y
fi

echo
sleep 3 

echo -e "\e[1m" "\e[33m[*] Creating evilginx folder: /opt/evilginx...\e[0m"
mkdir -p /opt/evilginx2

echo
sleep 3
   
#####

echo

 if [ -d /opt/Phishing/evilginx2/.git ]; then
   echo -e "\e[1m" "\e[32m[+] Updating evilginx2.....\e[0m"
   cd /opt/evilginx2; git pull
   echo
 else
   echo -e "\e[1m" "\e[31m[+] Downloading evilginx2.....\e[0m"
   git clone https://github.com/pentest01/evilginx2.git /opt/evilginx2
   
# check what we are about to remove
   sed -n -e '183p;350p;377,379p;381p;407p;562,566p;580p;1456,1463p' /opt/evilginx2/core/http_proxy.go
      
# remove + backup original
   sudo sed -i.bak -e '183d;350d;377,379d;381d;407d;562,566d;580d;1456,1463d' /opt/evilginx2/core/http_proxy.go

  cd /opt/evilginx2 && make && make install && cd
   echo
 fi

 echo
