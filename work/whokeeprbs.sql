set linesize 120
set pagesize 30
set heading on
set ver off
set feedback on

ttitle center 'ROLLBACK KEEPERS' skip 1 -
       center  ================  skip 2

col name                     format a6
col rsize   heading SIZE     format a4
col usage   heading US(%)    format a5
col status                   format a7
col username                 format a10
col logon                    format a11
col trans_start_time         format a17
col sid                      format a4
col serial                   format a6
col s                        format a1
col event                    format a30

  select rpad(rn.segment_name,6) name,
  rpad(round(rs.rssize/1024/1024,0),4) rsize,
  rpad(round(rs.writes/rs.rssize*100,0),5) usage,
  rpad(substr(rn.status,1,7),7) status,
  rpad(s.username,10) username,
  to_char(logon_time,'mm/dd hh24:mi') logon,
  t.start_time trans_start_time,
  lpad(s.sid,4) sid,
  lpad(s.serial#,6) serial,
  rpad(substr(s.status,1,1),1) s,
  rpad(substr(sw.event,1,27),27) event
  from v$transaction t, v$rollstat rs,v$session s,
  dba_rollback_segs rn, v$session_wait sw
  where rs.usn=t.xidusn
  and t.ses_addr=s.saddr
  and s.sid=sw.sid
  and rs.usn=rn.segment_id
  and t.start_time = 
  (select min(start_time) from v$transaction tr
   where tr.xidusn = t.xidusn)
  order by t.start_time;


ttitle off
