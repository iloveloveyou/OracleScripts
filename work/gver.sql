--Get version of package

set scan on
set feedback off
set ver off
set heading off


prompt Enter name of package 
accept pname prompt 'PACKAGE: '
prompt **************************
set serveroutput on

declare
p varchar2(50);
l_c integer;
l_res integer;
string varchar2(4000);
p_not_found EXCEPTION;
p_not_compile EXCEPTION;
PRAGMA EXCEPTION_INIT(p_not_found, -6550);
PRAGMA EXCEPTION_INIT(p_not_compile, -4063);
begin
p:= upper ('&&pname');
string := 'declare v varchar2(50); ' ||
          'begin ' ||
          'v :=' || p || '.GETVERSION; ' ||       
          'dbms_output.enable; ' ||
          'dbms_output.put_line(''Version of package is: ''' || 
          '||' || 'v); ' ||
          'end;';
l_c := dbms_sql.open_cursor;
dbms_sql.parse( l_c, string, dbms_sql.NATIVE );
l_res := dbms_sql.execute( l_c );
dbms_sql.close_cursor( l_c );

EXCEPTION
      WHEN p_not_found THEN
       begin
       dbms_output.enable; 
       dbms_output.put_line('Package ' || p || ' or function ' || p ||'.GETVERSION ');
       dbms_output.put_line('is not present in this scheme');
       end; 
      WHEN p_not_compile THEN
       begin
       declare
       str varchar2(4000);
       begin
       dbms_output.enable; 
       dbms_output.put_line('Package ' || p || ' have errors!!! ');
       select text into str
       from user_source
       where name = p
       and text like '%3.0%';
       dbms_output.put_line('Version from source of package is:');
       dbms_output.put_line(str);
      EXCEPTION
       when no_data_found then 
       dbms_output.put_line('And source have not string with version...');
       end;
       end; 

end;
/


set ver on
set feedback on
set heading on
