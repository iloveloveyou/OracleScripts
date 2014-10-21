-- Who hold most requestable latches
set linesize 90
set serveroutput on
set ver off
set feedback off

declare
Cursor lwCur is
select l.name name,count(1) kol
from v$session_wait sw,v$latch_children l
where event = 'latch free'
and sw.p1raw = l.addr
group by l.name
order by kol desc;
Cursor lhCur (lname# varchar2) is
select s.sid sid,
s.serial# serial#,p.spid spid,
s.username,s.machine,h.name
from v$session s,v$latchholder h,v$process p
where s.sid = h.sid
and s.paddr = p.addr
and h.name = lname#;

begin
    dbms_output.enable;   	 
    dbms_output.put_line('Holders most requestable latches');
    dbms_output.put_line('SID   SERIAL SPID   USER       MASHINE         LATCH NAME                WAITERS');
    dbms_output.put_line('----- ------ ------ ---------- --------------- ------------------------- -------');
    for lwRec in lwCur loop
        for lhRec in lhCur(lwRec.name) loop
          dbms_output.put_line(lpad(lhRec.sid,6,' ')||
          lpad(lhRec.serial#,7,' ')||
          lpad(lhRec.spid,7,' ')||' '||
          rpad(lhRec.username,11,' ')||
          rpad(nvl(substr(lhRec.machine,nvl(instr(lhRec.machine,'\',1,1),0)+1,
          length(lhRec.machine)),' '),16,' ')||
          rpad(lwRec.name,26,' ')||
          to_char(lwRec.kol));        
        end loop;
    end loop;
end;
/

set feedback on