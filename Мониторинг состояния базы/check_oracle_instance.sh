#! /bin/bash

# -----------------------------------------------------------------------
# Filename:   check_oracle_instance.sh
# Purpose:    Check if DB's background processes are started
# Author:     Sergey Brazgin
# -----------------------------------------------------------------------

# config
. ./params_check.sh

# ----------------------------------------------------------------------------------------
send() {
  mailTitle=$1
  mailText=$2 
  host=`hostname`

$sendmail -t << EOF
To: ${mailto}
From: ${host}
Subject: ${mailTitle}
${mailText}
`date`

EOF

echo 'check_oracle_instance.sh send mail with Error!'

}
# ----------------------------------------------------------------------------------------

############################################################
## MAIN CODE                                              ##
############################################################
echo 'check_oracle_instance.sh start ...'

FAILED=0; 
INSTANCEDOWN=0 

	for PROCESS in pmon smon 
	do
	  RC=$(ps -ef | egrep ${instance_name} | egrep -v 'grep' | egrep ${PROCESS}) 
	  if [ "${RC}" = "" ] ; then
	    INSTANCEDOWN=1 
	  fi 
	done
        if [ ${INSTANCEDOWN} = "1" ] ; then
	   echo "`date` - Instance ${instance_name} is DOWN!!!\n" 
          send  "Host: ${host_desc} Instance: ${instance_name} error!"  "Instance ${instance_name} ${PROCESS} down! " 
          echo " check_oracle_instance.sh   Instance ${instance_name} ${PROCESS} down! "  >> ./check.log
	   FAILED=1
	else 
	   echo "`date` - Instance ${instance_name} is running.\n" 
	fi	

if [ ${FAILED} = "1" ] ; then
  echo 'check_oracle_instance.sh finish with Error!'
  echo '----------------------'
  echo '  '
  exit -1
else
  echo 'check_oracle_instance.sh finish with OK!'
  echo '----------------------'
  echo '  '
  exit 0
fi
