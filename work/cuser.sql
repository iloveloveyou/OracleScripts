set ver on
set scan on

accept uname prompt "Enter user name:"
accept upasswd prompt "Enter user password:"
accept utblsps prompt "Enter default user tablespace:"


create user &&uname
identified by &&upasswd
default tablespace &&utblsps
temporary tablespace temp
quota unlimited on &&utblsps;

grant create session to &&uname;
grant create table to &&uname;
grant create view to &&uname;
grant create sequence to &&uname;
grant create procedure to &&uname;
grant create trigger to &&uname;
grant create synonym to &&uname;
grant create database link to &&uname;

grant select on v_$process to &&uname;
grant select on v_$rollstat to &&uname;
grant select on V_$SYSSTAT to &&uname;
grant select on v_$session to &&uname;
grant select on V_$SYSTEM_EVENT to &&uname;
grant select on V_$BACKUP_DATAFILE to &&uname;
grant select on V_$DATABASE to  &&uname;
grant select on V_$PARAMETER to &&uname;
grant select on dba_ddl_locks to &&uname;
grant select on V_$ROLLNAME to  &&uname;

grant execute on dbms_sql to &&uname;
grant execute on dbms_lock to &&uname;
grant execute on dbms_pipe to &&uname;
grant execute on dbms_alert to &&uname;
grant execute on dbms_job to &&uname;
grant execute on dbms_space to &&uname;
grant execute on dbms_system to &&uname;

--grant alter system to &&uname;
