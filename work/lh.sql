set linesize 100
set pagesize 30
set heading on
set ver off
set feedback on
set scan on

col sid        format a5
col ser#       format a5
col pid        format a5
col username   format a8
col machine    format a15
col program    format a13
col name       format a25
col request    format a7

select rpad(s.sid,5) sid,
       rpad(s.serial#,5) ser#,
       rpad(p.spid,5) pid,
       rpad(s.username,8) username,
       rpad(substr(s.machine,instr(s.machine,'\',1,1)+1,
       length(s.machine)),15) machine,
       rpad(nvl(substr(upper(s.program),instr(s.program,'\',-1,1)+1,
       length(s.program)),'NOT DEFINED'),13) program,
       rpad(lr.name,25) name,
       rpad(lr.rcount,6) request
from v$session s,v$latchholder h,v$process p,
(select l.name name,count(1) rcount
from v$session_wait sw,v$latchname l
where event = 'latch free'
and sw.p2 = l.latch#
group by l.name ) lr
where s.sid = h.sid
and s.paddr = p.addr
and h.name = lr.name
order by lr.rcount desc
/

set pagesize 12
set feedback on
set ver on
