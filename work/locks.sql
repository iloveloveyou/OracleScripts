set serveroutput on
set pagesize 0
set feedback off
set ver off
set scan off 

declare
Cursor LockCur is SELECT  decode(l.BLOCK,0,'---> ','->')||to_char(l.SID) SID,
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
order by lo.object_id,lo.xidsqn,l.BLOCK desc;

type LockTabType is table of LockCur%rowtype index by binary_integer;
LockTab LockTabType;
i binary_integer := 0;
j binary_integer;
ex boolean;
begin
    for LockRec in LockCur loop
            ex := false;
            j  := 0;
            loop
            exit when j >= LockTab.count or ex;
                if  LockTab(j).sid  = LockRec.sid  and
                    LockTab(j).ser# = LockRec.ser# and
                    LockTab(j).machine = LockRec.machine and
                    LockTab(j).orauser = LockRec.orauser and
                    LockTab(j).held = LockRec.held and
                    LockTab(j).request = LockRec.request and
                    LockTab(j).ltype = LockRec.ltype    then ex := true;
                 end if;
                 j := j + 1;
             end loop;
             if not ex then 
                LockTab(i).sid := LockRec.sid;
                LockTab(i).ser# := LockRec.ser#;
                LockTab(i).machine := LockRec.machine;
                LockTab(i).orauser := LockRec.orauser; 
                LockTab(i).held := LockRec.held;
                LockTab(i).request := LockRec.request;                
                LockTab(i).ltype := LockRec.ltype;                
                i := i + 1;
              end if;
    end loop;
    dbms_output.put_line('CURRENT DATABASE BLOCKING LOCKS');

    for j in 0 .. LockTab.count-1 loop
        if substr(LockTab(j).sid,1,2) = '->' then
    dbms_output.put_line('-------------------------------');
        end if;
        dbms_output.put_line(LockTab(j).sid||' '||LockTab(j).ser#||' '||
        substr(LockTab(j).machine,1,length(LockTab(j).machine)-1)||' '||LockTab(j).orauser||' '||
        LockTab(j).held||' '||LockTab(j).ltype);
    end loop;
end;
/

set feedback on
