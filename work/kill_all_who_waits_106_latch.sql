-- This script finds all sessions that wait for "library cache latch free" wait
-- and forms "kill -9" commands for every session in one spool file
-- and "alter system kill session" commands in second one
-- Than you should manually execute 

delete from  tmp_kill;

--create table pasha.tmp_kill as
insert into tmp_kill (sid, p1raw, p2)
select sid, p1raw, p2 from v$session_wait
where event='latch free' 
and p2=106  -- library cache
/

commit;

set heading off
set pagesize 0

spool kill_all_who_waits_106_latch.kill_9

select -- 'alter system kill session '''||s.sid||','||s.serial#||''';'
'kill -9 '||p.spid||';'
from v$session s, v$process p
where  p.addr = s.paddr
and sid in (select sid from pasha.tmp_kill)
and lower(machine) not like '%gener%'
and lower(machine) not like '%zeus%'
and type != 'BACKGROUND';
spool off

spool kill_all_who_waits_106_latch.alter_system

select  'alter system kill session '''||s.sid||','||s.serial#||''';'
--'kill -9 '||p.spid||';'
from v$session s, v$process p
where  p.addr = s.paddr
and sid in (select sid from pasha.tmp_kill)
and lower(machine) not like '%gener%'
and lower(machine) not like '%zeus%'
and type != 'BACKGROUND';
spool off

quit
