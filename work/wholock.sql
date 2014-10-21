-- Script find session that lock row in database
-------------------------------------------------------
-- Required grants :
-- grant select on v_$lock to <user>
-- grant select on dba_jobs_running to <user>
-- grant execute on dbms_job to <user>
-- grant execute on dbms_lock to <user>
-- grant select on V_$PARAMETER to <user>
-- grant select on V_$SESSION to <user>
-- grant select on sys.audit_actions to <user>
-- grant alter system to <user>
-------------------------------------------------------

set scan on
set feedback off
set ver off
set heading off

prompt Search for session that lock row in database
accept tbl prompt 'TABLE (''OWNER.TABLE_NAME''):'
accept whr prompt 'WHERE CLAUSE (for example ''A=B''): '

set serveroutput on
prompt Wait please..
----------------------------------------------------------
declare
table_name# varchar2(100) := &&tbl;
where_clause# varchar2(2000):= &&whr;

jn# number;
text varchar2(2000);
Cursor JobIntervalCur is
    select value from v$parameter
    where name='job_queue_interval';
JobIntervalRec JobIntervalCur%rowtype;
Cursor JobSidCur(j# number) is
    select j.sid,s.serial#
    from dba_jobs_running j,v$session s
    where j.sid = s.sid
    and     job = j#;
JobSidRec JobSidCur%rowtype;
Cursor LockSidCur(s# number) is
    select distinct sid from v$lock
    where (id1,id2) in (
    select id1,id2 from v$lock
    where sid = s#
    and type = 'TX')
    and sid != s#
    and lmode != 0;
LockSidRec LockSidCur%rowtype;
Cursor WhoCur(s# number) is
select to_char(s.sid) sid,
       to_char(decode(sign(s.serial#), -1,
       65536+s.serial#, s.serial# )) ser#,
       s.username username,
       s.osuser osuser,
       nvl(s.program,'NOT DEFINED') program,
       s.status status,
       a.name command,
       s.machine machine
  from v$session s, sys.audit_actions a
  where a.action = s.command  and s.sid = s#;
WhoRec WhoCur%rowtype;
SleepInterval number;
------------------------------------------------------------
begin

table_name# := upper(table_name#);
dbms_output.enable(20000);
text := 'DECLARE R ROWID;'||chr(10);
text := text||'BEGIN '||chr(10);
text := text||'SELECT ROWID INTO R FROM ';
text := text|| table_name#||' WHERE '||where_clause#||' FOR UPDATE;'||chr(10);
text := text||'ROLLBACK;END;';

dbms_job.submit(jn#,text,sysdate,null,true);
commit;
------------------------------------------------------
open JobIntervalCur;
fetch JobIntervalCur into JobIntervalRec;
    if JobIntervalCur%found then
        SleepInterval := to_number(JobIntervalRec.value)+10;    
    else
        SleepInterval := 60;
    end if;
close JobIntervalCur;

dbms_lock.sleep(SleepInterval);

open JobSidCur(jn#);
fetch JobSidCur into JobSidRec;
    if JobSidCur%notfound then
        dbms_job.remove(jn#);    
        commit;
        dbms_output.put_line('No free SNP processes or row not locked.');
        return;
    end if;
close JobSidCur;

open LockSidCur(JobSidRec.sid);
fetch LockSidCur into LockSidRec;
close LockSidCur;

    dbms_output.put_line('******************************');
open WhoCur(LockSidRec.sid);
fetch WhoCur into WhoRec;
    if WhoCur%found then
    dbms_output.put_line('SID       '||WhoRec.sid);
    dbms_output.put_line('SERIAL    '||WhoRec.ser#);
    dbms_output.put_line('ORAUSER   '||WhoRec.username);
    dbms_output.put_line('OSUSER    '||WhoRec.osuser);
    dbms_output.put_line('PROGRAM   '||WhoRec.program);
    dbms_output.put_line('STATUS    '||WhoRec.status);
    dbms_output.put_line('COMMAND   '||WhoRec.command);
    dbms_output.put_line('MACHINE   '||WhoRec.machine);
    else
        dbms_output.put_line('Lock process information not found.');
    end if;
close WhoCur;

dbms_job.remove(jn#);
commit;
execute immediate 'alter system kill session '||chr(39)||to_char(jobSidRec.sid)||','||to_char(JobSidRec.serial#)||chr(39);
----------------------------------------------
exception
when others then
	null;
end;
/
-----------------------------------------------
set feedback on
set scan off
set ver on
