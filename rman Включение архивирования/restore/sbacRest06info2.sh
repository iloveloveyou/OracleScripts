#!/bin/bash 


########################################################################
# author: Sergey Brazgin    09.2014
# mail:   sbrazgin@gmail.com
# 
# 1) show DB info
########################################################################


GEN_ERR=1  # something went wrong in the script
export path_to_config=`dirname $0`
cd $path_to_config

export PATH_TO_BACKUP=`pwd`

chmod u+x ./oraenvRestDB.sh
source oraenvRestDB.sh


sqlplus -S "/ as sysdba" << EOF
set linesize 150
set pagesize 1500
show parameter unique_name;

col DATABASE_ROLE format a20
col LOG_MODE format a10
col FLASHBACK_ON format a12
col FORCE_LOGGING format a12
col PROTECTION_MODE format a20
col PROTECTION_LEVEL format a20
select DATABASE_ROLE, LOG_MODE, FLASHBACK_ON, FORCE_LOGGING, PROTECTION_MODE, PROTECTION_LEVEL from v\$database;

exit;
EOF
