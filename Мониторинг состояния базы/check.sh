#!/bin/sh

. ./params_check.sh

echo "    " >> ./check.log
echo " =======================================================   " >> ./check.log
date >> ./check.log
echo "    " >> ./check.log
echo " Start checking ...  " >> ./check.log



# Проверка 1
./check_host_free_space.sh

if ./check_oracle_instance.sh; then
  if ./check_oracle.sh; then 
    ./check_oracle_free_space.sh
    ./send_oracle_log.sh
  fi
fi

echo " Finish checking  " >> ./check.log
echo " =======================================================   " >> ./check.log

