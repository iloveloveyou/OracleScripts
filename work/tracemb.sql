set serveroutput on
set ver off
set echo off
set feedback off
declare
 cursor c is
	select s.sid,s.serial#,p.spid 
	from v$session s, v$process p
	where s.paddr = p.addr
        and upper(s.machine) like upper('%&1%')
	order by s.sid;

 r c%rowtype;
begin
dbms_output.enable(20000);
dbms_output.put_line('---------------------------');
dbms_output.put_line('Trace for sessoin switch ON');
dbms_output.put_line('SID        SERIAL      SPID');
dbms_output.put_line('---------------------------');

for r in c loop
sys.dbms_system.set_sql_trace_in_session(r.sid,r.serial#,true);	
dbms_output.put_line(rpad(r.sid,10)||' '||rpad(r.serial#,10)||' '||r.spid);
end loop;
end;
/

set feedback on




