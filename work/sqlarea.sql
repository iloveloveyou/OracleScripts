set linesize 80
set pagesize 30
set heading on
set ver off
set feedback on
set scan on

col sid       format a5
col ser#      format a5
col PID       format a7
col SQL       format a60

        select 
        lpad(to_char(s.sid),5) sid,
        lpad(to_char(decode(sign(s.serial#), -1,
        65536+s.serial#, s.serial# )), 5) ser#,
        lpad(to_char(p.spid),7) PID, 
        sq.sql_text SQL
        from v$sql sq,v$session s,v$process p
        where sq.address = s.sql_address
        and sq.hash_value = s.sql_hash_value
        and p.addr = s.paddr
        and sql_text like '%address%'
        and sq.sql_text not like '%like ''%address%''%'
/
set pagesize 12
set feedback on
set ver on
