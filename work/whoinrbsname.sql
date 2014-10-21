set linesize 130
set pagesize 30
set heading on
set ver off
set feedback on
set scan on

ttitle center 'ROLLBACK STAT' skip 1 -
       center  ==============  skip 2

col name                     format a6
col username                 format a10
col st                       format a2
col logon                     format a8
col trans_start_time         format a17
col sid                      format a4
col serial                   format a6
col s                        format a1
col machine                  format a10
col program                  format a15
col event                    format a21

  select rpad(rn.segment_name,6) name,
  rpad(s.username,10) username,
  substr(rn.status,1,2) st,
  to_char(logon_time,'dd-hh24:mi') logon,
  t.start_time trans_start_time,
  lpad(s.sid,4) sid,
  lpad(s.serial#,6) serial,
  rpad(substr(s.status,1,1),1) s,
  substr(s.machine,instr(s.machine,'\',1,1)+1,
  length(s.machine)) machine,
  nvl(rpad(substr(upper(s.program),instr(s.program,'\',-1,1)+1,
  length(s.program)),15),'NOT DEFINED') program,
  rpad(substr(sw.event,1,21),21) event
  from v$transaction t, v$rollstat rs,v$session s,
  dba_rollback_segs rn, v$session_wait sw
  where rs.usn=t.xidusn(+)
  and t.ses_addr=s.saddr(+)
  and s.sid=sw.sid(+)
  and rs.usn(+)=rn.segment_id
  and rn.segment_name like upper('%&1%')
  order by t.start_time;

ttitle off
