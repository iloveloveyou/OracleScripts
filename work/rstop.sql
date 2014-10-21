-------------------------------------
-- REDO statistic by sessions
-------------------------------------
set linesize 80
set serveroutput on
prompt Incremental REDO statisticts
prompt *****************************************
PROMPT STATISTIC NUMBERS:
prompt 100	redo entries
prompt 101	redo size
prompt 102	redo buffer allocation retries
prompt 103	redo wastage
prompt 104	redo writer latching time
prompt 105	redo writes
prompt 106	redo blocks written
prompt 107	redo write time
prompt 108	redo log space requests
prompt 109	redo log space wait time
prompt 110	redo log switch interrupts
prompt 111	redo ordering marks
prompt ******************************************
accept statnumber prompt "ENTER STATISTIC NUMBER:"

prompt Wait please...

declare
-------------------------------------------------
/* Можно модифицировать */
    WaitTime# number := 5; -- Задержка для сбора данных
    ShowRows# number := 20; -- Сколько строк выводить
-------------------------------------------------
    Statname varchar2(200);

    cursor c_Sessions (statn# number) is
        select io.sid, io.value from v$sesstat io
        where io.statistic# = statn#;

    type timed_array is table of c_Sessions%ROWTYPE
        index by binary_integer;

    arr1        timed_array;
    arr2        timed_array;

    max_i       number := 0;
    blksize     number;

    statnumber# number;

begin

    statnumber#:= &&statnumber;

    select name into Statname from v$statname where statistic# = statnumber#;

    for sess in c_Sessions(statnumber#) loop
        arr1(sess.sid) := sess;
    end loop;
--------------------------------------------------------
    dbms_lock.sleep(WaitTime#);
    dbms_output.enable(100000);
--------------------------------------------------------
    for sess in c_Sessions(statnumber#) loop
        declare
            r_new       c_Sessions%ROWTYPE;
            r_temp      c_Sessions%ROWTYPE;
        begin
            r_new := sess;
            r_new.value := sess.value - arr1(sess.sid).value;
--------------------------------------
-- сортировка
--------------------------------------
            for i in 1..max_i loop
                if r_new.value > arr2(i).value
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

    dbms_output.put_line('LIST TOP SESSIONS FOR STATISTIC: '||upper(Statname));
    dbms_output.put_line('--------------------------------------');
    dbms_output.put_line('SID    VALUE');
    dbms_output.put_line('----- -------------------');

    for i in 1 .. least(ShowRows#,max_i) loop
        dbms_output.put_line(rpad(arr2(i).sid, 5) || ' ' ||
            to_char(arr2(i).value, '9999999999999'));
    end loop;
end;
/

