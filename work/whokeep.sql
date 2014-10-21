set linesize 140
set pagesize 0
set scan on
set ver off

col sid format 9990
col sid format 999990
col username format a10
col program format a40

spool kill_app.sql

select  distinct 'alter system kill session '||chr(39)||
    s.sid ||','|| s.serial#||chr(39)||';'
    from v$session s, sys.x$kglob ob, sys.x$kgllk lk
    where lk.kgllkhdl = ob.kglhdadr
        and  lk.kgllkuse = s.saddr
        and  ob.kglhdnsp != 0
        and  ob.kglnaobj= 'KK_PAY'
        and  ob.kglnaown = 'MTS24E'
/


spool off
