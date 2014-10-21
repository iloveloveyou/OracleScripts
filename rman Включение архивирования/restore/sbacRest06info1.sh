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
show parameter unique_name;
exit;
EOF

echo " "
echo "-------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
echo "| STATUS: STARTED - NOMOUNT; MOUNTED - MOUNT or ALTER DATABASE CLOSE; OPEN - STARTUP or ALTER DATABASE OPEN; OPEN MIGRATE - ALTER DATABASE OPEN { UPGRADE | DOWNGRADE } |"
echo "-------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
sqlplus -S "/ as sysdba" << EOF
set linesize 150
set pagesize 150
-------------------
set linesize 200
column HOST_NAME format a15
column family format a15
select  INSTANCE_NAME, HOST_NAME, VERSION, STATUS,ARCHIVER,LOGINS,SHUTDOWN_PENDING,DATABASE_STATUS ,INSTANCE_ROLE ,ACTIVE_STATE ,BLOCKED,CON_ID,FAMILY
  from v\$instance;   

exit;
EOF
