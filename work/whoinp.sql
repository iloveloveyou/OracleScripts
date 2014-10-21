set linesize 90
set pagesize 30
set heading on
set ver off
set feedback off
set scan on

prompt Parallel servers usage..

col sid        format a5
col ser#       format a5
col orauser    format a10
col program    format a25
col username   format a10
col osuser     format a10
col command    format a15
col S          format a1
col machine    format a10
col cnt        format 999

select value parallel_max_servers from v$parameter
where name = 'parallel_max_servers'
/
set feedback on

select lpad(to_char(s.sid),5) sid,
      lpad(to_char(decode(sign(s.serial#), -1,
         65536+s.serial#, s.serial# )), 5) ser#,
      substr(s.username,1,10) orauser,
      substr(s.osuser,1,10) osuser,
      nvl(rpad(substr(upper(s.program),instr(s.program,'\',-1,1)+1,
      length(s.program)),25),'NOT DEFINED') program,
      substr(s.status,1,1) S,
      substr(a.name,1,15) command,
      substr(s.machine,instr(s.machine,'\',1,1)+1,
      length(s.machine)) machine
  from v$session s, sys.audit_actions a
  where a.action = s.command
  and s.program like '%(P0%'
  order by orauser,machine
/

select substr(username,1,10) orauser,
       substr(osuser,1,10) osuser,
       substr(machine,instr(machine,'\',1,1)+1,
       length(machine)) machine,count(*) CNT
  from v$session
  where program like '%(P0%'
  group by username,osuser,machine
/


set pagesize 12
set feedback on
set ver on