-- Выводит степень использования объектом места в базе
-- Выполняется под sys если нет соотв. гранта
set serveroutput on
set feedback off
set ver off
set scan on

accept oname prompt 'Название объекта:'
accept oowner prompt 'Владелец объекта:'
prompt ********************************
begin
declare
rsize number;
usize number;
otype varchar2(50);
onam varchar2(50);
oown varchar2(50);
p_name varchar2(50);
totalblocks number;
totalbytes number;
unusedblocks number;
unusedbytes number;
luefi number;
luebi number;
lub number;

cursor ptableCur (t_name varchar2,t_owner varchar2) is
select 1 from dba_part_tables
where owner = t_owner
and table_name = t_name;

ptableRec pTableCur%rowtype;

cursor pnameCur (t_name varchar2,t_owner varchar2) is
select partition_name from dba_tab_partitions
where table_owner = t_owner
and table_name = t_name
order by PARTITION_POSITION;

begin
dbms_output.enable(1000000);
onam:=upper('&&oname');
oown:=upper('&&oowner');

open ptableCur(onam,oown);
fetch ptableCur into ptableRec;
 if ptableCur%found then
  for pnameRec in pnameCur(onam,oown) loop
   dbms_space.unused_space(oown,onam,'TABLE PARTITION',totalblocks,totalbytes,
unusedblocks,unusedbytes,luefi,luebi,lub,pnameRec.partition_name);
dbms_output.put_line('Partition: ' ||oown||'.'||onam||'.'|| pnameRec.partition_name);
dbms_output.put_line('Реальный размер: '||round(totalbytes/1024/1024,2)  || 'Mb');
dbms_output.put_line('Не используется: '||round(unusedbytes/1024/1024,2) || 'Mb');
   
  end loop;  
 else
  select segment_type into otype
from dba_segments
where owner=oown
and segment_name=onam;

dbms_space.unused_space(oown,onam,otype,totalblocks,totalbytes,
unusedblocks,unusedbytes,luefi,luebi,lub);
dbms_output.put_line(otype||': '||oown||'.'||onam);
dbms_output.put_line('Реальный размер: '||round(totalbytes/1024/1024,2)  || 'Mb');
dbms_output.put_line('Не используется: '||round(unusedbytes/1024/1024,2) || 'Mb');

 end if;
close ptableCur;


exception
when no_data_found then
dbms_output.put_line('Объект не найден!');
end;
end;
/
set feedback on
