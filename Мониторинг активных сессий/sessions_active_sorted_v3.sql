/* Formatted on 08/04/2013 12:12:37 (QP5 v5.227.12220.39754) */
SET PAGES 200 LINES 400
SET TRIMSPOOL ON
set wrap off
col "SQL start/elap" form a20
COL event FORM a25 
COL sql_op FORM a15
COL obj FORM a25 
COL username FORM a10
col sql_id form a15
COL seq# FORM 999999
COL file# FORM 9999
COL block# FORM 999999
COL row# FORM 9999
COL sample_time FORM a20
COL machine FORM a20
COL inst_id FORM 9999
COL serial# FORM 9999
COL session FORM a15
COL blocker FORM a10
COL file:block:row FORM a12
COL service_name FORM a10
COL os_pid FORM a6
COL SID FORM 99999
COL sessid FORM a6
COL status FORM a8
COL sql_elap FORM 99999
COL parallel_sess FORM a20
COL machine FORM a20 

  SELECT TO_CHAR (SQL_EXEC_START, 'dd/mm hh24:mi:ss')||' / '||ROUND (last_call_et / 60, 0) "SQL start/elap",
         TO_CHAR (logon_time, 'dd/mm hh24:mi:ss') logon_time,                  
         username,
         sessid as SID,
         os_pid,
         '(' || sessid || ',' || serial# || ',@' || inst_id || ')' "SESSION",
         '(' || blocking_session || ',,@' || blocking_instance || ')' "BLOCKER",
         seq#,
         event,
         sql_id,
         sql_op,
         obj,
         file# || ':' || block# || ':' || row# "file:block:row",
         status,
         parallel_sess,
         machine,
         substr(program,1,25) as program 
    FROM (SELECT a.logon_time,
                 a.SQL_EXEC_START,
                 a.username,
                 a.last_call_et,
                 a.inst_id inst_id,
                 p.spid os_pid,
                 a.sid sessid,
                 a.serial# serial#,
                 a.seq#,
                 a.event,
                 a.sql_id,
                 blocking_session,
                 blocking_instance,
                 blocking_session_status,
--                 ROW_WAIT_OBJ# || ' ' || o.owner || ' ' || o.object_name obj,
                 o.owner || ' ' || o.object_name obj,
                 ROW_WAIT_FILE# file#,
                 ROW_WAIT_BLOCK# block#,
                 ROW_WAIT_ROW# row#,
                 a.program,
                 a.machine,
                 a.status,
                 case when a.ownerid=2147483644 then 'MASTER' else 'SID='||bitand(a.ownerid, 65535) ||', INST='|| bitand(a.ownerid, 4294967296 - 65535) / 65536 end parallel_sess,
                 DECODE (command,
                                            1,'CREATE TABLE',2,'INSERT',3,'SELECT',
                                            4,'CREATE CLUSTER',5,'ALTER CLUSTER',6,'UPDATE',
                                            7,'DELETE',8,'DROP CLUSTER',9,'CREATE INDEX',
                                            10,'DROP INDEX',11,'ALTER INDEX',12,'DROP TABLE',
                                            13,'CREATE SEQUENCE',14,'ALTER SEQUENCE',15,'ALTER TABLE',
                                            16,'DROP SEQUENCE',17,'GRANT OBJECT',18,'REVOKE OBJECT',
                                            19,'CREATE SYNONYM',20,'DROP SYNONYM',21,'CREATE VIEW',
                                            22,'DROP VIEW',23,'VALIDATE INDEX',24,'CREATE PROCEDURE',
                                            25,'ALTER PROCEDURE',26,'LOCK',27,'NO-OP',28,'RENAME',
                                            29,'COMMENT',30,'AUDIT OBJECT',31,'NOAUDIT OBJECT',32,'CREATE DATABASE LINK',
                                            33,'DROP DATABASE LINK',34,'CREATE DATABASE',35,'ALTER DATABASE',
                                            36,'CREATE ROLLBACK SEG',37,'ALTER ROLLBACK SEG',38,'DROP ROLLBACK SEG',
                                            39,'CREATE TABLESPACE',40,'ALTER TABLESPACE',41,'DROP TABLESPACE',
                                            42,'ALTER SESSION',43,'ALTER USER',44,'COMMIT',45,'ROLLBACK',
                                            46,'SAVEPOINT',47,'PL/SQL EXECUTE',48,'SET TRANSACTION',49,'ALTER SYSTEM',
                                            50,'EXPLAIN',51,'CREATE USER',52,'CREATE ROLE',53,'DROP USER',54,'DROP ROLE',
                                            55,'SET ROLE',56,'CREATE SCHEMA',57,'CREATE CONTROL FILE',59,'CREATE TRIGGER',
                                            60,'ALTER TRIGGER',61,'DROP TRIGGER',62,'ANALYZE TABLE',63,'ANALYZE INDEX',
                                            64,'ANALYZE CLUSTER',65,'CREATE PROFILE',66,'DROP PROFILE',67,'ALTER PROFILE',
                                            68,'DROP PROCEDURE',70,'ALTER RESOURCE COST',71,'CREATE SNAPSHOT LOG',
                                            72,'ALTER SNAPSHOT LOG',73,'DROP SNAPSHOT LOG',74,'CREATE SNAPSHOT',
                                            75,'ALTER SNAPSHOT',76,'DROP SNAPSHOT',77,'CREATE TYPE',78,'DROP TYPE',
                                            79,'ALTER ROLE',80,'ALTER TYPE',81,'CREATE TYPE BODY',82,'ALTER TYPE BODY',
                                            83,'DROP TYPE BODY',84,'DROP LIBRARY',85,'TRUNCATE TABLE',86,'TRUNCATE CLUSTER',
                                            91,'CREATE FUNCTION',92,'ALTER FUNCTION',93,'DROP FUNCTION',94,'CREATE PACKAGE',
                                            95,'ALTER PACKAGE',96,'DROP PACKAGE',97,'CREATE PACKAGE BODY',98,'ALTER PACKAGE BODY',
                                            99,'DROP PACKAGE BODY',100,'LOGON',101,'LOGOFF',102,'LOGOFF BY CLEANUP',
                                            103,'SESSION REC',104,'SYSTEM AUDIT',105,'SYSTEM NOAUDIT',106,'AUDIT DEFAULT',
                                            107,'NOAUDIT DEFAULT',108,'SYSTEM GRANT',109,'SYSTEM REVOKE',110,'CREATE PUBLIC SYNONYM',
                                            111,'DROP PUBLIC SYNONYM',112,'CREATE PUBLIC DATABASE LINK',113,'DROP PUBLIC DATABASE LINK',
                                            114,'GRANT ROLE',115,'REVOKE ROLE',116,'EXECUTE PROCEDURE',117,'USER COMMENT',
                                            118,'ENABLE TRIGGER',119,'DISABLE TRIGGER',120,'ENABLE ALL TRIGGERS',121,'DISABLE ALL TRIGGERS',
                                            122,'NETWORK ERROR',123,'EXECUTE TYPE',157,'CREATE DIRECTORY',158,'DROP DIRECTORY',
                                            159,'CREATE LIBRARY',160,'CREATE JAVA',161,'ALTER JAVA',162,'DROP JAVA',163,'CREATE OPERATOR',
                                            164,'CREATE INDEXTYPE',165,'DROP INDEXTYPE',167,'DROP OPERATOR',168,'ASSOCIATE STATISTICS',
                                            169,'DISASSOCIATE STATISTICS',170,'CALL METHOD',171,'CREATE SUMMARY',172,'ALTER SUMMARY',
                                            173,'DROP SUMMARY',174,'CREATE DIMENSION',175,'ALTER DIMENSION',176,'DROP DIMENSION',
                                            177,'CREATE CONTEXT',178,'DROP CONTEXT',179,'ALTER OUTLINE',180,'CREATE OUTLINE',
                                            181,'DROP OUTLINE',182,'UPDATE INDEXES',183,'ALTER OPERATOR',
                         command || ' - ???')
                    sql_op
            FROM gv$session a,
                 gv$process p,
                 dba_objects o,
                 dba_users u
           WHERE     a.username = u.username
                 AND a.paddr = p.addr
                 AND o.data_object_id(+) = a.row_wait_obj#
                 AND u.username NOT IN ('DBSNMP', 'SYS', 'SYSTEM')
                 AND a.status <> 'INACTIVE'
                 AND (    (a.USERNAME IS NOT NULL)
                      AND (NVL (a.osuser, 'x') <> 'SYSTEM')
                      AND (a.TYPE <> 'BACKGROUND')))
ORDER BY SQL_EXEC_START
/

