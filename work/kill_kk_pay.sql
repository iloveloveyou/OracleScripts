set linesize 140
set pagesize 12
set scan on
set ver off

col sid format 9990
col sid format 999990
col username format a10
col program format a40


select  distinct s.sid sid, s.serial# serial#,s.username,
        substr(s.program,1,40) program
    from v$session s, sys.x$kglob ob, sys.x$kgllk lk
    where lk.kgllkhdl = ob.kglhdadr
        and  lk.kgllkuse = s.saddr
        and  ob.kglhdnsp != 0
        and  ob.kglnaobj= 'KK_PAY'
        and  ob.kglnaown = 'MTS24E'
/

