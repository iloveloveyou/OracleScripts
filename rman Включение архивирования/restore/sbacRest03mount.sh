#!/bin/bash 


########################################################################
# author: Sergey Brazgin     09.2014
# mail:   sbrazgin@gmail.com
# 
# 1) mount DB in mount state
# 2) restore control file
########################################################################


GEN_ERR=1  # something went wrong in the script
export path_to_config=`dirname $0`
cd $path_to_config
export PATH_TO_BACKUP=`pwd`

chmod u+x ./oraenvRestDB.sh
. ./oraenvRestDB.sh



#------------- rman set dbid , restore control file
echo -n "1. Restore control file ${CONTROL_FILE} ...       "

export LOGFILE="t03mount.log"
export RMANFILE="t03mount.rman"

echo "set dbid ${ORACLE_DBID};"    > ${RMANFILE}
echo "RESTORE CONTROLFILE FROM '${CONTROL_FILE}';"  >> ${RMANFILE}

rman target / cmdfile ${RMANFILE} log ${LOGFILE}

if [ $? -ne 0 ]
then
  echo "Running rman FAILED"
  exit ${GEN_ERR}
fi

echo "   OK "


#-------------- mount
echo -n "2. Mount database  ...      "

output=`sqlplus / as sysdba <<EOF
      spool $LOGFILE
      alter database mount;
      exit;
EOF
`
if [ $? -ne 0 ]
then
  echo "Running sqlplus FAILED: $output "
  exit ${GEN_ERR}
fi

echo "OK"

./sbacRest06info1.sh

./sbacRest06info2.sh


