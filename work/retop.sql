-------------------------------------
-- REDO statistic by sessions
-------------------------------------
set linesize 80
set serveroutput on
set ver off
set scan on

prompt Incremental REDO statisticts
prompt SORT MODE:
prompt 1 (TOP ENTRIES)
prompt 2 (TOP REDOSIZE)
accept sortmode prompt "ENTER SORT MODE:"

prompt Wait please...

declare
-------------------------------------------------
/* Можно модифицировать */
    WaitTime# number := 5; -- Задержка для сбора данных
    ShowRows# number := 20; -- Сколько строк выводить
-------------------------------------------------
    Statname varchar2(200);

    cursor c_Sessions is
        select io1.sid, io1.value RE,io2.value RS
        from v$sesstat io1,v$sesstat io2
        where io1.sid = io2.sid
        and io1.statistic# = 100 -- redo entries
        and io2.statistic# = 101; -- redo size

    type timed_array is table of c_Sessions%ROWTYPE
        index by binary_integer;

    arr1        timed_array;
    arr2        timed_array;
    smode       number;
    max_i       number := 0;
    blksize     number;
begin
    smode :=  &&sortmode;

    if smode not in (1,2) then
        smode := 1;
    end if;

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
            r_new.RE := sess.RE - arr1(sess.sid).RE;
            r_new.RS := sess.RS - arr1(sess.sid).RS;
--------------------------------------
-- сортировка
--------------------------------------
if smode = 1 then

            for i in 1..max_i loop
                if r_new.RE > arr2(i).RE
                then
                    r_temp := arr2(i);
                    arr2(i) := r_new;
                    r_new := r_temp;
                end if;
            end loop;
            max_i := max_i + 1;
            arr2(max_i) := r_new;
end if;
-----------------------------------------      
if smode = 2 then
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
end if;

        exception
            when NO_DATA_FOUND then null;
        end;
 
    end loop;

    dbms_output.put_line('LIST TOP SESSIONS FOR REDO LOG ACTIVITY');
    dbms_output.put_line('---------------------------------------');
    dbms_output.put_line('SID     REDO ENTRIES      REDO SIZE');
    dbms_output.put_line('------ -------------      ---------');

    for i in 1 .. least(ShowRows#,max_i) loop
        dbms_output.put_line(rpad(arr2(i).sid, 5) || ' ' ||
            to_char(arr2(i).RE, '9999999999999') || ' ' ||
            to_char(arr2(i).RS, '9999999999999'));
    end loop;
end;
/

