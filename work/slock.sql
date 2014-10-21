set linesize 110
set pagesize 30
set heading on
set feedback on

col SID        format a6
col SER#       format a5
col MACHINE    format a10
col ORAUSER    format a10
col OBJECT     format a20
col HELD       format a10
col REQUEST    format a10
col LTYPE      format a20

SELECT  decode(l.BLOCK,0,' ','')||l.SID SID,
        lpad(to_char(decode(sign(s.serial#), -1,
         65536+s.serial#, s.serial# )), 5) ser#,
        substr(s.machine,instr(s.machine,'\',1,1)+1,
        length(s.machine)) MACHINE,
        lo.ORACLE_USERNAME ORAUSER,
        o.owner||'.'||o.object_name OBJECT,
        DECODE(l.LMODE,0,'None',1,'Null',2,'Row-S (SS)',3,'Row-X (SX)',4,'Share',
        5,'S/Row-X (SSX)',6,'Exclusive',TO_CHAR(l.LMODE)) HELD,
        DECODE(l.REQUEST,0,'None',1,'Null',2,'Row-S (SS)',3,'Row-X (SX)',4,'Share',
        5,'S/Row-X (SSX)',6,'Exclusive',TO_CHAR(l.REQUEST)) REQUEST,
        DECODE(l.TYPE,'MR','Media Recovery','RT','Redo Thread',
        'UN','User Name','TX','Transaction','TM','DML','UL',
        'PL/SQL User Lock','DX','Distributed Xaction','CF','Control File',
        'IS','Instance State','FS','File Set','IR','Instance Recovery','ST',
        'Disk Space Transaction','TS','Temp Segment','IV','Library Cache Inv.',
        'LS','Log Start or Switch','RW','Row Wait','SQ','Sequence Number',
        'TE','Extend Table','TT','Temp Table',l.TYPE) LTYPE
FROM V$LOCK l,v$locked_object lo,dba_objects o,v$session s
WHERE (l.REQUEST != 0  OR l.BLOCK != 0)
and l.id2 = lo.XIDSQN
and o.object_id = lo.object_id
and l.sid = s.sid
order by lo.object_id,lo.xidsqn,l.BLOCK desc
/
set feedback on
