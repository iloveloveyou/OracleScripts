set linesize 120
set pagesize 30
set heading on
set ver off
set feedback on
set scan on

col sid        format a5
col seq#       format a5
col event      format a30
col p1text     format a10
col p1         format a10
col p2text     format a10
col p2         format a10
col machine    format a20

select lpad(sw.sid,5) sid,
       lpad(sw.seq#,5) seq#,
       rpad(substr(sw.event,1,30),30) event,
       rpad(substr(sw.p1text,1,10),10) p1text,
       rpad(substr(sw.p1,1,10),10) p1,
       rpad(substr(sw.p2text,1,10),10) p2text,
       rpad(substr(sw.p2,1,10),10) p2,
       substr(s.machine,instr(s.machine,'\',1,1)+1,
       length(s.machine)) machine
from v$session_wait sw,v$session s
where sw.sid = s.sid
and s.sid = &1
/


set pagesize 12
set feedback on
set ver on
