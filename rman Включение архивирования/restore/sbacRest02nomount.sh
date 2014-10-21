#!/bin/bash 


########################################################################
# author: Sergey Brazgin    09.2014
# mail:   sbrazgin@gmail.com
# 
# 1) mount DB in nomount state
# 2) create spfile from pfile
# 3) mount DB in nomount state with SPFILE
########################################################################


#set -o nounset
#set -o errexit

GEN_ERR=1  # something went wrong in the script
export path_to_config=`dirname $0`
cd $path_to_config

export PATH_TO_BACKUP=`pwd`


#--------- startup nomount
export LOGFILE="_sbacRest02nomount1.log"

chmod u+x ./oraenvRestDB.sh
. ./oraenvRestDB.sh

echo -n "1. Shutdown database if started ...           "

output=`sqlplus / as sysdba <<EOF
      shutdown abort;
      exit;
EOF
`
echo  "OK"

echo -n "2. Start database nomount with pfile ${INIT_FILE} ...      "

output=`sqlplus / as sysdba <<EOF
      spool $LOGFILE
      startup nomount pfile=${INIT_FILE};
      exit;
EOF
`
if [ $? -ne 0 ]
then
  echo "Running sqlplus FAILED: $output "
  exit ${GEN_ERR}
fi


#------------ Проверка на ошибки
grep -q 'ORA-' ${LOGFILE}
status=$?

if [ $status -eq 0 ]; then
   echo "startup nomount error. Check error log: ${LOGFILE}"
   exit 1
fi
echo  "OK"

#--------- create spfile
export LOGFILE="_sbacRest02nomount2.log"
echo -n "3. Create spfile from pfile           ...     "

output=`sqlplus / as sysdba <<EOF
      spool $LOGFILE
      create spfile from pfile='${INIT_FILE}';
      exit;
EOF
`

if [ $? -ne 0 ]
then
  echo "Running sqlplus FAILED"
  exit ${GEN_ERR}
fi

grep -q 'ORA-' $LOGFILE
status=$?

if [ $status -eq 0 ]; then
   echo "create spfile error. Check error log: ${LOGFILE}"
   exit 1
fi

echo  "OK"


#---------  restart with spfile
echo -n "4. Shutdown database if started ...           "

output=`sqlplus / as sysdba <<EOF
      shutdown abort;
      exit;
EOF
`
echo  "OK"


export LOGFILE="_sbacRest02nomount3.log"
echo -n "5. Start database nomount with spfile ...     "

output=`sqlplus / as sysdba <<EOF
      spool $LOGFILE
      startup nomount;
      exit;
EOF
`

if [ $? -ne 0 ]
then
  echo "Running sqlplus FAILED"
  exit ${GEN_ERR}
fi

grep -q 'ORA-' $LOGFILE
status=$?

if [ $status -eq 0 ]; then
   echo "start with spfile error. Check error log: ${LOGFILE}"
   exit 1
fi


echo  "OK"

./sbacRest06info1.sh

#-------------------------------------------------
