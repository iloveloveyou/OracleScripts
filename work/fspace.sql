set heading on
set pagesize 15
set linesize 80
set ver off
set echo off

select tablespace_name "TABLESPACE",
       count(*) "PIECES",
       max(bytes)/1024 "MAXIMUM (Kb)",
       avg(bytes)/1024 "AVERAGE (Kb)",
       sum(bytes)/1024 "TOTAL (Kb)"
   from sys.dba_free_space
   group by tablespace_name;
