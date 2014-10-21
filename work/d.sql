set linesize 100
column name format a40;
column CHECKPOINT_CHANGE# format 99999999999999999999;
select file#,name,status,enabled,CHECKPOINT_CHANGE# from v$datafile;
