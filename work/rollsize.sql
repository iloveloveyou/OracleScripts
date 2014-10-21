set linesize 130
set pagesize 30
set heading on
set ver off
set feedback on
set scan on

ttitle 'ROLLBACK SIZE' skip 1 -
       ==============  skip 2

col sid                      format 9999
col serial                   format 999999
col name                     format a6
col usn                      format 999
col username                 format a10
col osuser                   format a10
col machine                  format a10
col s                        format a1
col used_mb                  format 9999999999
col used_urec                format 999999999999


SELECT 
       n.name,
       r.usn,
       sid,
       serial# serial,
       username,
       substr(osuser,1,10) osuser,
       substr(s.machine,instr(s.machine,'\',1,1)+1,
       length(s.machine)) machine,
       substr(s.status,1,1) status,
       ROUND(used_ublk*(SELECT value FROM v$parameter 
                        WHERE name='db_block_size')/1024/1024) AS Used_Mb,
       used_urec
FROM v$session s,v$transaction t,v$rollstat r,v$rollname n, DBA_ROLLBACK_SEGS d
WHERE s.taddr = t.addr 
AND t.xidusn = r.usn
AND n.usn=r.usn
AND r.usn=d.segment_id
--and ((r.curext = t.start_uext - 1) or ((r.curext = r.extents - 1) and  (t.start_uext = 0)))
--and sid = 2733
--and s.machine like '%MARI%'
--and s.osuser = 'les'
--AND r.usn IN (10) -- номер rollback
--and s.status = 'KILLED'
--and name like 'RBIG%'
ORDER BY name,Used_urec desc
/

ttitle off
