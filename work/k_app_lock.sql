set linesize 80
set pagesize 12
set scan on
set ver off

col sid format 9990
col username format a10
col owner format a10
col name format a15
col type format a8
col held format a7
col request format a7


spool ddllocks.log
select  distinct 'alter system kill session '||chr(39)||s.sid||','||s.serial#||chr(39)||';'
    from v$session s, sys.x$kglob ob, sys.x$kgllk lk
    where lk.kgllkhdl = ob.kglhdadr
        and  lk.kgllkuse = s.saddr
        and  ob.kglhdnsp != 0
        and  upper(ob.kglnaobj) like upper('KK_BREP_INTR')
        and  upper(ob.kglnaown) = upper('MTS24E')
	and s.sid != 3505
order by sid desc
/

spool off
