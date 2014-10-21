set pagesize 0
set ver off
set scan on

spool kill/killobjlocker.sql

select distinct 'alter system kill session '''||
	s.sid||','||s.serial#||''''||'/* '||s.machine||' '||
        substr(s.program,1,40)||' */;'
    from v$session s, sys.x$kglob ob, sys.x$kgllk lk
    where lk.kgllkhdl = ob.kglhdadr
        and  lk.kgllkuse = s.saddr
        and  ob.kglhdnsp != 0
        and  ob.kglnaobj= '&1'
        and  ob.kglnaown = 'MTS24E'
/

