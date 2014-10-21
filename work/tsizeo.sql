-- Выдает десять наибольших объектов схемы
set scan on
set feedback off
set ver off
set heading off
 
prompt Largest objects in your scheme:
set serveroutput on

declare 
cursor c is
select segment_name sname,
sum(bytes) ssize
from user_extents
group by segment_name
order by 2 desc;
n number;
tname varchar2(20);
otyp varchar2(20);
begin
n:=1;
dbms_output.enable;
dbms_output.put_line(' OBJECT            OBJECT_TYPE    TABLESPACE   SIZE(Mb)');
dbms_output.put_line(' ______________________________________________________');
for t in c loop
select object_type into otyp from user_objects
where object_name=t.sname;
tname:='NO INFORMATION';

if otyp='TABLE' then
select tablespace_name into tname
from user_tables
where table_name=t.sname;
end if;

if otyp='INDEX' then
select tablespace_name into tname
from user_indexes
where index_name=t.sname;
end if;

dbms_output.put_line(' ' || rpad(t.sname,20) || ' ' 
|| rpad(otyp,8) || ' ' 
|| rpad(tname,9) || ' ' || t.ssize/1024);
if n=10 then exit;
end if;
n:=n+1;
end loop;
end;
/
set ver on
set feedback on
set heading on
