/* Formatted on 08/04/2013 12:12:37 (QP5 v5.227.12220.39754) */
SET PAGES 300 LINES 300
SET TRIMSPOOL ON
COL event FORM a29
COL sql_op FORM a15
COL sql_id FORM a14
COL obj FORM a35
COL seq# FORM 999999
COL file# FORM 9999
COL block# FORM 999999
COL row# FORM 9999
COL sample_time FORM a20
COL sessid FORM 999999
COL program FORM a15
COL machine FORM a20
COL inst_id FORM 9999
COL serial# FORM 9999
COL session FORM a15
COL blocker FORM a10
COL file:block:row FORM a12
COL service_name FORM a10
COL os_pid FORM a6
COL status FORM a8
COL ela_min FORM 99999

  SELECT TO_CHAR (logon_time, 'dd/mm/yyyy hh24:mi:ss') logon_time,
         SQL_EXEC_START,
         username,
         ROUND (last_call_et / 60, 0) ela_min,
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
         machine
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
                 ROW_WAIT_OBJ# || ' ' || o.owner || ' ' || o.object_name obj,
                 ROW_WAIT_FILE# file#,
                 ROW_WAIT_BLOCK# block#,
                 ROW_WAIT_ROW# row#,
                 a.program,
                 a.machine,
                 a.status,
                 DECODE (command,
                         0, 'BACKGROUND',
                         1, 'Create Table',
                         2, 'INSERT',
                         3, 'SELECT',
                         4, 'CREATE CLUSTER',
                         5, 'ALTER CLUSTER',
                         6, 'UPDATE',
                         7, 'DELETE',
                         8, 'DROP',
                         9, 'CREATE INDEX',
                         10, 'DROP INDEX',
                         11, 'ALTER INDEX',
                         12, 'DROP TABLE',
                         13, 'CREATE SEQUENCE',
                         14, 'ALTER SEQUENCE',
                         15, 'ALTER TABLE',
                         16, 'DROP SEQUENCE',
                         17, 'GRANT',
                         18, 'REVOKE',
                         19, 'CREATE SYNONYM',
                         20, 'DROP SYNONYM',
                         21, 'CREATE VIEW',
                         22, 'DROP VIEW',
                         23, 'VALIDATE INDEX',
                         24, 'CREATE PROCEDURE',
                         25, 'ALTER PROCEDURE',
                         26, 'LOCK TABLE',
                         27, 'NO OPERATION',
                         28, 'RENAME',
                         29, 'COMMENT',
                         30, 'AUDIT',
                         31, 'NOAUDIT',
                         32, 'CREATE EXTERNAL DATABASE',
                         33, 'DROP EXTERNAL DATABASE',
                         34, 'CREATE DATABASE',
                         35, 'ALTER DATABASE',
                         36, 'CREATE ROLLBACK SEGMENT',
                         37, 'ALTER ROLLBACK SEGMENT',
                         38, 'DROP ROLLBACK SEGMENT',
                         39, 'CREATE TABLESPACE',
                         40, 'ALTER TABLESPACE',
                         41, 'DROP TABLESPACE',
                         42, 'ALTER SESSION',
                         43, 'ALTER USER',
                         44, 'COMMIT',
                         45, 'ROLLBACK',
                         46, 'SAVEPOINT',
                         47, 'PL/SQL EXECUTE',
                         48, 'SET TRANSACTION',
                         49, 'ALTER SYSTEM SWITCH LOG',
                         50, 'EXPLAIN',
                         51, 'CREATE USER',
                         52, 'CREATE ROLE',
                         53, 'DROP USER',
                         54, 'DROP ROLE',
                         55, 'SET ROLE',
                         56, 'CREATE SCHEMA',
                         57, 'CREATE CONTROL FILE',
                         58, 'ALTER TRACING',
                         59, 'CREATE TRIGGER',
                         60, 'ALTER TRIGGER',
                         61, 'DROP TRIGGER',
                         62, 'ANALYZE TABLE',
                         63, 'ANALYZE INDEX',
                         64, 'ANALYZE CLUSTER',
                         65, 'CREATE PROFILE',
                         66, 'DROP PROFILE',
                         67, 'ALTER PROFILE',
                         68, 'DROP PROCEDURE',
                         69, 'DROP PROCEDURE',
                         70, 'ALTER RESOURCE COST',
                         71, 'CREATE SNAPSHOT LOG',
                         72, 'ALTER SNAPSHOT LOG',
                         73, 'DROP SNAPSHOT LOG',
                         74, 'CREATE SNAPSHOT',
                         75, 'ALTER SNAPSHOT',
                         76, 'DROP SNAPSHOT',
                         79, 'ALTER ROLE',
                         85, 'TRUNCATE TABLE',
                         86, 'TRUNCATE CLUSTER',
                         87, '-',
                         88, 'ALTER VIEW',
                         89, '-',
                         90, '-',
                         91, 'CREATE FUNCTION',
                         92, 'ALTER FUNCTION',
                         93, 'DROP FUNCTION',
                         94, 'CREATE PACKAGE',
                         95, 'ALTER PACKAGE',
                         96, 'DROP PACKAGE',
                         97, 'CREATE PACKAGE BODY',
                         98, 'ALTER PACKAGE BODY',
                         99, 'DROP PACKAGE BODY',
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
ORDER BY 2
/