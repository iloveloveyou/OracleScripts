-------------------------------------
-- Disk statistic by sessions
-------------------------------------
set linesize 80
set serveroutput on
set ver off
set scan on

prompt Incremental disk statisticts for block changes (+consistent)


prompt Wait please...

declare
---------------------------------------------------------
/* Можно модифицировать */
    MaxRow#   number := 50;
    WaitTime# number := 5; -- Задержка для сбора данных
    ShowRows# number := 20; -- Сколько строк выводить
---------------------------------------------------------

    cursor c_Sessions is
        select io.sid,io.block_gets,io.consistent_gets,
        io.physical_reads,io.block_changes,io.consistent_changes,
        io.block_changes + io.consistent_changes bc,
        t.hsecs time$ from v$sess_io io, v$timer t
        order by bc desc;


    type timed_array is table of c_Sessions%ROWTYPE
        index by binary_integer;

    arr1        timed_array;
    arr2        timed_array;

    r_new       c_Sessions%ROWTYPE;
    r_temp      c_Sessions%ROWTYPE;
    sess        c_Sessions%ROWTYPE;


    max_i       number := 0;
    blksize     number;
    rc number;
begin

    select value/1024 into blksize from v$parameter where name = 'db_block_size';
    rc := 0;
    open    c_Sessions;
    loop
    fetch c_Sessions into sess;
    exit when rc > maxrow# or c_Sessions%notfound;
        arr1(sess.sid) := sess;
        rc := rc + 1;
    end loop;
    close c_Sessions;
--------------------------------------------------------
    dbms_lock.sleep(WaitTime#);
    dbms_output.enable(100000);
--------------------------------------------------------
    rc := 0;
    open    c_Sessions;
    loop
    fetch c_Sessions into sess;
    exit when rc > maxrow# or c_Sessions%notfound;
        begin
            r_new := sess;
            r_new.block_gets := round((sess.block_gets - arr1(sess.sid).block_gets)/(sess.time$ - arr1(sess.sid).time$)*100,2);
            r_new.block_changes := round((sess.block_changes - arr1(sess.sid).block_changes)/(sess.time$ - arr1(sess.sid).time$)*100,2);
            r_new.physical_reads := round((sess.physical_reads - arr1(sess.sid).physical_reads)/(sess.time$ - arr1(sess.sid).time$)*100,2);
            r_new.consistent_gets := round((sess.consistent_gets - arr1(sess.sid).consistent_gets)/(sess.time$ - arr1(sess.sid).time$)*100,2);
            r_new.consistent_changes := round((sess.consistent_changes - arr1(sess.sid).consistent_changes)/(sess.time$ - arr1(sess.sid).time$)*100,2);

-------------------------------------------
-- Сортировка по изменению данных
-------------------------------------------
            for i in 1..max_i loop
                if r_new.block_changes + r_new.consistent_changes
                        > arr2(i).block_changes + arr2(i).consistent_changes
                then
                    r_temp := arr2(i);
                    arr2(i) := r_new;
                    r_new := r_temp;
                end if;
            end loop;
            max_i := max_i + 1;
            arr2(max_i) := r_new;
---------------------------------------------------------------
        exception
            when NO_DATA_FOUND then null;
        end;
       rc := rc + 1;
    end loop;
    close c_Sessions;


    dbms_output.put_line('DISK STATISTICS FOR CURRENT SESSIONS');
    dbms_output.put_line('SID    LReads(Kb/s)   Phys. (Kb/s) block changes (Kb/s)');
    dbms_output.put_line('----- -------------  ------------- --------------------');

    for i in 1 .. least(ShowRows#,max_i) loop
        dbms_output.put_line(rpad(arr2(i).sid, 5) || ' ' ||
            to_char( (arr2(i).block_gets+arr2(i).consistent_gets)*blksize, '999999990.99') || ' ' ||
            to_char( arr2(i).physical_reads*blksize, '9999999990.99') || ' ' ||
            to_char( (arr2(i).block_changes+arr2(i).consistent_changes)*blksize, '999999999990'));
    end loop;
end;
/

