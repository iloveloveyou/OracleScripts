-------------------------------------
-- LATCH child miss by name
-------------------------------------
set linesize 80
set serveroutput on
set ver off
set scan on
set feedback off

----------------------------------------
-- Для работы нужно создать таблицу
--
--  create global temporary table latch_children_tmp 
--  (latch# number,child# number,name varchar2(500),
--  misses number,seq# number,tim# number)
--
-----------------------------------------

prompt Incremental latch child miss statisticts

prompt Wait please...


declare
cursor MissesCur is
select a.latch#,a.child#,a.name,
round((b.misses - a.misses)/(b.tim# - a.tim#)*100,2) missrate
from latch_children_tmp a,latch_children_tmp b
where a.latch# = b.latch#
and a.child# = b.child#
and a.seq# = 1
and b.seq# = 2
order by 4 desc;

MissesRec MissesCur%rowtype;
-----------------------------------------------------
Timeout number := 10; -- Задержка для сбора данных
ShowRows number := 20; -- Сколько строк выводить
-----------------------------------------------------
CurrentRow number;
begin

delete from latch_children_tmp;
commit;

insert into latch_children_tmp(latch#,child#,name,misses,seq#,tim#)
select l.latch#,l.child#,l.name,l.misses,1,t.hsecs
from v$latch_children l,v$timer t;

dbms_lock.sleep(10);


insert into latch_children_tmp(latch#,child#,name,misses,seq#,tim#)
select l.latch#,l.child#,l.name,l.misses,2,t.hsecs
from v$latch_children l,v$timer t;


    dbms_output.put_line('List top latch child misses');
    dbms_output.put_line('----------------------------------------------------------------');
    dbms_output.put_line('NAME                          LATCH#       CHILD#       MISSES/c');
    dbms_output.put_line('----------------------------------------------------------------');


CurrentRow := 1;
open MissesCur;
loop
    fetch MissesCur into MissesRec;
        exit when MissesCur%notfound or CurrentRow > ShowRows;

   dbms_output.put_line(rpad(MissesRec.name,30)||'  '||
rpad(to_char(MissesRec.latch#),10)||'  '||rpad(to_char(MissesRec.child#),10)||'  '||
to_char(MissesRec.missrate));

    CurrentRow := CurrentRow + 1;
end loop;
close MissesCur;


end;
/

set feedback on
