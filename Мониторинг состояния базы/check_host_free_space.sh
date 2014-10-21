#!/bin/sh
 
# config
threshold1=90
threshold2=97
threshold3=95
. ./params_check.sh



############################################################
send() {
  i=$1
  host=`hostname`
  threshold=$2
  strFreeSpace=`echo $i | awk '{print $4, $5}'`
#  echo $strFreeSpace
  $sendmail -t << EOF
To: $mailto
From: $host space monitor
Subject: $host $3 free space alert: ($threshold)
On $host:`echo $i | awk '{print $6}'` not enough space left ($strFreeSpace) 
$host_desc

EOF

#echo 'check_host_free_space.sh sending Error mail:'
#echo $host $i $strFreeSpace
#echo '-------'

echo " check_host_free_space.sh   $host $i $strFreeSpace  "
echo " check_host_free_space.sh   $host $i $strFreeSpace  " >> ./check.log

}
 
############################################################
## MAIN CODE                                              ##
############################################################
echo 'check_host_free_space.sh start ...'
df -Ph | grep '/oracle\|/u01\|/u02\|/u03\|/u04\|/home\|/$' | while read i; do
#echo $i | awk '{print $5}'


  if [ `echo $i | awk '{print $5}' | cut -d'%' -f1` -ge $threshold3 ] ; then
    send "$i" $threshold3 "ALERT!"
  elif [ `echo $i | awk '{print $5}' | cut -d'%' -f1` -ge $threshold2 ] ; then
    send "$i" $threshold2 "Alert"
  elif [ `echo $i | awk '{print $5}' | cut -d'%' -f1` -ge $threshold1 ] ; then
    send "$i" $threshold1 "Warning"
  fi
done;

echo 'check_host_free_space.sh finish'
echo '----------------------'
echo '  '
