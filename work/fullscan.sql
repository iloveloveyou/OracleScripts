/*  Vijay Fernando INTEL CORPORATION */
/* 7th June 2002  */
/* Recent full table scan */ 
/* Should be run as SYS user */
set serverout on size 1000000
set verify off

set linesize 100
col object_name format a30
col object_type format a10
col owner format a10
col kol format a10

PROMPT Column flag in x$bh table is set to value 0x80000, when
PROMPT block was read by a sequential scan. 

spool recentfulltablescan.lst

SELECT o.object_name,o.object_type,o.owner,to_char(count(*)) kol
FROM dba_objects o,x$bh x
WHERE x.obj=o.object_id
AND o.object_type='TABLE' 
AND standard.bitand(x.flag,524288)>0 
AND o.owner<>'SYS'
Group by o.object_name,o.object_type,o.owner
Order by count(*) desc;

spool off

