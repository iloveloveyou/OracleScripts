--Выводит схему текущего пользователя
set serveroutput on
set feedback off
declare
STR varchar2(100);
Cursor HostCur is
select host_name,INSTANCE_NAME
from v$instance;
HostRec HostCur%rowtype;
Username varchar2(50);
begin
open HostCur;
fetch HostCur into HostRec;
close HostCur;
select user into username from dual;

str:='You are '||USERname||' on '||HostRec.host_name||
'('||HostRec.INSTANCE_NAME||')';
dbms_output.enable;
dbms_output.put_line(str);
end;
/
set feedback on
