#!/bin/bash

# config
. ./params_check.sh



export DIAG_DEST=`$ORACLE_HOME/bin/sqlplus -S "$oracle_user/$oracle_pass@$instance_name" << EOF
set heading off;
set feedback off;
set pagesize 0;
set tab off;
select value from v\\$parameter where name='diagnostic_dest';
exit;
EOF`

export DB_UNIQ_NAME=`$ORACLE_HOME/bin/sqlplus -S "$oracle_user/$oracle_pass@$instance_name" << EOF
set heading off;
set feedback off;
set pagesize 0;
set tab off;
select value from v\\$parameter where name='db_unique_name';
exit;
EOF`

export LWC_ORA_SID=`echo $ORACLE_SID | awk '{print tolower($0)}'`; 

export alert_file=$DIAG_DEST/diag/rdbms/$DB_UNIQ_NAME/$ORACLE_SID/trace/alert_$LWC_ORA_SID.log

echo $alert_file

############################################################
## MAIN CODE                                              ##
############################################################
echo 'send_oracle_log.sh start ...'
host=`hostname`


output=`tail -100 $alert_file`

tail -1000 $alert_file > ./alert_log.log

$sendmail -t << EOF
To: $mailto_info
From: $host
Subject: ORA_CHECKER Host: $host_desc Inst: $instance_name OK

This is alert log
---------------------------------------------
$output
---------------------------------------------

EOF


echo 'send_oracle_log.sh finish!'
echo '----------------------'
echo '  '
exit 0
