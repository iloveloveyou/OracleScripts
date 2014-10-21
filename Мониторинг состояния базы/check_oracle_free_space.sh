#!/bin/bash

############################################################
## MAIN CODE                                              ##
############################################################
echo 'check_oracle_free_space.sh start ...'

# config
. ./params_check.sh

LOGFILE='check_oracle_free_space.log'

rm -rf $LOGFILE

output=`sqlplus -s "$oracle_user/$oracle_pass@$instance_name" <<EOF
           spool $LOGFILE
           @@check_oracle_free_space.sql;
           exit;
EOF
`

#echo $output

if grep 'TABLESPACE' $LOGFILE
then
     cat $LOGFILE 

     mailx -s "tablespace size Warning! $host_desc" $mailto < $LOGFILE

     echo 'check_oracle_free_space.sh finish with Warning!'
     echo '----------------------'
     echo '  '
     echo " check_oracle_free_space.sh    Warning!  " >> ./check.log

     exit -1
else

     echo 'check_oracle_free_space.sh finish with OK!'
     echo '----------------------'
     echo '  '
     exit 0

fi

