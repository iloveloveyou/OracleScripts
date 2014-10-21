-------------------------------------
-- Disk statistic by sessions
-------------------------------------
set linesize 120
set serveroutput on
set ver off
set scan on

prompt Incremental disk statisticts
prompt SORT MODE:
prompt 1 (TOP LOGICAL  READ)
prompt 2 (TOP PHYSICAL READ)
prompt 3 (TOP LOGICAL CHANGE)

accept sortmode prompt "ENTER SORT MODE:"

prompt Wait please...

declare
---------------------------------------------------------
/* Можно модифицировать */
    WaitTime# number := 3; -- Задержка для сбора данных
    ShowRows# number := 20; -- Сколько строк выводить
---------------------------------------------------------

    cursor c_Sessions is
        select io.*, t.hsecs time$, s.machine,s.osuser, s.program
        from v$sess_io io, v$timer t, v$session s
        where s.sid=io.sid;
--        select io.*, t.hsecs time$ from v$sess_io io, v$timer t;

    type timed_array is table of c_Sessions%ROWTYPE
        index by binary_integer;

    arr1        timed_array;
    arr2        timed_array;

    max_i       number := 0;
    blksize     number;
    smode number;

begin
    smode :=  &&sortmode;

    select value/1024 into blksize from v$parameter where name = 'db_block_size';

    for sess in c_Sessions loop
        arr1(sess.sid) := sess;
    end loop;
--------------------------------------------------------
    dbms_lock.sleep(WaitTime#);
    dbms_output.enable(100000);
--------------------------------------------------------
    for sess in c_Sessions loop
        declare
            r_new       c_Sessions%ROWTYPE;
            r_temp      c_Sessions%ROWTYPE;
        begin
            r_new := sess;
            r_new.block_gets := round((sess.block_gets - arr1(sess.sid).block_gets)/(sess.time$ - arr1(sess.sid).time$)*100,2);
            r_new.block_changes := round((sess.block_changes - arr1(sess.sid).block_changes)/(sess.time$ - arr1(sess.sid).time$)*100,2);
            r_new.physical_reads := round((sess.physical_reads - arr1(sess.sid).physical_reads)/(sess.time$ - arr1(sess.sid).time$)*100,2);
            r_new.consistent_gets := round((sess.consistent_gets - arr1(sess.sid).consistent_gets)/(sess.time$ - arr1(sess.sid).time$)*100,2);
            r_new.consistent_changes := round((sess.consistent_changes - arr1(sess.sid).consistent_changes)/(sess.time$ - arr1(sess.sid).time$)*100,2);
-------------------------------------------
 -- Сортировка по логическому чтению
-------------------------------------------
	if smode = 1 then

            for i in 1..max_i loop
                if r_new.block_gets+r_new.consistent_gets
                        > arr2(i).block_gets+arr2(i).consistent_gets
                then
                    r_temp := arr2(i);
                    arr2(i) := r_new;
                    r_new := r_temp;
                end if;
            end loop;
            max_i := max_i + 1;
            arr2(max_i) := r_new;
     end if;
-------------------------------------------
-- Сортировка по физическому чтению
-------------------------------------------
     if smode = 2 then
            for i in 1..max_i loop
                if r_new.physical_reads*blksize
                        > arr2(i).physical_reads*blksize
                then
                    r_temp := arr2(i);
                    arr2(i) := r_new;
                    r_new := r_temp;
                end if;
            end loop;
            max_i := max_i + 1;
            arr2(max_i) := r_new;
      end if;
-------------------------------------------
-- Сортировка по изменению данных
-------------------------------------------
     if smode = 3 then
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

     end if;
---------------------------------------------------------------
        exception
            when NO_DATA_FOUND then null;
        end;
    end loop;

    dbms_output.put_line('DISK STATISTICS FOR CURRENT SESSIONS');
    dbms_output.put_line('SID    LReads blk/s  Phys. blk/s   blk changes/s machine name     osuser  program ');
    dbms_output.put_line('----- -------------  ------------- ------------- --------------- ------- -------------');

    for i in 1 .. least(ShowRows#,max_i) loop
        dbms_output.put_line(
            rpad(arr2(i).sid, 5) || ' ' ||
            to_char( (arr2(i).block_gets+arr2(i).consistent_gets), '999999990.99') || ' ' ||
            to_char( arr2(i).physical_reads, '9999999990.99') || ' ' ||
            to_char( (arr2(i).block_changes+arr2(i).consistent_changes), '999999999990')||' '||
            rpad(arr2(i).machine,18)||' '||
            rpad(arr2(i).osuser,14)||' '||
            rpad(arr2(i).program,30) );
    end loop;
end;
/

