REM --------------------------------------------------------------------------------------------- 
REM File:         sos_sessions_active.sql
REM Description:  To list active sessions in a RAC or non-RAC database
REM ---------------------------------------------------------------------------------------------
REM Website:      http://sosdba.wordpress.com
REM Important:    Copyright 2011 SOS DBA (Tam Nguyen)
REM
REM               Redistribution of script and source code with or without modification is
REM               permitted based on the following conditions:
REM
REM               1. Redistribution must retain the copyright notice with list of conditions
REM                  mentioned, following disclaimer and references to SOS DBA.
REM               2. Stated changes by the modifier and revision.
REM               3. In no event shall the copyright holder be liable for any
REM                  direct, indirect, incidental, or consequential
REM                  damages.
REM ----------------------------------------------------------------------------------------------
REM Notes:        Run as SYSDBA or database user with select privileges on the data dictionary 
REM               tables and views mentioned in the query.
REM               Multiple rows are likely to return for the query.  
REM               It is recommended that spooling to a file may be required for analysis.
REM Known Issues: 
REM Revision:     v2011_10_02  TN : Initial 
REM ----------------------------------------------------------------------------------------------

set pages 300 lines 300
set trimspool on
col event form a29
col sql_op form a15
col sql_id form a14
col obj form a35
col seq# form 999999
col file# form 9999
col block# form 999999
col row# form 9999
col sample_time form a20
col sessid form 999999
col program form a15
col machine form a20
col inst_id form 9999
col serial# form 9999
col session form a15
col blocker form a10
col file:block:row form a12
col service_name form a10
col os_pid form a6
col status form a8
col ela_min form 99999

select to_char(logon_time,'dd/mm/yyyy hh24:mi:ss') logon_time, round(last_call_et/60,0) ela_min, os_pid, 
'('||sessid||','||serial#||',@'||inst_id||')' "SESSION" ,
        '('||blocking_session||',,@'||blocking_instance||')' "BLOCKER",
        seq#,event, sql_id, sql_op, 'obj', file#||':'||block#||':'||row# "file:block:row", status, machine
    from
    (select a.logon_time, a.last_call_et,a.inst_id inst_id, p.spid os_pid, a.sid sessid, a.serial# serial#, a.seq#, a.event, a.sql_id,
        blocking_session, blocking_instance, blocking_session_status,
                  ROW_WAIT_OBJ# || ' ' || 'name obj'
                 ,ROW_WAIT_FILE# file#
                 ,ROW_WAIT_BLOCK#  block#
                 ,ROW_WAIT_ROW# row#
                 ,a.program
                 ,a.machine
                 ,a.status
                 ,decode(command, 
                0,'BACKGROUND', 
                1,'Create Table', 
                2,'INSERT', 
                3,'SELECT', 
                4,'CREATE CLUSTER', 
                5,'ALTER CLUSTER', 
                6,'UPDATE', 
                7,'DELETE', 
                8,'DROP', 
                9,'CREATE INDEX', 
                10,'DROP INDEX', 
                11,'ALTER INDEX', 
                12,'DROP TABLE', 
                13,'CREATE SEQUENCE', 
                14,'ALTER SEQUENCE', 
                15,'ALTER TABLE', 
                16,'DROP SEQUENCE', 
                17,'GRANT', 
                18,'REVOKE', 
                19,'CREATE SYNONYM', 
                20,'DROP SYNONYM', 
                21,'CREATE VIEW', 
                22,'DROP VIEW', 
                23,'VALIDATE INDEX', 
                24,'CREATE PROCEDURE', 
                25,'ALTER PROCEDURE', 
                26,'LOCK TABLE', 
                27,'NO OPERATION', 
                28,'RENAME', 
                29,'COMMENT', 
                30,'AUDIT', 
                31,'NOAUDIT', 
                32,'CREATE EXTERNAL DATABASE', 
                33,'DROP EXTERNAL DATABASE', 
                34,'CREATE DATABASE', 
                35,'ALTER DATABASE', 
                36,'CREATE ROLLBACK SEGMENT', 
                37,'ALTER ROLLBACK SEGMENT', 
                38,'DROP ROLLBACK SEGMENT', 
                39,'CREATE TABLESPACE', 
                40,'ALTER TABLESPACE', 
                41,'DROP TABLESPACE', 
                42,'ALTER SESSION', 
                43,'ALTER USER', 
                44,'COMMIT', 
                45,'ROLLBACK', 
                46,'SAVEPOINT', 
                47,'PL/SQL EXECUTE', 
                48,'SET TRANSACTION', 
                49,'ALTER SYSTEM SWITCH LOG', 
                50,'EXPLAIN', 
                51,'CREATE USER', 
                52,'CREATE ROLE', 
                53,'DROP USER', 
                54,'DROP ROLE', 
                55,'SET ROLE', 
                56,'CREATE SCHEMA', 
                57,'CREATE CONTROL FILE', 
                58,'ALTER TRACING', 
                59,'CREATE TRIGGER', 
                60,'ALTER TRIGGER', 
                61,'DROP TRIGGER', 
                62,'ANALYZE TABLE', 
                63,'ANALYZE INDEX', 
                64,'ANALYZE CLUSTER', 
                65,'CREATE PROFILE', 
                66,'DROP PROFILE', 
                67,'ALTER PROFILE', 
                68,'DROP PROCEDURE', 
                69,'DROP PROCEDURE',
                70,'ALTER RESOURCE COST', 
                71,'CREATE SNAPSHOT LOG', 
                72,'ALTER SNAPSHOT LOG', 
                73,'DROP SNAPSHOT LOG', 
                74,'CREATE SNAPSHOT', 
                75,'ALTER SNAPSHOT', 
                76,'DROP SNAPSHOT', 
                79,'ALTER ROLE',
                85,'TRUNCATE TABLE', 
                86,'TRUNCATE CLUSTER', 
                87,'-', 
                88,'ALTER VIEW', 
                89,'-', 
                90,'-', 
                91,'CREATE FUNCTION', 
                92,'ALTER FUNCTION', 
                93,'DROP FUNCTION', 
                94,'CREATE PACKAGE', 
                95,'ALTER PACKAGE', 
                96,'DROP PACKAGE', 
                97,'CREATE PACKAGE BODY', 
                98,'ALTER PACKAGE BODY', 
                99,'DROP PACKAGE BODY', 
                command||' - ???') sql_op
     from gv$session a, gv$process p,
              dba_users u
    where a.username=u.username
    and a.paddr=p.addr
   and u.username not in ('DBSNMP','SYS','SYSTEM')
   and a.status <> 'INACTIVE'
   AND  ( (a.USERNAME is not null) and (NVL(a.osuser,'x') <> 'SYSTEM') and (a.type <> 'BACKGROUND') )
   )
   order by 1
/
