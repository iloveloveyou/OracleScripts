#!/bin/bash 

########################################################################
# author: Sergey Brazgin    09.2014   
# mail:   sbrazgin@gmail.com
# 
# 1) create env variable file
# 2) create init file
# 3) create dir
#  
########################################################################


GEN_ERR=1  # something went wrong in the script
export path_to_config=`dirname $0`
cd $path_to_config
export PATH_TO_BACKUP=`pwd`

source sbac00params.sh

echo "Backup DB dir            : ${REMOTE_HOST_DIR}"
echo "Restore DB dir           : ${RESTORE_DB_DIR}"

#--------- find init file
export INIT_FILE=`find ${REMOTE_HOST_DIR} -name 'init*' -type f -print0 | xargs -0 ls -t | head -n 1`
echo "INIT_FILE orig           : ${INIT_FILE}"


export init_file_edited=${RESTORE_DB_DIR}/s_init_db.ora

#--------- modify init file
cp ${INIT_FILE} ${RESTORE_DB_DIR}/temp_init_db.ora
sed '/audit_file_dest/d'        ${RESTORE_DB_DIR}/temp_init_db.ora >  ${RESTORE_DB_DIR}/temp_init_db2.ora
sed '/db_recovery_file_dest/d'  ${RESTORE_DB_DIR}/temp_init_db2.ora > ${RESTORE_DB_DIR}/temp_init_db.ora
sed '/diagnostic_dest/d'        ${RESTORE_DB_DIR}/temp_init_db.ora >  ${RESTORE_DB_DIR}/temp_init_db2.ora
sed '/control_files/d'          ${RESTORE_DB_DIR}/temp_init_db2.ora > ${RESTORE_DB_DIR}/temp_init_db.ora
sed '/local_listener/d'         ${RESTORE_DB_DIR}/temp_init_db.ora >  ${RESTORE_DB_DIR}/temp_init_db2.ora
sed '/db_create_file_dest/d'    ${RESTORE_DB_DIR}/temp_init_db2.ora > ${RESTORE_DB_DIR}/temp_init_db.ora
sed '/.__/d'    ${RESTORE_DB_DIR}/temp_init_db.ora > ${RESTORE_DB_DIR}/temp_init_db2.ora
sed '/log_archive_dest/d'       ${RESTORE_DB_DIR}/temp_init_db2.ora >  $init_file_edited


#--------- create dir for db
mkdir -p ${RESTORE_DB_DIR}/adump
echo "*.audit_file_dest='${RESTORE_DB_DIR}/adump'" >> $init_file_edited

mkdir -p ${RESTORE_DB_DIR}/control
rm -rf ${RESTORE_DB_DIR}/control/*
echo "*.control_files='${RESTORE_DB_DIR}/control/control01.ctl'" >> $init_file_edited

mkdir -p ${RESTORE_DB_DIR}/logarchive
rm -rf ${RESTORE_DB_DIR}/logarchive/*
echo "*.log_archive_dest_1='location=${RESTORE_DB_DIR}/logarchive MANDATORY' " >> $init_file_edited

mkdir -p ${RESTORE_DB_DIR}/fast_recovery_area
rm -rf ${RESTORE_DB_DIR}/fast_recovery_area/*
echo "*.db_recovery_file_dest='${RESTORE_DB_DIR}/fast_recovery_area' " >> $init_file_edited
echo "*.db_recovery_file_dest_size=1000g" >> $init_file_edited

mkdir -p ${RESTORE_DB_DIR}/diag
echo "*.diagnostic_dest='${RESTORE_DB_DIR}' " >> $init_file_edited

mkdir -p ${RESTORE_DB_DIR}/data
rm -rf ${RESTORE_DB_DIR}/data/*
echo "*.db_create_file_dest='${RESTORE_DB_DIR}/data' " >> $init_file_edited


echo "INIT_FILE edited         : $init_file_edited"
echo "---------------"
cat $init_file_edited
echo "---------------"



#--------------- find control file
export CONTROL_FILE=`find ${REMOTE_HOST_DIR} -name 'control*' -type f -print0 | xargs -0 ls -t | head -n 1`
#export CONTROL_FILE=${CONTROL_FILE#"./"}
#export CONTROL_FILE=${PATH_TO_BACKUP}/${CONTROL_FILE}
echo "CONTROL_FILE             : ${CONTROL_FILE}"



#------------- create env file
if [ ! -f ${REMOTE_HOST_DIR}/oraenv_db.sh ]; then
    echo "File ${REMOTE_HOST_DIR}/oraenv_db.sh not found!"
    exit 1
fi

chmod u+x ${REMOTE_HOST_DIR}/oraenv_db.sh
source ${REMOTE_HOST_DIR}/oraenv_db.sh

echo "ORACLE_HOME=$ORACLE_HOME"   >  oraenvRestDB.sh
echo "ORACLE_SID=$ORACLE_SID"     >>  oraenvRestDB.sh
echo "PATH=$PATH"                 >>  oraenvRestDB.sh
echo "LIBRARY_PATH=$LIBRARY_PATH" >>  oraenvRestDB.sh
echo "ORACLE_DBID=$ORACLE_DBID"     >>  oraenvRestDB.sh
echo "CONTROL_FILE=$CONTROL_FILE"   >>  oraenvRestDB.sh
echo "INIT_FILE=$init_file_edited"  >>  oraenvRestDB.sh
echo "DB_BACKUP_DIR=${REMOTE_HOST_DIR}"  >>  oraenvRestDB.sh
echo "DB_RESTORE_DIR=${RESTORE_DB_DIR}"  >>  oraenvRestDB.sh
echo "export ORACLE_HOME"         >>  oraenvRestDB.sh
echo "export ORACLE_SID"         >>  oraenvRestDB.sh
echo "export PATH"               >>  oraenvRestDB.sh
echo "export LIBRARY_PATH"       >>  oraenvRestDB.sh
echo "export ORACLE_DBID"        >>  oraenvRestDB.sh
echo "export CONTROL_FILE"       >>  oraenvRestDB.sh
echo "export INIT_FILE"         >>  oraenvRestDB.sh
echo "export NLS_DATE_FORMAT='DD-MON-YY HH24:MI:SS'"       >>  oraenvRestDB.sh
echo "export DB_BACKUP_DIR"         >>  oraenvRestDB.sh
echo "export DB_RESTORE_DIR"        >>  oraenvRestDB.sh



echo "oraenv created           : oraenvRestDB.sh"
echo "---------------"
cat oraenvRestDB.sh
echo "---------------"


