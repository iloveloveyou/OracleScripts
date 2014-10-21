set pagesize 0
set ver off
set scan on
set feedback off

spool kill/killsess.sql

select 'alter system kill session '''||sid||','||
serial#||''''||'/* '||machine||' '||substr(program,1,40)||' */;'
from v$session
where upper(machine) like upper('%&1%')
and (
        upper(program) like '%F50RUN32.EXE%'
        or upper(program) like '%CBOSS4.EXE%'
    )
--and username = 'MTS24E'
/

spool off
set feedback on