#!/bin/bash 

########################################################################
# author: Sergey Brazgin     09.2014    OAO EM
# mail:   sbrazgin@gmail.com
# 
# 1) create backup
# 2) call db_info.sh
#
########################################################################


export path_to_config=`dirname $0`
cd $path_to_config

. ./oraenv.sh


export PATH_TO_BACKUP=`pwd`
export PATH_TO_BACKUP=${PATH_TO_BACKUP}/backup
echo "PATH_TO_BACKUP=${PATH_TO_BACKUP}"
source sbac00params.sh


export PATH_TO_LOGS=logs
export NLS_DATE_FORMAT='DD-MON-YY HH24:MI:SS'
export date=`date +%Y%m%d%H%M%S`
export date1=`date +%Y_%m_%d`
export date2=`date +%H_%M_%S`
export LOGOUT=$PATH_TO_LOGS/$date1
echo "LOGOUT=${LOGOUT}"

[ -d $PATH_TO_LOGS ] || mkdir -p $PATH_TO_LOGS
[ -d $PATH_TO_BAC ] || mkdir -p $PATH_TO_BAC
[ -d $LOGOUT ] || mkdir -p $LOGOUT

case $1 in

hourly)

rman target / @sbacHOURLY.rman > $LOGOUT/HOURLY_$date2.log       
./sbac04db_info.sh

;;
daily)

rman target / @sbacDAILY.rman > $LOGOUT/DAILY_${date2}.log	
./sbac04db_info.sh

;;
full)

rman target / @sbacFULL.rman using "$BACKUP_STORE_DAYS" "FULL_DB_$date1" "FULL_ARC_$date1" > $LOGOUT/FULL_${date2}.log	
./sbac04db_info.sh

;;
*)

echo -e "\n\tUsage $0 (hourly|daily|full)\n
	hourly	make a hourly backup of archivelogs
	daily	make a daily incremental level 1 backup
	full	make a full backup (level 0)\n"

;;
esac

