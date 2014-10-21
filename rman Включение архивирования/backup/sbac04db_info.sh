#!/bin/bash

########################################################################
# author: Sergey Brazgin     09.2014    OAO EM
# mail:   sbrazgin@gmail.com
# 
# 1) create backup/db_info.txt
# 2) create backup/rman_backup_info.txt
# 3) create backup/db_info2.txt
# 4) create backup/oraenv_db.sh
#
########################################################################


GEN_ERR=1  # something went wrong in the script
export path_to_config=`dirname $0`
cd $path_to_config
. ./oraenv.sh
export PATH_TO_BACKUP=`pwd`
export PATH_TO_BACKUP=${PATH_TO_BACKUP}/backup



#----------- create db_info.txt
LOGOUT=backup/db_info.txt

echo "select * from global_name;" > db_info1.sql 
echo "select dbid from v\$database;" >> db_info1.sql 

output=`sqlplus -s / as sysdba <<EOF
           spool $LOGOUT
           @db_info1.sql;
           exit;
EOF
`
if [ $? -ne 0 ]
then
  echo "Running sqlplus FAILED"
  exit ${GEN_ERR}
fi



#----------- create rman_backup_info.txt
export NLS_DATE_FORMAT='DD-MON-YY HH24:MI:SS'
echo " list backup; " > db_info2.rman
rman target / cmdfile db_info2.rman log ${PATH_TO_BACKUP}/rman_backup_info.txt

if [ $? -ne 0 ]
then
  echo "Running rman FAILED"
  exit ${GEN_ERR}
fi



#------------  get dbid value
LOGOUT=backup/db_info2.txt

echo "set verify off" > db_info3.sql 
echo "set heading off " >> db_info3.sql  
echo "set echo off " >> db_info3.sql  
echo "set head off" >> db_info3.sql  
echo "set verify off" >> db_info3.sql  
echo "set feedback off" >> db_info3.sql  
echo "select dbid from v\$database; " >> db_info3.sql  


output=`sqlplus -s -l / as sysdba <<EOF
      spool $LOGOUT
      @db_info3.sql;
      exit;
EOF
`

if [ $? -ne 0 ]
then
  echo "Running sqlplus FAILED"
  exit ${GEN_ERR}
fi

if [ -z "${output}" ] # check if  empty
then
  echo "No Database ID were found"
  exit ${GEN_ERR}
fi

#remove carriage return and newline from a variable
output=$(echo $output | sed -e 's/\r//g')

echo "output = $output"


# create oraenv
echo "export ORACLE_SID=${ORACLE_SID}" > ${PATH_TO_BACKUP}/oraenv_db.sh
echo "export ORACLE_DBID=${output}" >> ${PATH_TO_BACKUP}/oraenv_db.sh


