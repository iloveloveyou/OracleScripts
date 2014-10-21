/*  Vijay Fernando INTEL CORPORATION */
/* 7th June 2002  */
/* Recently used indexes */
/* Should be run as SYS user */
set serverout on size 1000000
set verify off

column owner format a20 trunc
column segment_name format a30 trunc

spool indexused.lst

select distinct b.owner, b.segment_name
from x$bh a, dba_extents b         
where b.file_id=a.dbarfil 
and a.dbablk between b.block_id 
and b.block_id+blocks-1 
and segment_type='INDEX' and  b.owner not in ('SYS','SYSTEM')
/

spool off

