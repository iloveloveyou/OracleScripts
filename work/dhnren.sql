column CHECKPOINT_CHANGE# format 9999999999999999
column name format a35
column file# format 9999
set pagesize 0
set linesize 140
set heading off
set feedback off
select 'alter database rename file '''||n.name||''' to '''||replace(n.name,'Datafiles','Datafiles_test')||''';'
from v$datafile_header h, v$datafile n
where h.file#=n.file#
/
