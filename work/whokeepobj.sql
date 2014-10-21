set linesize 120
set pagesize 0
set scan on
set ver off

col sid format 9990
col serial# format 999990
col username format a10
col program format a40
col machine format a40

prompt Getting DDL locks for object
accept NAME  prompt 'Enter object  name: '
accept SHEMA prompt 'Enter object shema: '

spool ddllocks.log

select  distinct s.sid sid, s.serial#, s.username, 
substr(s.program,1,30) program ,substr(s.machine,1,30) machine
    from v$session s, sys.x$kglob ob, sys.x$kgllk lk
    where lk.kgllkhdl = ob.kglhdadr
        and  lk.kgllkuse = s.saddr
        and  ob.kglhdnsp != 0
        and  upper(ob.kglnaobj) like upper('%&&NAME')
        and  upper(ob.kglnaown) = upper('&&SHEMA')
	order by 5
/

spool off
