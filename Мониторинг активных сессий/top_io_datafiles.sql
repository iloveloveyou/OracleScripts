set echo off
set feedback off
set linesize 512

prompt
prompt Top Tablespaces by IO consumption
prompt

column file_name		format a60     		heading "Data-File Name"
column ts_name			format a32     		heading "Tablespace Name"
column stat_reads		format 999,999,999,999  heading "Physical Reads"
column stat_writes		format 999,999,999,999  heading "Physical Writes"
column stat_breads		format 999,999,999,999  heading "Physical Blk-Reads"
column stat_bwrites		format 999,999,999,999  heading "Physical Blk-Writes"

break on ts_name

select  
	t.name  	ts_name,
	f.name		file_name,
	s.phyrds	stat_reads,
	s.phyblkrd	stat_breads,
	s.phywrts	stat_writes,
	s.phyblkwrt	stat_bwrites
from
	v$tablespace t,
	v$datafile f,
	v$filestat s
where
	t.ts# = f.ts# 
and
	f.file# = s.file#
order by s.phyrds desc, s.phywrts desc;