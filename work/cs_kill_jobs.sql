set pagesize 0
set ver off
set scan on

spool kill/kill_jobs.sql

select 'alter system kill session '||chr(39)||to_char(sid)||','||
      to_char(serial#)||chr(39)||';'
  from v$session s, v$bgprocess p,sys.audit_actions a
  where a.action = s.command
  and s.osuser is null 
  and s.paddr = p.PADDR
  and s.client_info like 'cbjob=%';

spool off