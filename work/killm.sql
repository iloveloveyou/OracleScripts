set linesize 90
set pagesize 30
set heading off
set ver off
set feedback off
set scan on

col sid        format a5
col ser#       format a5
col orauser    format a10
col program    format a25
col username   format a10
col osuser     format a10
col command    format a15
col S          format a1
col machine    format a10
spool kill_allm.sql
select 'host kill -9 '||to_char(p.spid)
  from v$session s, sys.audit_actions a, v$process p
  where a.action = s.command
  and upper(machine) like upper('%&1%')
  and s.paddr = p.addr;
spool off
set pagesize 12
set feedback on
set ver on
