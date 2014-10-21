set linesize 90
set pagesize 30
set heading on
set ver off
set feedback on
set scan on

col sid        format a5
col ser#       format a5
col pid        format a7
col orauser    format a11
col program    format a27
col osuser     format a11
col S          format a1
col machine    format a8

select lpad(to_char(s.sid),5) sid,
      lpad(to_char(decode(sign(s.serial#), -1,
         65536+s.serial#, s.serial# )), 5) ser#,
      lpad(to_char(p.spid),7) PID,
      substr(s.username,1,11) orauser,
      substr(s.osuser,1,11) osuser,
      nvl(rpad(substr(upper(s.program),instr(s.program,'\',-1,1)+1,
      length(s.program)),25),'NOT DEFINED') program,
      substr(s.status,1,1) S,
      substr(s.machine,instr(s.machine,'\',1,1)+1,
      length(s.machine)) machine
  from v$session s, v$process p
  where s.paddr = p.addr
  and p.spid = &&1
  order by 7, machine desc, orauser, sid, ser#;

set pagesize 12
