#!/bin/bash 

########################################################################
# author: Sergey Brazgin     09.2014    OAO EM
# mail:   sbrazgin@gmail.com
# 
# 1) create dirs
# 2) create copy file (easy)
# 3) create oraenv
# 4) config rman
# 5) create scp copy script
########################################################################


export path_to_config=`dirname $0`
cd $path_to_config
export PATH_BACKUP_SCRIPTS=`pwd`
source sbac00params.sh

#---------------- create dirs
export PATH_TO_BACKUP=${PATH_BACKUP_SCRIPTS}/backup
echo "PATH_TO_BACKUP=${PATH_TO_BACKUP}"
[ -d $PATH_TO_BACKUP ] || mkdir -p $PATH_TO_BACKUP

export PATH_TO_LOGS=${PATH_BACKUP_SCRIPTS}/logs
echo "PATH_TO_LOGS=${PATH_TO_LOGS}"
[ -d $PATH_TO_LOGS ] || mkdir -p $PATH_TO_LOGS

export NLS_DATE_FORMAT='DD-MON-YY HH24:MI:SS'
export date=`date +%Y%m%d%H%M%S`
export date1=`date +%Y_%m_%d`
export date2=`date +%H_%M_%S`
export LOGOUT=$PATH_TO_LOGS/$date1
echo "CURRENT_LOGS=${LOGOUT}"
[ -d $LOGOUT ] || mkdir -p $LOGOUT

# create copy file 
#echo "scp ${PATH_TO_BACKUP}/* oracle@xxx:${PATH_TO_BACKUP} " > ${PATH_BACKUP_SCRIPTS}/copy_backup.sh
#chmod u+x *.sh
#echo "created: ${PATH_BACKUP_SCRIPTS}/copy_backup.sh"
#exit 0

# create oraenv file for crontab
echo "export ORACLE_BASE=${ORACLE_BASE}" > ${PATH_BACKUP_SCRIPTS}/oraenv.sh
echo "export ORACLE_HOME=${ORACLE_HOME}" >> ${PATH_BACKUP_SCRIPTS}/oraenv.sh
echo "export ORACLE_SID=${ORACLE_SID}" >> ${PATH_BACKUP_SCRIPTS}/oraenv.sh
echo "export LD_LIBRARY_PATH=${ORACLE_HOME}/lib:" >> ${PATH_BACKUP_SCRIPTS}/oraenv.sh
echo "export PATH=/usr/local/bin:/bin:/usr/bin:/home/oracle/bin:/home/oracle/bin:${ORACLE_HOME}/bin:" >> ${PATH_BACKUP_SCRIPTS}/oraenv.sh
echo "created: ${PATH_BACKUP_SCRIPTS}/oraenv.sh"

# config rman options
echo "CONFIGURE BACKUP OPTIMIZATION OFF;" > ${PATH_BACKUP_SCRIPTS}/config.rman
echo "CONFIGURE DEFAULT DEVICE TYPE TO DISK;" >> ${PATH_BACKUP_SCRIPTS}/config.rman
echo "CONFIGURE COMPRESSION ALGORITHM 'MEDIUM';" >> ${PATH_BACKUP_SCRIPTS}/config.rman
echo "CONFIGURE CONTROLFILE AUTOBACKUP ON;" >> ${PATH_BACKUP_SCRIPTS}/config.rman
echo "CONFIGURE DEVICE TYPE 'DISK' PARALLELISM 8 BACKUP TYPE TO COMPRESSED BACKUPSET;" >> ${PATH_BACKUP_SCRIPTS}/config.rman

echo "CONFIGURE CHANNEL DEVICE TYPE DISK FORMAT  '${PATH_TO_BACKUP}/DB_%d_%U';" >> ${PATH_BACKUP_SCRIPTS}/config.rman
echo "CONFIGURE CONTROLFILE AUTOBACKUP FORMAT FOR DEVICE TYPE DISK TO '${PATH_TO_BACKUP}/control_%d_%F'; " >> ${PATH_BACKUP_SCRIPTS}/config.rman
echo "CONFIGURE SNAPSHOT CONTROLFILE NAME TO '${PATH_TO_BACKUP}/snapcf_PROTECT.f';" >> ${PATH_BACKUP_SCRIPTS}/config.rman
echo "CONFIGURE RETENTION POLICY TO RECOVERY WINDOW OF ${BACKUP_STORE_DAYS} DAYS;" >> ${PATH_BACKUP_SCRIPTS}/config.rman

echo "created: ${PATH_BACKUP_SCRIPTS}/config.rman"

echo -n "Config rman ... "
rman target / @${PATH_BACKUP_SCRIPTS}/config.rman > ${LOGOUT}/config_rman_${date2}.log       

echo "List parameters from rman:  "
echo "show all;" > ${PATH_BACKUP_SCRIPTS}/show_all.rman
rman target / @${PATH_BACKUP_SCRIPTS}/show_all.rman > ${LOGOUT}/show_rman_${date2}.log       
echo "OK"
echo "-----------------------------"
cat ${LOGOUT}/show_rman_${date2}.log | grep -v default
echo "-----------------------------"



echo "scp -p ${PATH_TO_BACKUP}/* oracle@${REMOTE_HOST}:${REMOTE_HOST_DIR} " > ${PATH_BACKUP_SCRIPTS}/copy_backup.sh
status=$?
if [ $status -ne 0 ]; then
    echo "error creating file: ${PATH_BACKUP_SCRIPTS}/copy_backup.sh"
    exit $status
fi

chmod u+x *.sh
echo "created: ${PATH_BACKUP_SCRIPTS}/copy_backup.sh"


chmod u+x *.sh
echo "OK "
