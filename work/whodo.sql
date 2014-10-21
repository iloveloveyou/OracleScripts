-- ¬ыводит SQL текст дл€ сессий с указанным SID'ом
--
set scan on
set linesize 80
set pagesize 30
set head on
set feed off
set ver off

define piece = 0
col c1 noprint
col c2 noprint
col c3 new_value piece noprint
col sid format 999990
col sql_text format a64
col state format a7

break on sid nodup on state skip 1 nodup

select sess.sid, text.sql_text, 'CURRENT' state,
    sess.sql_address c1, sess.sql_hash_value c2, text.piece c3
    from v$session sess, v$sqltext text
    where sess.sid in (&&1)
        and sess.sql_address = text.address
        and sess.sql_hash_value = text.hash_value
        and text.hash_value != 0
/*
union
select sess.sid, text.sql_text, 'PREVID' state,
    sess.prev_sql_addr c1, sess.prev_hash_value c2, text.piece c3
    from v$session sess, v$sqltext text
    where sess.sid in (&&1)
        and sess.prev_sql_addr = text.address
        and sess.prev_hash_value = text.hash_value
        and text.hash_value != 0
*/
order by 3, 1, 4, 5, 6
/

set pagesize 12
set linesize 80
set scan off
set ver on
