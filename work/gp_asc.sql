set scan on
set feedback off
set ver off
set pagesize 0
set heading off
set linesize 300
--set maxdata 10000000
set arraysize 1
set trimspool on

col txt format a256
col owner noprint
col type noprint
col line noprint
col ind noprint

accept names char prompt 'PACKAGE: ';

spool create/cp_asc.sql

select type, line,
       decode(line, 1, 'create or replace ','') || text txt,
       1 ind
  from user_source
  where name =upper('&&names')
/*union
select type, line,
       '/' txt,
       2 ind
  from user_source
  where name =upper('&&names')
    and line=1*/
  order by type, ind, line;

spool off

set linesize 80
set pagesize 12
set ver on
set feedback on
set heading on


