-------------------------------------
-- REDO statistic by sessions
-------------------------------------
set linesize 150
set serveroutput on
set ver off
set scan on
set feedback off

prompt Incremental REDO statisticts
prompt to kill session use file kill_redo.sql in current directory
prompt Wait please...
spool kill_redo.sql
declare
-------------------------------------------------
/* Можно модифицировать */
    WaitTime# number := 5; -- Задержка для сбора данных
    ShowRows# number := 20; -- Сколько строк выводить
    Threshold# number := 100000; -- Пороговое значение entry size
    TimeZ number := 5; -- Некое количество секунд
    /*Средне-статистическое значение прироста entry size
    ресурсоемких процессов при штатной работе*/
-------------------------------------------------
    cursor c_Sessions(Threshold number) is
        select io.sid, s.serial#, p.spid ,
        io.value RS, s.machine, sq.sql_text, t.hsecs
        from v$sesstat io,v$session s,v$sql sq,
        v$process p,v$timer t
        where io.statistic# = 101
        and io.sid = s.sid
        and s.paddr = p.addr
        and s.sql_hash_value = sq.hash_value
        and io.value > Threshold;

    cursor c_Sessions_new(Threshold number) is
        select io.sid, io.value RS, t.hsecs
        from v$sesstat io,v$timer t
        where io.statistic# = 101
        and io.value > Threshold;

    type timed_array is table of c_Sessions%ROWTYPE
        index by binary_integer;

    arr1        timed_array;
    arr2        timed_array;
    smode       number;
    max_i       number := 0;
    blksize     number;
    t1 number;
    t2 number;
    ThresholdK number;
begin

--    ThresholdK := Threshold#/512*1024*TimeZ;
    ThresholdK := Threshold#;

    dbms_output.enable(100000);

--    select hsecs into t1 from v$timer;
    for sess in c_Sessions(ThresholdK) loop
        arr1(sess.sid) := sess;
    end loop;
--    select hsecs into t2 from v$timer;
--    dbms_output.put_line('Elapsed time for first select (mc):'||to_char(t2-t1));
--------------------------------------------------------
    dbms_lock.sleep(WaitTime#);
--------------------------------------------------------
--    select hsecs into t1 from v$timer;
    for sess in c_Sessions_new(ThresholdK) loop
        declare
            r_new       c_Sessions%ROWTYPE;
            r_temp      c_Sessions%ROWTYPE;
        begin
            r_new.sid := sess.sid;
            r_new.serial# := arr1(sess.sid).serial#;
            r_new.spid := arr1(sess.sid).spid;
            r_new.sql_text := arr1(sess.sid).sql_text;
            r_new.machine :=  arr1(sess.sid).machine;
            r_new.RS := round((sess.RS - arr1(sess.sid).RS)/(sess.hsecs - arr1(sess.sid).hsecs));
            for i in 1..max_i loop
                if r_new.RS > arr2(i).RS
                then
                    r_temp := arr2(i);
                    arr2(i) := r_new;
                    r_new := r_temp;
                end if;
            end loop;
            max_i := max_i + 1;
            arr2(max_i) := r_new;
        exception
            when NO_DATA_FOUND then null;
        end;

    end loop;
--    select hsecs into t2 from v$timer;
--    dbms_output.put_line('Elapsed time for second select (mc):'||to_char(t2-t1));

    dbms_output.put_line('--LIST TOP SESSIONS FOR REDO LOG ACTIVITY (Kb/C)');
    dbms_output.put_line('----------------------------------------------------');
    dbms_output.put_line('--SID   SPID    REDO SIZE MASHINE               SQL');
    dbms_output.put_line('----- ----- ----------- --------------------- ------------');

    for i in 1 .. least(ShowRows#,max_i) loop
            dbms_output.put_line('--'||
            rpad(arr2(i).sid, 5) || ' ' ||
            rpad(arr2(i).spid, 5) || ' ' ||
            to_char(arr2(i).RS*512/1024, '9999999999')|| ' ' ||
            rpad(NVL(substr(arr2(i).machine,1,length(arr2(i).machine)-1),'SERVER JOB'),21) || ' ' ||
            substr(arr2(i).sql_text,1,60));
    end loop;

    for i in 1 .. least(ShowRows#,max_i) loop
            dbms_output.put_line('alter system kill session '||chr(39)||
            to_char(arr2(i).sid)|| ',' ||to_char(arr2(i).serial#)||chr(39)||';');
    end loop;

end;
/

    spool off
    set feedback on
