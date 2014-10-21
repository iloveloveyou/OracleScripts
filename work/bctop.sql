-------------------------------------
-- Disk statistic by sessions
-------------------------------------
set linesize 150
set serveroutput on
set ver off
set scan on
set feedback off

prompt Incremental disk statisticts for block changes
prompt to kill session use file kill_bctop.sql in current directory
prompt Wait please...
spool kill_bctop.sql


declare
---------------------------------------------------------
    /* Можно модифицировать */
    WaitTime# number := 5; -- Задержка для сбора данных
    ShowRows# number := 20; -- Сколько строк выводить
    Threshold# number := 1000; -- Пороговое значение block changes
    /*Средне-статистическое значение прироста block changes
    ресурсоемких процессов при штатной работе*/
    
---------------------------------------------------------
    cursor c_Sessions(Threshold number) is
        select io.sid,s.serial#,io.block_changes,
        s.machine, sq.sql_text, t.hsecs,p.spid
        from v$sess_io io,v$session s,v$sql sq,
        v$timer t,v$process p
        where io.sid = s.sid
        and s.paddr = p.addr
        and s.sql_hash_value = sq.hash_value
        and io.block_changes > Threshold;

    cursor c_Sessions_new(Threshold number) is
        select io.sid,io.block_changes,t.hsecs
        from v$sess_io io,v$timer t
        where block_changes > Threshold;

    type timed_array is table of c_Sessions%ROWTYPE
        index by binary_integer;

    arr1        timed_array;
    arr2        timed_array;

    sess        c_Sessions%ROWTYPE;

    max_i       number := 0;
    blksize     number;

    t1 number;
    t2 number;

begin

    select value/1024 into blksize from v$parameter where name = 'db_block_size';

    dbms_output.enable(100000);
    select hsecs into t1 from v$timer;
    for sess in c_Sessions(Threshold#) loop
        arr1(sess.sid) := sess;
    end loop;
    select hsecs into t2 from v$timer;
    dbms_output.put_line('Elapsed time for first select (mc):'||to_char(t2-t1));
--------------------------------------------------------
    dbms_lock.sleep(WaitTime#);
--------------------------------------------------------
    select hsecs into t1 from v$timer;
    for sess in c_Sessions_new(Threshold#) loop
        declare
            r_new       c_Sessions%ROWTYPE;
            r_temp      c_Sessions%ROWTYPE;
        begin
            r_new.sid := sess.sid;
            r_new.sql_text := arr1(sess.sid).sql_text;
            r_new.machine :=  arr1(sess.sid).machine;
            r_new.serial# := arr1(sess.sid).serial#;
            r_new.spid := arr1(sess.sid).spid;
--            r_new.block_changes := (sess.block_changes - arr1(sess.sid).block_changes);
            r_new.block_changes := round((sess.block_changes - arr1(sess.sid).block_changes)/
                                    (sess.hsecs - arr1(sess.sid).hsecs),2);
            for i in 1..max_i loop
                if r_new.block_changes
                        > arr2(i).block_changes
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
    select hsecs into t2 from v$timer;
    dbms_output.put_line('--Elapsed time for second select (mc):'||to_char(t2-t1));

    dbms_output.put_line('--BLOCK CHANGE STATISTICS FOR CURRENT SESSIONS');
    dbms_output.put_line('----------------------------------------------------');
    dbms_output.put_line('--SID  SPID  BL. CHANGES MASHINE               SQL');
    dbms_output.put_line('----- ------ ----------- --------------------- ------------');

    for i in 1 .. least(ShowRows#,max_i) loop
            dbms_output.put_line('--'||
            rpad(arr2(i).sid, 5) || ' ' ||
            rpad(arr2(i).spid, 6) || ' ' ||
            to_char(arr2(i).block_changes*blksize, '9999999999')|| ' ' ||
--            to_char(arr2(i).block_changes, '9999999999')|| ' ' ||
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
