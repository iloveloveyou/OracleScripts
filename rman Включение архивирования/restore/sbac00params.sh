#!/bin/bash

########################################################################
# author: Sergey Brazgin     09.2014    OAO EM
# mail:   sbrazgin@gmail.com
# 
# Here all variables for all backu scripts ( sbac*.sh )
# 
########################################################################


###############################
## BACKUP: store backup for XXX days
###############################
export BACKUP_STORE_DAYS=2


###############################
## BACKUP: remote host for test restore
###############################
export REMOTE_HOST=10.0.5.59
export REMOTE_HOST_DIR=/u01/backup/TESTDB

###############################
## RESTORE: test restore on remote host
###############################
export RESTORE_DB_DIR=/u01/backup/DB
