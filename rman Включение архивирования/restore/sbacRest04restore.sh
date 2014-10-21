#!/bin/bash 


########################################################################
# author: Sergey Brazgin      09.2014
# mail:   sbrazgin@gmail.com
# 
# 1) catalog archive
# 2) restore datafiles
########################################################################

#------------------- START

GEN_ERR=1  # something went wrong in the script
export path_to_config=`dirname $0`
cd $path_to_config
export PATH_TO_BACKUP=`pwd`


export LOGFILE="t04restore1.log"
chmod u+x ./oraenvRestDB.sh
source oraenvRestDB.sh
source sbac00params.sh

#-------------------------- CATALOG
echo -n "1. CATALOG  ...             "

export LOGFILE="t04restore2.log"
export RMANFILE="t04restore2.rman"

echo "CATALOG START WITH '${DB_BACKUP_DIR}';" > $RMANFILE

rman target / cmdfile ${RMANFILE} log ${LOGFILE}

if [ $? -ne 0 ]
then
  echo "Running rman FAILED see ${LOGFILE}"
  exit ${GEN_ERR}
fi

echo "OK"


#------------------------ create script for rename temp
export LOGFILE="t04rest_temp1.log"
export SQLFILE="t04rest_temp.sql"

#echo "select '  set newname for tempfile '''||name||''' to ''${RESTORE_DB_DIR}/'|| substr(name,instr(name,'/',-1)+1)||''' ;' as ttt from v\$tempfile;" > ${SQLFILE}
#echo "select '  set newname for tempfile '||file#||' to ''${RESTORE_DB_DIR}/data/'|| substr(name,instr(name,'/',-1)+1)||''' ;' as ttt from v\$tempfile;" > ${SQLFILE}

echo "set linesize 200" > ${SQLFILE}
echo "set pagesize 200" >> ${SQLFILE}
echo "column ttt format a200" >> ${SQLFILE}
echo "select '  set newname for datafile '||file#||' to ''${RESTORE_DB_DIR}/data/data'||file#||'_'|| substr(name,instr(name,'/',-1)+1)||''' ;' as ttt from v\$datafile" >> ${SQLFILE}
echo "union all         " >> ${SQLFILE}
echo "select '  set newname for tempfile '||file#||' to ''${RESTORE_DB_DIR}/data/temp'||file#||'_'|| substr(name,instr(name,'/',-1)+1)||''' ;' as ttt from v\$tempfile;" >> ${SQLFILE}


chmod u+x ./oraenvRestDB.sh
. ./oraenvRestDB.sh

echo -n "2. select data and temp file...           "


output=`sqlplus / as sysdba <<EOF
      spool $LOGFILE
      set linesize 300
      @${SQLFILE} 
      exit;
EOF
`
if [ $? -ne 0 ]
then
  echo "Running sqlplus FAILED: $output "
  exit ${GEN_ERR}
fi

cat $LOGFILE | grep newname > t04rest_temp2.log

echo "OK"


 

#------------- Create rman script
echo -n "3. Create rman script for restore  ...             "
export LOGFILE="t04restore3.log"
export RMANFILE="t04restore3.rman"
export SQLFILE="t04restore3.sql"

#echo "select 'set newname for datafile ' || file# || ' to ''${DB_RESTORE_DIR}/data/' || substr(name,instr(name,'/',-1)+1) || ''';'from v\$datafile;" > $SQLFILE


echo "RUN"                     > ${RMANFILE}
echo "{"                      >> ${RMANFILE}
echo "  CONFIGURE CONTROLFILE AUTOBACKUP ON; " >> ${RMANFILE}
echo "  CONFIGURE CONTROLFILE AUTOBACKUP FORMAT FOR DEVICE TYPE DISK TO '${DB_RESTORE_DIR}/data/control_%d_%F'; " >> ${RMANFILE}
cat t04rest_temp2.log >> ${RMANFILE}
#echo "  set newname for database to new;"    >> ${RMANFILE}
echo "  restore database;"                   >> ${RMANFILE}
echo "  SWITCH DATAFILE ALL; "  >> ${RMANFILE}
echo "  RECOVER  database;"     >> ${RMANFILE}
echo "}"                        >> ${RMANFILE}


echo "OK"

echo "----------------"
cat ${RMANFILE}
echo "----------------"

#exit 1

#---------------------- restore
echo -n "4. RESTORE  ...             "

rman target / cmdfile ${RMANFILE} log ${LOGFILE}

if [ $? -ne 0 ]
then
  echo "Running rman FAILED"
fi

echo "--------------------"
tail -20 ${LOGFILE}
echo "--------------------"



