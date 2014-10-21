

-------------------------------------
-- Disk statistic by sessions
-------------------------------------
set linesize 120
set pagesize 30
set serveroutput on
set ver off
set scan on
column stat_name format a22
column name format a22
column stat_value format 999999
column sid format 99999
column machine format a15
column osuser format a13
column program format a27
column client_info format a13

prompt Incremental session statisticts
prompt Statistic number:
prompt session logical reads: 9
prompt physical reads:        40
prompt physical reads direct: 86
prompt db block changes:      41
prompt execute count:         181
prompt redo size:             101 
prompt parse count (total):   179 
prompt parse count (hard):    180

accept statnumber prompt "ENTER STATISTIC NUMBER: "

prompt
prompt Na ekran budut vivedeni tol'ko znacheniya bolee chem THRESHOLD_VALUE:
select name, threshold_value 
from pcpu.st_thresholds
where statistic#=&&statnumber;

prompt Please, wait ...

exec pcpu.p_st.sesstat;

select stat_name, stat_value, sid, machine, osuser, program, client_info from pcpu.st_sesstat
where dt=(select max(dt) from pcpu.st_sesstat)
--and stat_name='session logical reads'
and statistic#=&&statnumber
order by dt desc, stat_name, stat_value desc
/
quit
