-- Выводит ошибки компиляции для текущей схемы

set pagesize 30
set heading on
set linesize 80
set arraysize 1

col NAME  heading NAME  format a20
col TYPE  heading TYPE  format a20
col ERROR heading ERROR format a37

break on name
prompt Ошибки компиляции

select distinct rpad(name,20) NAME,
rpad(type,20) TYPE,text ERROR
from user_errors
order by name
/

set heading off