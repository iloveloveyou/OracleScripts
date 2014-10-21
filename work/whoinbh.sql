set linesize 100
set pagesize 30
set heading on
set ver off
set feedback on
set scan on

col sid        format a5
col ser#       format a5
col orauser    format a10
col program    format a25
col S          format a1
col command    format a15
col machine    format a10
col event      format a27

prompt Session, changing buffer cache blocks, held by specified latch children
prompt Script parameters: <latch#> <child#>

select distinct lpad(to_char(s.sid),5) sid,
      lpad(to_char(decode(sign(s.serial#), -1,
         65536+s.serial#, s.serial# )), 5) ser#,
      substr(s.username,1,10) orauser,
      nvl(rpad(substr(upper(s.program),instr(s.program,'\',-1,1)+1,
      length(s.program)),25),'NOT DEFINED') program,
      substr(s.status,1,1) S,
      substr(s.machine,instr(s.machine,'\',1,1)+1,
      length(s.machine)) machine,
      rpad(substr(w.event,1,27),27) event
from v$transaction t, sys.x_$bh b, v$session s,v$session_wait w
where t.XIDUSN = b.CR_XID_USN
and t.XIDSLOT = b.CR_XID_SLT
and t.XIDSQN = b.CR_XID_SQN
--and b.CR_XID_USN != 0
--and b.CR_XID_SLT != 0
--and b.CR_XID_SQN != 0
and b.HLADDR in 
(select addr from v$latch_children
where latch# = &1 and child# = &2)
and t.ses_addr=s.saddr
and w.sid = s.sid
/

