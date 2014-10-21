prompt Temporary segment usage
prompt

set feedback off
set ver off
set heading off
set serveroutput on


declare
Cursor t_cur is
select tablespace_name, sum(ROUND(bytes/1024/1024)) as ts_size
from dba_temp_files 
group by tablespace_name
union all
select tablespace_name, sum(ts_mb) as ts_size from
(select dt.tablespace_name tablespace_name,df.bytes/1024/1024 ts_mb
from dba_data_files df,dba_tablespaces dt
where dt.tablespace_name = df.tablespace_name
and dt.contents = 'TEMPORARY')
group by tablespace_name;

Cursor u_cur(tname varchar2) is
select nvl(sum(blocks/1024/1024),0) AS umb,
count(distinct(session_num)) cnt
from v$sort_usage
where tablespace = tname;
u_rec u_cur%rowtype;

bs number;
begin
	SELECT value into bs
	FROM v$parameter 
	WHERE name='db_block_size';

        dbms_output.put_line('TABLESPACE                    ALL(Mb)   USAGE(Mb) USAGE(%)  SESSIONS');
        dbms_output.put_line('____________________________________________________________________');        
    for t_rec in t_cur loop
        open u_cur(t_rec.tablespace_name);
        fetch u_cur into u_rec;
        close u_cur;
        
        dbms_output.put_line(rpad(t_rec.tablespace_name,30)||
        rpad(to_char(t_rec.ts_size),10)||
        rpad(to_char(round(u_rec.umb*bs)),10)||
        rpad(to_char(round(u_rec.umb*bs/t_rec.ts_size*100,2)),10)||
        rpad(to_char(u_rec.cnt),10));
    end loop;
        dbms_output.put_line('____________________________________________________________________');        

end;
/

prompt
prompt Top session list

set heading on
set linesize 120
set pagesize 20

col sid        format a5
col ser#       format a5
col orauser    format a10
col osuser     format a10
col program    format a25
col S          format a1
col tablespace format a15
col USAGE(MB)  format 999999

select * from(
select lpad(to_char(s.sid),5) sid,
       lpad(to_char(decode(sign(s.serial#), -1,
       65536+s.serial#, s.serial# )), 5) ser#,
       substr(s.username,1,10) orauser,
       substr(s.osuser,1,10) osuser,
       nvl(rpad(substr(upper(s.program),instr(s.program,'\',-1,1)+1,
       length(s.program)),25),'NOT DEFINED') program,
       substr(s.status,1,1) s,
       su.tablespace,
       su.umb as "USAGE(MB)"
from v$session s,
(select session_addr, tablespace,
round(sum(blocks*(SELECT value FROM v$parameter WHERE name='db_block_size')/1024/1024),2) AS umb
from v$sort_usage
group by session_addr,tablespace) su
where s.saddr = su.session_addr
order by umb desc)
where rownum < 16
/
prompt
set feedback on

