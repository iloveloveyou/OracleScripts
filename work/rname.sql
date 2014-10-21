set linesize 90
set pagesize 30
set heading on
set ver off
set feedback on
set scan on

col N          format a10
col NAME       format a70

select lpad(to_char(segment_id),10) N,
       substr(segment_name,1,70) name
       from dba_rollback_segs
       where segment_id =&1;

set pagesize 12
set feedback on
set ver on