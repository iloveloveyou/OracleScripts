-------------------------------------
-- LATCH requests by sessions
-------------------------------------
set linesize 80
set serveroutput on
set ver off
set scan on
set feedback off

prompt Incremental Library cache latch statisticts

prompt Wait please...

declare
-------------------------------------------------
/* Можно модифицировать */
    WaitTime# number := 10; -- Задержка для сбора данных
    ShowRows# number := 10; -- Сколько строк выводить
-------------------------------------------------

    cursor c_Latch is
        select lc.child# child# ,lc.misses misses ,t.hsecs time$
        from v$latch_children lc,v$timer t
        where latch# = 106;

    type Latch_array_t is table of c_Latch%rowtype
        index by binary_integer;

    arr1        Latch_array_t;
    arr2        Latch_array_t;

    max_i       number := 0;

begin

    for sess in c_Latch loop
        arr1(sess.child#) := sess;
    end loop;
--------------------------------------------------------
    dbms_lock.sleep(WaitTime#);
    dbms_output.enable(100000);
--------------------------------------------------------
    for sess in c_Latch loop
        declare
            r_new       c_Latch%ROWTYPE;
            r_temp      c_Latch%ROWTYPE;
        begin
            r_new := sess;
            r_new.misses := round((sess.misses - arr1(sess.child#).misses)/
                                  (sess.time$ - arr1(sess.child#).time$)*100,2);


            for i in 1..max_i loop
                if r_new.misses
                        > arr2(i).misses
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


    dbms_output.put_line('List top Library cashe latch misses');
    dbms_output.put_line('-----------------------------------');
    dbms_output.put_line('CHILD#                     MISSES/c');
    dbms_output.put_line('-----------------------------------');

    for i in 1..least(ShowRows#,max_i-1) loop
        dbms_output.put_line(rpad(arr2(i).child#, 5) || ' ' ||
            lpad(arr2(i).misses,30));
    end loop;

end;
/

set feedback on
