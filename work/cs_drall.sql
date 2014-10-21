set feedback off
set pagesize 0

spool drop/drop_all.sql


select 'drop '||object_type||' '||object_name || decode(object_type,'TABLE',' CASCADE CONSTRAINTS') ||';'
   from user_objects
   where object_type in (
         'FUNCTION',
         'PACKAGE',
         'PROCEDURE',
         'SEQUENCE',
         'SYNONYM',
         'VIEW',
         'TABLE',
	 'TYPE')
   group by object_type, object_name;

spool off

set pagesize 12
set feedback on
