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

prompt Getting DDL locks for object
accept NAME  prompt 'Enter object  name: '
accept SHEMA prompt 'Enter object shema: '

spool ddllocks.log

select  s.sid sid, s.username,
        substr(ob.kglnaown,1,10) owner,
        substr(ob.kglnaobj,1,15) name,
        decode(ob.kglhdnsp, 0, 'Cursor', 1, 'Tab/Proc', 2, 'Body', 3, 'Trigger',
            4, 'Index', 5, 'Cluster', 'Unknown') type,
        decode(lk.kgllkmod, 0, 'None', 1, 'Null', 2, 'Share',
            3, 'Excl.','Unknown') held,
        decode(lk.kgllkreq,  0, 'None', 1, 'Null', 2, 'Share',
            3, 'Excl.','Unknown') request
    from v$session s, sys.x$kglob ob, sys.x$kgllk lk
    where lk.kgllkhdl = ob.kglhdadr
        and  lk.kgllkuse = s.saddr
        and  ob.kglhdnsp != 0
        and  upper(ob.kglnaobj) like upper('%&&NAME')
        and  upper(ob.kglnaown) = upper('&&SHEMA')
    order by 3 desc, 2, 1, 6
/

spool off
