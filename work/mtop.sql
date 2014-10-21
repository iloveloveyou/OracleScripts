
set linesize 80
set serveroutput on
set ver off
set scan on

prompt Incremental cpu/memory statistic
prompt SORT MODE:
prompt 1 (TOP CPU)
prompt 2 (TOP MEMORY)
accept sortmode prompt "ENTER SORT MODE:"

prompt Wait please...

declare
---------------------------------------------------------
/* Можно модифицировать */
    WaitTime# number := 5; -- Задержка для сбора данных
    ShowRows# number := 20; -- Сколько строк выводить
---------------------------------------------------------
    cursor c_Sessions is
        select  s.sid       sid,
                s.serial#   ser#,
                p.spid      pid,
                s.username  orauser,
                st1.value   cpu,
                round(st2.value/1024,2) memory, -- Mb
                sysdate     time$
            from v$session s, v$process p, v$sesstat st1, v$sesstat st2
            where s.paddr = p.addr
                and s.sid = st1.sid
                and s.sid = st2.sid
                and st1.statistic# = 12  -- cpu time
                and st2.statistic# = 15; -- current memory

    type timed_array is table of c_Sessions%ROWTYPE
        index by binary_integer;

    r_new       c_Sessions%ROWTYPE;
    r_temp      c_Sessions%ROWTYPE;
    arr1        timed_array;
    arr2        timed_array;
    max_i       number := 0;
    smode       number;
begin
    smode :=  &&sortmode;
    if smode not in (1,2) then
        smode := 1;
    end if;

    for sess in c_Sessions loop
        arr1(sess.sid) := sess;
    end loop;

    dbms_lock.sleep(WaitTime#);
    dbms_output.enable(100000);

    for sess in c_Sessions loop
        r_new := sess;

        begin
            if sess.ser# != arr1(sess.sid).ser# then raise NO_DATA_FOUND; end if;

            r_new.cpu := round((sess.cpu - arr1(sess.sid).cpu)/(sess.time$ - arr1(sess.sid).time$)/86400,2); -- CPU %
----------------------------------------
-- Сортировка по CPU
----------------------------------------
        if smode = 1 then

            for i in 1..max_i loop
                if r_new.cpu > arr2(i).cpu then
                    r_temp := arr2(i);
                    arr2(i) := r_new;
                    r_new := r_temp;
                end if;
            end loop;
            max_i := max_i + 1;
            arr2(max_i) := r_new;
        end if;
----------------------------------------
-- Сортировка по MEMORY
----------------------------------------
        if smode = 2 then

            for i in 1..max_i loop
                if r_new.memory > arr2(i).memory then
                    r_temp := arr2(i);
                    arr2(i) := r_new;
                    r_new := r_temp;
                end if;
            end loop;
            max_i := max_i + 1;
            arr2(max_i) := r_new;
        end if;
-------------------------------------------------
        exception
            when NO_DATA_FOUND then null;
        end;
    end loop;

    dbms_output.put_line('CPU/MEMORY STATISTICS');
    dbms_output.put_line('SID     SER#    PID    CPU%   MEM(K)   USER    ');
    dbms_output.put_line('----- ------ ------ ------- ---------- --------');

    for i in 1 .. least(ShowRows#,max_i) loop
        dbms_output.put_line(
            rpad(arr2(i).sid, 5) || ' ' ||
            lpad(arr2(i).ser#,6) || ' ' ||
            lpad(arr2(i).pid, 6) || ' ' ||
            to_char( arr2(i).cpu, '990.99' ) || ' ' ||
            to_char( arr2(i).memory, '999990.99') || ' ' ||
            substr(rpad(nvl(arr2(i).orauser,' '),10),1,10));
    end loop;
end;
/


