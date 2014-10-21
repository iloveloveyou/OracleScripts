declare
Cursor ObjectsCur is
select object_name from all_objects
where owner = 'MTS24E';
 
 Cursor SynonymCur is
 select synonym_name,table_name from all_synonyms
 where owner = 'MTS24E';
 
i number;
str varchar2(2000);
begin
for ObjectsRec in ObjectsCur loop
str := 'create synonym '||ObjectsRec.object_name||' for mts24e.'||
ObjectsRec.object_name;
	i := dbms_sql.open_cursor;
    begin
	dbms_sql.parse(i,str,dbms_sql.NATIVE);
    exception
        when others then null;
    end;
	dbms_sql.close_cursor(i);
end loop;
for SynonymRec in SynonymCur loop
str := 'create synonym '||SynonymRec.synonym_name||' for mts24e.'||
SynonymRec.table_name;
	i := dbms_sql.open_cursor;
    begin
	dbms_sql.parse(i,str,dbms_sql.NATIVE);
    exception
        when others then null;
    end;
	dbms_sql.close_cursor(i);
end loop;

end;
