set linesize 90
set pagesize 30
set heading on
set ver off
set feedback on
set scan off

col group#     format a7
col members    format a7
col archived   format a15
col status     format a10
col member     format a40

select  to_char(l.group#) group#,
	to_char(l.members) members,
	l.archived,
	l.status,
	lf.member
from v$log l,v$logfile lf
where l.group# = lf.group#;



