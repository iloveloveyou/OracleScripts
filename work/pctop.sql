-------------------------------------
-- PARSE CALL requests by sessions
-------------------------------------
set linesize 80
set serveroutput on
set ver off
set scan on
set feedback off

prompt Incremental hard parse rate statisticts

prompt Wait please...

declare
-------------------------------------------------
/* Можно модифицировать */
    WaitTime# number := 10; -- Задержка для сбора данных
    ShowRows# number := 30; -- Сколько строк выводить
-------------------------------------------------

    cursor c_stat is
        select s.sid sid ,s.value value ,t.hsecs time$,
        nvl(rpad(substr(upper(ses.program),instr(ses.program,'\',-1,1)+1,
        length(ses.program)),25),'NOT DEFINED') program,ses.machine
        from v$sesstat s,v$timer t,v$session ses
        where s.STATISTIC# = 177
        and s.sid = ses.sid;

    type stat_array_t is table of c_stat%rowtype
        index by binary_integer;

    arr1        stat_array_t;
    arr2        stat_array_t;

    max_i       number := 0;

begin

    for sess in c_stat loop
        arr1(sess.sid) := sess;
    end loop;
--------------------------------------------------------
    dbms_lock.sleep(WaitTime#);
    dbms_output.enable(100000);
--------------------------------------------------------
    for sess in c_stat loop
        declare
            r_new       c_stat%ROWTYPE;
            r_temp      c_stat%ROWTYPE;
        begin
            r_new := sess;
            r_new.value := round((sess.value - arr1(sess.sid).value)/
                                  (sess.time$ - arr1(sess.sid).time$)*100,2);


            for i in 1..max_i loop
                if r_new.value
                        > arr2(i).value
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

-------------------------------------------
    end loop;


    dbms_output.put_line('List top parse calls');
    dbms_output.put_line('-----------------------------------------------------------');
    dbms_output.put_line('SID                         PARSE/c    PROGRAM      MACHINE');
    dbms_output.put_line('-----------------------------------------------------------');

    for i in 1..least(ShowRows#,max_i-1) loop
        dbms_output.put_line(rpad(arr2(i).sid, 5) || ' ' ||
            lpad(arr2(i).value,30)||' '||arr2(i).program||arr2(i).machine);
    end loop;

end;
/

set feedback on
