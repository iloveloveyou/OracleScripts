set linesize 90
set pagesize 30
set heading on
set ver off
set feedback on
set scan on

col STATUS          format a10
col CNT             format a10

select STATUS,to_char(COUNT(1))
CNT from v$session
group by status
order by status;

set pagesize 12
set feedback on
set ver on