#!/bin/bash

######################################
#
# create standby redo on standby db
#
######################################

source 00_all_vars.sh

echo;
show_hosts_db_names;
echo;

$ORACLE_HOME/bin/sqlplus -S "/ as sysdba" << EOF
set linesize 150
set serveroutput on;
declare
 standby_logs_exists		number 		:= 0;
 max_groups 			number 		:= 0;
 max_onlinelog_size		number 		:= 0;
 standby_logfile_path 		varchar2(100) 	:= '$STANDBY_LOG_FILE_PATH';
 standby_logfile_group_number   number		:= 0;
begin
	dbms_output.put_line(CHR(13)||CHR(10)||'##############################################################################################');
	dbms_output.put_line('<=== This PL/SQL generate SQL script for add standby logfiles ===>');

	select count(group#) into standby_logs_exists from v\$standby_log;
	if standby_logs_exists>0 then
		dbms_output.put_line(CHR(13)||CHR(10));
		dbms_output.put_line('===========================================================');
		dbms_output.put_line('AHTUNG!');
		dbms_output.put_line('AHTUNG!: standby logfiles already exists!');
		dbms_output.put_line('AHTUNG!');
		dbms_output.put_line('===========================================================');
		dbms_output.put_line(CHR(13)||CHR(10));
	end if;
	

	dbms_output.put_line('recommended number of standby redo log file groups = (maximum number of logfiles for each thread + 1) * maximum number of threads');

	select max(group#), max(bytes)/1024/1024 into max_groups, max_onlinelog_size from v\$log;

	dbms_output.put_line('Max.Groups = '||max_groups);
	dbms_output.put_line('Max.Onlinelog.Size (Mb) = '||max_onlinelog_size||CHR(13)||CHR(10));


	for i in 0..max_groups loop
		standby_logfile_group_number := i + max_groups + 1;
		dbms_output.put_line('alter database add standby logfile group '||standby_logfile_group_number||' ('''||standby_logfile_path||'$ORACLE_SID'||'_standby_redo_g'||standby_logfile_group_number||'m1.dbf'')'||' size '||max_onlinelog_size||'M;');
	end loop;

	dbms_output.put_line(CHR(13)||CHR(10)||'Check standby log:'); 
	dbms_output.put_line('SELECT GROUP#,THREAD#,SEQUENCE#,ARCHIVED,STATUS FROM V\$STANDBY_LOG;');
	dbms_output.put_line(CHR(13)||CHR(10)||'##############################################################################################');	
end;
/
exit;
EOF
