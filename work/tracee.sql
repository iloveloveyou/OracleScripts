set serveroutput on
set ver off
set echo off
set feedback off
declare
 cursor c(sid# number) is
	select s.sid,s.serial#,p.spid 
	from v$session s, v$process p
	where s.paddr = p.addr
        and s.sid = sid#;

 r c%rowtype;
begin
open c(&1);
fetch c into r;
if c%found then
sys.dbms_system.set_sql_trace_in_session(r.sid,r.serial#,false);	
dbms_output.enable(20000);
dbms_output.put_line('--------------------------');
dbms_output.put_line('Trace for sessoin switch OFF');
dbms_output.put_line('SID        SERIAL      SPID');
dbms_output.put_line('--------------------------');
dbms_output.put_line(rpad(r.sid,10)||' '||rpad(r.serial#,10)||' '||r.spid);
else
dbms_output.put_line('Session not found');
end if;
close c;
end;
/

set feedback on


