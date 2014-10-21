col owner format a15
col type format a15
col name format a30
set pagesize 0
set linesize 100
set pause off
break on type
spool compile.sql
select  'alter ' || decode( o.object_type, 'VIEW', 'VIEW', 'PACKAGE',
           'PACKAGE',
           'PACKAGE BODY', 'PACKAGE', 'PROCEDURE', 'PROCEDURE', 'TRIGGER',
           'TRIGGER', 'FUNCTION', 'FUNCTION') || ' ' || o.owner || '.' ||
        o.object_name || ' compile ' ||   decode( o.object_type, 'VIEW', '',
           'PACKAGE',
           'PACKAGE', 'PACKAGE BODY', 'BODY', 'PROCEDURE', '', 'TRIGGER',
           '', 'FUNCTION', '') || ';'
  from all_objects o
  where o.owner = user
    and o.object_type in ( 'VIEW', 'PACKAGE', 'PACKAGE BODY', 'PROCEDURE', 'TRIGGER',
                           'FUNCTION')
    and o.status ='INVALID'
  order by o.owner, o.object_type, o.object_name;
spool off
