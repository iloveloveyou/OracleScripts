-- Выдает десять наибольших объектов табличного пространства
set scan on
set feedback off
set ver off
set heading off
 
prompt 20 Largest objects in tablespace
accept ts prompt 'Enter tablespace: '

set serveroutput on

declare 
cursor c(tname varchar2) is
select segment_name sname,
segment_type styp,owner oname,bytes ssize
from dba_segments
where tablespace_name=tname
and bytes/1024/1024 < 300
order by bytes desc;
n number;
tname varchar2(20);

begin
n:=1;
tname:=upper('&&ts');
dbms_output.enable;
dbms_output.put_line(' OBJECT            OBJECT_TYPE      OWNER      SIZE(Mb)');
dbms_output.put_line(' ______________________________________________________');
for t in c(tname) loop
dbms_output.put_line(' ' || rpad(t.sname,20) || ' ' 
|| rpad(t.styp,15) || ' ' 
|| rpad(t.oname,10) || ' ' || t.ssize/1024/1024);
if n=20 then exit;
end if;
n:=n+1;
end loop;
end;
/
--set ver on
set feedback on
set heading on
