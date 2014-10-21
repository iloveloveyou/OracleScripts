#!/bin/bash 


########################################################################
# author: Sergey Brazgin      09.2014
# mail:   sbrazgin@gmail.com
# 
# 1) recover
# 2) rename online logs
# 3) open database
########################################################################

logoutput()
{
   while read line
   do
	if [[ $line == *RENAME* ]]
	then
	      echo "$line" >> $SQLFILE2
	fi
   done
}



#------------------- START

GEN_ERR=1  # something went wrong in the script
export path_to_config=`dirname $0`
cd $path_to_config
export PATH_TO_BACKUP=`pwd`


export LOGFILE="sbacRest04restore1.log"
chmod u+x ./oraenvRestDB.sh
. ./oraenvRestDB.sh



echo -n "1. Create script for rename online logs  ...             "

export LOGFILE="t05open1.log"
export RMANFILE="t05open1.rman"
export SQLFILE1="t05open1.sql"
export SQLFILE2="t05open2.sql"

echo "set linesize 200"   > $SQLFILE1
echo "set pagesize 200"   >> $SQLFILE1
echo "set verify off "    >> $SQLFILE1
echo "set heading off "   >> $SQLFILE1
echo "set echo off "      >> $SQLFILE1
echo "set head off"       >> $SQLFILE1
echo "set verify off"     >> $SQLFILE1
echo "set feedback off "  >> $SQLFILE1
echo "SELECT 'ALTER DATABASE RENAME FILE '''||MEMBER||''' to ''${DB_RESTORE_DIR}/data/'|| substr(member,instr(member,'/',-1)+1)||''';' as command FROM V\$LOGFILE;   " >> $SQLFILE1
echo "union all "  >> $SQLFILE1
echo "select 'alter database RENAME file '''||name||'''  to ''${DB_RESTORE_DIR}/data/temp'||file#||'_'|| substr(name,instr(name,'/',-1)+1)||''' ;' as command from v\$tempfile; " >> $SQLFILE1

echo " " > $SQLFILE2

sqlplus -s / as sysdba <<EOF | logoutput
@${SQLFILE1}
exit;
EOF

echo  "OK"
echo "----------------------"
cat $SQLFILE2
echo "----------------------"

#exit 1

echo -n "2. Rename online logs  ...             "
export LOGFILE="t05open1.log"
sqlplus -s / as sysdba <<EOF 
spool $LOGFILE
@${SQLFILE2}
exit;
EOF


echo  "OK"


echo -n "3. Open resetlogs  ...             "
export LOGFILE="t05open2.log"
sqlplus -s / as sysdba <<EOF 
spool $LOGFILE
alter database open resetlogs;
exit;
EOF


echo  "OK"


