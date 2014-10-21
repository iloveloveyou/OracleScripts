set ver on
set scan on

accept uname prompt "Enter XA-user name:"
accept upasswd prompt "Enter XA-user password:"
accept utblsps prompt "Enter default XA-user tablespace:"


create user &&uname
identified by &&upasswd
default tablespace &&utblsps
temporary tablespace temp
quota unlimited on &&utblsps;

grant connect to &&uname;
grant resource to &&uname;
grant select on DBA_PENDING_TRANSACTIONS to &&uname;
grant select on V$XATRANS$ to &&uname;