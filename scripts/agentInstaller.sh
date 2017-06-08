#!/bin/bash


# get_osflavor(){

#     if [[ -f "/etc/lsb-release" ]]
#         then
#             os="ubuntu"
#             fileAgentController="agent_controller_ubuntu.sh"
#         elif [[ -f "/etc/redhat-release" ]]
#         then
#             os="rpm"
#         elif [[ -f "/etc/debian_version" ]]
#         then
#             os="debian"
#         else
#             #echo "ERROR: Cannot get the system type. Aborting entire process."
#             os="unknown"
#             #exit 1
#     fi
  


# }



create_InfraGuardDirectories(){
    echo "Creating directories in /opt ..."
    exec="mkdir -p /opt/infraguard/sbin"
    $exec

    exec="mkdir -p /opt/infraguard/etc"
    $exec

    exec="mkdir -p /var/logs/infraguard"
    $exec

    exec="touch  /var/logs/infraguard/activityLog"
    $exec


   
    exec="chmod 700 -R /opt/infraguard"
    $exec
    exec="chown root:root /opt/infraguard"
    $exec


    exec="chmod 700 -R /var/logs/infraguard"
    $exec
    exec="chown root:root /var/logs/infraguard"
    $exec

    echo "completed Directories Creation"


}


# install_daemon(){
#     echo 'Attempting Daemon Installation'
#     cd /tmp
#     if [[ "$os" = "debian"  || "$os" = "ubuntu" ]]
#         then
#         wget -q https://github.com/terminalcloud/terminal-tools/raw/master/daemon_0.6.4-2_amd64.deb || exit -1
#         dpkg -i daemon_0.6.4-2_amd64.deb
#         echo "Daemon Installation Done Successfully on debian/ununtu"
#     else
#         wget -q http://libslack.org/daemon/download/daemon-0.6.4-1.x86_64.rpm || exit -1
#         rpm -i daemon-0.6.4-1.x86_64.rpm
#         echo "Daemon Installation Done Successfully on rpm"
#     fi
# }

getLinuxType(){

   filename="/opt/infraguard/etc/linuxDistroInfo.txt" 
   cat /etc/*-release > $filename
   
   while IFS= read -r line; do

      if [[ $line == *"ID_LIKE"* ]]; then
         echo "$line"
         
         if [[ $line == *"debian"* ]]; then
            os="debian"
            fileAgentController="agent_controller_ubuntu.sh"
         fi

         if [[ $line == *"rhel"* ]]; then
            os="rhel"
         fi

        break;

      fi

  done < "$filename"


}


installAgent() {
    
    echo "Downloading $fileAgentController  > This file will act as a process"
    local url="wget -O /tmp/$fileAgentController https://raw.githubusercontent.com/agentinfraguard/agent/master/scripts/$fileAgentController"
    wget $url--progress=dot $url 2>&1 | grep --line-buffered "%" | sed -u -e "s,\.,,g" | awk '{printf("\b\b\b\b%4s", $2)}'
    command="mv /tmp/$fileAgentController  /etc/init.d"
    $command
      
   
    exec="chown root:root /etc/init.d/$fileAgentController"
    $exec
    exec="chmod 700 /etc/init.d/$fileAgentController"
    $exec


    echo "create  /tmp/serverInfo.txt with following data $serverName:$projectId:$licenseKe >> It will remove after server regn."
    echo "$serverName:$projectId:licenseKey" > /tmp/serverInfo.txt


    echo ""
    echo "Downloading infraGuardMain executable. It will take time. Please wait...."
    url="wget -O /opt/infraguard/sbin/infraGuardMain https://raw.githubusercontent.com/agentinfraguard/agent/master/go/src/agentController/infraGuardMain"
    
    #url="wget -O /opt/infraguard/sbin/infraGuardMain https://raw.githubusercontent.com/agentinfraguard/agent/master/go/src/test/infraGuardMain"
    wget $url--progress=dot $url 2>&1 | grep --line-buffered "%" | sed -u -e "s,\.,,g" | awk '{printf("\b\b\b\b%4s", $2)}'
    echo "infraGuardMain downloaded."
    
    
    exec="chown root:root /opt/infraguard/sbin/infraGuardMain"
    $exec
    exec="chmod 700 /opt/infraguard/sbin/infraGuardMain"
    $exec


    echo ""
    echo "Downloading property file i.e agentConstants.txt ...."
    url="wget -O /opt/infraguard/etc/agentConstants.txt https://raw.githubusercontent.com/agentinfraguard/agent/master/go/src/agentConstants.txt"
    wget $url--progress=dot $url 2>&1 | grep --line-buffered "%" | sed -u -e "s,\.,,g" | awk '{printf("\b\b\b\b%4s", $2)}'
    echo "agentConstants.txt downloaded."
   

    exec="chown root:root /opt/infraguard/etc/agentConstants.txt"
    $exec
    exec="chmod 700 /opt/infraguard/etc/agentConstants.txt"
    $exec


     if [[ "$os" = "debian" ]] ;then
            echo " ------- going to call  update-rc.d for agent_controller.sh --------"
            update-rc.d $fileAgentController defaults
     else
            echo " ------- going to call  chkconfig for  $fileAgentController ----------"
            chkconfig --add /etc/init.d/$fileAgentController
            #chkconfig --level 2345 /etc/init.d/$fileAgentController on 
            echo " ------- After --add Command --------"
     fi


    export start="start"
    export command="/etc/init.d/$fileAgentController"
     echo " ------- Going to start service $command ${start} --------"    
    sh $command ${start}

   
    } # downloadFiles_FromGitHub


    checkUserPrivileges(){
        if [ `id -u` -ne 0 ] ; then
            echo "error: requested operation requires superuser privilege"
            exit 1
        fi
    }


# Check whether agent already is running or not. If yes, then abort further process.

echo "Checking whether agent already installed/running or not."
pId=$(ps -ef | grep 'infraGuardMain' | grep -v 'grep' | awk '{ printf $2 }')
file="/opt/infraguard/sbin/infraGuardMain"

if [ -f "$file" ]
  then
    echo "Agent exe file found at $file "

    if [ -z "$pId" ] ; then
        echo "Agent is stopped."
    else
        echo "Agent is running. Process id is $pId"
    fi

  echo "Abort further process."
  exit 1

   
fi


if [ $# -ne 3 ] ; then
    echo "182. Insufficient arguments. Usage: $0 serverName projectId licenseKey"
    exit 1
fi

 


checkUserPrivileges
# Read arguments, it will saved into /tmp/serverInfo.txt & then serverMgmt/ServerHandler.go will read.
serverName=$1
projectId=$2
licenseKey=$3

os=""
fileAgentController="agent_controller.sh"
#get_osflavor
#install_daemon

create_InfraGuardDirectories
getLinuxType
echo "------------  Linux Type = : $os  ----------------"
installAgent






