set linesize 90
set pagesize 30
set heading on
set ver off
set feedback on
set scan on

col N          format a10
col NAME       format a70

select lpad(to_char(file#),10) N,
       substr(name,1,70) file_name
       from v$dbfile
       where file# = &1;

set pagesize 12
set feedback on
set ver on