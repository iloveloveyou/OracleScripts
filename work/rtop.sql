-------------------------------------
-- REDO statistic by sessions
-------------------------------------
set linesize 230
set serveroutput on
set ver off
set scan on

prompt Incremental REDO statisticts for REDO SIZE

prompt Wait please...

declare
-------------------------------------------------
/* Можно модифицировать */
    WaitTime# number := 30; -- Задержка для сбора данных
    ShowRows# number := 10; -- Сколько строк выводить
    MaxRow#   number := 50;
-------------------------------------------------
    Statname varchar2(200);

    cursor c_Sessions is
        select io.sid, io.value RS, s.machine, sq.sql_text 
        from v$sesstat io,v$session s,v$sqltext sq
        where io.statistic# = 146 
        and io.sid = s.sid
        and s.sql_hash_value = sq.hash_value
        and s.sql_address = sq.address
        and sq.piece = 0
        and upper(s.program) not like '%CALLCHRG%'
        order by RS desc;

    type timed_array is table of c_Sessions%ROWTYPE
        index by binary_integer;

    sess        c_Sessions%rowtype;
    r_new       c_Sessions%ROWTYPE;
    r_temp      c_Sessions%ROWTYPE;

    arr1        timed_array;
    arr2        timed_array;

    max_i       number := 0;
    rc number;

begin

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
            r_new.RS := sess.RS - arr1(sess.sid).RS;
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
       rc := rc + 1;
    end loop;
    close c_Sessions;

    dbms_output.put_line('LIST TOP SESSIONS FOR REDO LOG ACTIVITY');
    dbms_output.put_line('---------------------------------------');
    dbms_output.put_line('SID    REDO SIZE  MASHINE         SQL');
    dbms_output.put_line('----- ----------  --------------- ------');

    for i in 1 .. least(ShowRows#,max_i) loop
        dbms_output.put_line(rpad(arr2(i).sid, 5) || ' ' ||
            to_char(arr2(i).RS, '9999999999')|| ' ' ||
            rpad(substr(arr2(i).machine,1,15),15) || ' ' ||
            substr(arr2(i).sql_text,1,190));
    end loop;
end;
/

