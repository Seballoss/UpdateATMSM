#!/usr/bin/env bash
source $HOME/.env
while [ 1 ];
do
(
date
status=$(ssh  $ip_srv -p $port_srv 'export name_mach='$(uname -n)' && ./check_status' | sed -n '2p')
stat="Reboot"
stat1="Rebooting"
stat2="LostConnection"
stat3="Update"
stat4="Screenshot"
stat5="RestartTMV"
stat6="SendLogs"
stat7="FullLogs"
stat8="ClearSystem"
stat9="RemoveLogs"
name_mach=$(uname -n)
echo $status;
if [ $status == $stat ];then
  ssh  $ip_srv -p $port_srv 'export stat='Rebooting' && export name_mach='$(uname -n)' && ./exc'
  echo "System is rebooting"
  sudo reboot
fi
if [ $status == $stat1 ] || [ $status == $stat2 ];then
  ssh  $ip_srv -p $port_srv 'export stat='PowerON' && export name_mach='$(uname -n)' && ./exc'
  echo "Change status to PowerON"
  ssh  $ip_srv -p $port_srv 'export uptimer='$(uptime -s)' && export name_mach='$(uname -n)' && ./uptime.sh' &>/dev/null
fi
if [ $status == $stat3 ];then
  ssh  $ip_srv -p $port_srv 'export stat='Updating' && export name_mach='$(uname -n)' && ./exc'
  cd $HOME/
  sudo rm -R UpdateATMSM/
  git clone https://github.com/Seballoss/UpdateATMSM
  cd UpdateATMSM/
# git pull origin master
  bash update
  version=$(cat $HOME/UpdateATMSM/version)
  ssh  $ip_srv -p $port_srv 'export ver='$version' && export name_mach='$(uname -n)' && ./ver'
  ssh  $ip_srv -p $port_srv 'export stat='PowerON' && export name_mach='$(uname -n)' && ./exc'
fi
if [ $status == $stat4 ];then
  gnome-screenshot
#  mv $HOME/Pictures/Screenshot* $HOME/Pictures/Screenshot_$HOSTNAME_$(date +%H_%M_%d_%m).png
  mv $HOME/Pictures/Screenshot* $HOME/Pictures/Screenshot_$HOSTNAME.png
  convert -resize 580x170 $HOME/Pictures/Screenshot_$HOSTNAME.png $HOME/Pictures/Screenshot_$HOSTNAME.png
  scp -i $HOME/.ssh/id_rsa $HOME/Pictures/Screenshot_$HOSTNAME.png $ip_srv:/var/www/html/img
  ssh  $ip_srv -p $port_srv 'export stat='PowerON' && export name_mach='$(uname -n)' && ./exc'
  rm $HOME/Pictures/Screenshot*
fi
if [ $status == $stat5 ];then
  sudo teamviewer --daemon restart
  ssh  $ip_srv -p $port_srv 'export stat='PowerON' && export name_mach='$(uname -n)' && ./exc'
fi
if [ $status == $stat6 ];then
  ssh  $ip_srv -p $port_srv 'export stat='SendingLogs' && export name_mach='$(uname -n)' && ./exc'
  tail -n 300000 /var/log/JCMconverter.log >> $HOME/jcmcheck_$(uname -n).log
  scp $HOME/jcmcheck_$(uname -n).log $ip_srv:/root/logs/$(uname -n)
  rm $HOME/jcmcheck_$(uname -n).log
  tail -n 300000 /var/log/lamassu-machine.log >> $HOME/lamacheck_$(uname -n).log
  scp $HOME/lamacheck_$(uname -n).log $ip_srv:/root/logs/$(uname -n)
  rm $HOME/lamacheck_$(uname -n).log
  ssh  $ip_srv -p $port_srv 'export stat='PowerON' && export name_mach='$(uname -n)' && ./exc'
fi
if [ $status == $stat7 ];then
  ssh  $ip_srv -p $port_srv 'export stat='SendingFullLogs' && export name_mach='$(uname -n)' && ./exc'
  cp /var/log/JCMconverter.log $HOME/jcmcheck_$(uname -n)_Full.log
  scp $HOME/jcmcheck_$(uname -n)_Full.log $ip_srv:/root/logs/$(uname -n)
  rm $HOME/jcmcheck_$(uname -n)_Full.log
  cp /var/log/lamassu-machine.log $HOME/lamacheck_$(uname -n)_Full.log
  scp $HOME/lamacheck_$(uname -n)_Full.log $ip_srv:/root/logs/$(uname -n)
  rm $HOME/lamacheck_$(uname -n)_Full.log
  ssh  $ip_srv -p $port_srv 'export stat='PowerON' && export name_mach='$(uname -n)' && ./exc'
fi
if [ $status == $stat8 ];then
  ssh  $ip_srv -p $port_srv 'export stat='ClearingSystem' && export name_mach='$(uname -n)' && ./exc'
  sudo rm /var/lib/lamassu-machine/machine.log
  sudo rm /var/lib/lamassu-machine/log/*
  sudo rm /var/lib/lamassu-machine/tx-db/*
  ssh  $ip_srv -p $port_srv 'export stat='PowerON' && export name_mach='$(uname -n)' && ./exc'
fi
if [ $status == $stat9 ];then
  ssh  $ip_srv -p $port_srv 'export stat='RemovingLogs' && export name_mach='$(uname -n)' && ./exc'
  sudo rm /var/log/JCMconverter.log
  sudo rm /var/log/lamassu-machine.log
  ssh  $ip_srv -p $port_srv 'export stat='PowerON' && export name_mach='$(uname -n)' && ./exc'
else
  ssh  $ip_srv -p $port_srv "echo $(uptime -s) > $name_mach"
  ssh  $ip_srv -p $port_srv 'export name_mach='$(uname -n)' && ./uptime.sh' &>/dev/null
  echo "Update uptime"
  ssh  $ip_srv -p $port_srv 'export stat='PowerON' && export name_mach='$(uname -n)' && ./exc'
fi
#bash $HOME/transfer_log
)
sleep 10s
done
