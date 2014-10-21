set linesize 90
set pagesize 30
set heading on
set ver off
set feedback on
set scan on

col sid        format a5
col ser#       format a5
col orauser    format a10
col program    format a20
col username   format a10
col command    format a15
col S          format a1

select lpad(to_char(s.sid),5) sid,
      lpad(to_char(decode(sign(s.serial#), -1,
         65536+s.serial#, s.serial# )), 5) ser#,
      substr(s.username,1,10) orauser,
      rpad(p.description,20) program,
      substr(s.status,1,1) S,
      substr(a.name,1,15) command
  from v$session s, v$bgprocess p,sys.audit_actions a
  where a.action = s.command
  and s.osuser is null 
  and s.paddr = p.PADDR
  order by orauser;
set pagesize 12
