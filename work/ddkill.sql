set linesize 80
set pagesize 1200
set scan on
set ver off

prompt Getting DDL locks for object
accept NAME prompt 'Enter object name (mts24e): '

set heading off

spool kill_file.sql


SELECT DISTINCT 'alter system kill session '||''''||s.sid||','||LPAD(TO_CHAR(DECODE(SIGN(s.serial#), -1,
         65536+s.serial#, s.serial# )), 5)||''';'
    from v$session s, sys.x$kglob ob, sys.x$kgllk lk
    where lk.kgllkhdl = ob.kglhdadr
        and  lk.kgllkuse = s.saddr
        and  ob.kglhdnsp != 0
        and  upper(ob.kglnaobj) like upper('%&&NAME')
        and  upper(ob.kglnaown) like upper('MTS24E')
	AND  upper(s.machine) not like '%VENUS%' and  upper(s.machine) not like 'ZEUS';

spool off

