#!/bin/bash 


########################################################################
# author: Sergey Brazgin     09.2014    OAO EM
# mail:   sbrazgin@gmail.com
# 
# 1) create entry in crontab
#
########################################################################

export path_to_config=`dirname $0`
cd $path_to_config
export PATH_BACKUP_SCRIPTS=`pwd`

command="nohup ${PATH_BACKUP_SCRIPTS}/sbac02backup.sh full > ${PATH_BACKUP_SCRIPTS}/cron_log.out &"
job="0 23 * * * $command"
cat <(fgrep -i -v "$command" <(crontab -l)) <(echo "$job") | crontab -

