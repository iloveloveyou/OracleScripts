declare
Cursor ObjectCur is
select object_name,decode(object_type,'TABLE','ALL','VIEW','ALL',
'SEQUENCE','ALL','PACKAGE','EXECUTE','FUNCTION','EXECUTE',
'PROCEDURE','EXECUTE') grant_type from user_objects uo
where object_type in ('TABLE','VIEW','SEQUENCE')
and status = 'VALID'
and not exists
    (select 1 from  user_tab_privs_made
    where grantee = 'MTS24T' and table_name = uo.object_name);

i number;
str varchar2(2000);

begin
for ObjectRec in ObjectCur loop
    str := 'grant '||ObjectRec.grant_type||' on '||ObjectRec.object_name||' to mts24t';
    i := dbms_sql.open_cursor;
    dbms_sql.parse(i,str,dbms_sql.NATIVE);
end loop;
exception
    when others then
        dbms_output.put_line(SQLERRM||' '||str);
end;
