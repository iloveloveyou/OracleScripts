#!/bin/bash

########################################################################
# author: Sergey Brazgin     09.2014    OAO EM
# mail:   sbrazgin@gmail.com
# 
# Here all variables for all backu scripts ( sbac*.sh )
# 
########################################################################


###############################
## store backup for XXX days
###############################
export BACKUP_STORE_DAYS=2


###############################
## remote host for test restore
###############################
export REMOTE_HOST=x.x.x.x
export REMOTE_HOST_DIR=/u01/backup/TESTDB
