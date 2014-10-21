#!/bin/bash

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

}


############################################################
## MAIN CODE                                              ##
############################################################
echo 'check_oracle.sh start ...'

#echo "$oracle_user/$oracle_pass@$instance_name"

output=`sqlplus -s "$oracle_user/$oracle_pass@$instance_name" <<EOF
           set heading off feedback off verify off
           select * from global_name; 
           exit
EOF
`

#echo $output
#echo 'qwerty 1'

if [[ $output =~ ERROR ]]; then
     echo "Login to Oracle DB error: $oracle_user/$oracle_pass@$instance_name"
     send "Host: ${host_desc} Connect to Instance: ${instance_name} Error!" "Instance connect error ! \n $output" 
     echo " check_oracle.sh   Connect to Instance: ${instance_name} Error!  "  >> ./check.log
     echo 'check_oracle.sh finish with Error!'
     echo '----------------------'
     echo '  '
     exit -1
else
     echo 'check_oracle.sh finish with OK!'
     echo '----------------------'
     echo '  '
     exit 0
fi 