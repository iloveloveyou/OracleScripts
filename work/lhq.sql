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
       rpad(lh.name,25) name,
       rpad(lr.rcount,6) request
from v$session s,v$process p,v$latchholder lh,
(select sw.p1raw p1raw,count(1) rcount
from v$session_wait sw,v$latchholder l
where event = 'latch free'
and sw.p1raw = l.laddr
group by sw.p1raw) lr
where s.paddr = p.addr
and s.sid = lh.sid
and lr.p1raw = lh.laddr
order by lr.rcount desc
/

set pagesize 12
set feedback on
set ver on
