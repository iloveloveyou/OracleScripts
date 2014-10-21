-------------------------------------
-- LATCH requests by sessions
-------------------------------------
set linesize 80
set serveroutput on
set ver off
set scan on
set feedback off

prompt Incremental LATCH REQUESTS statisticts

prompt Wait please...

declare
-------------------------------------------------
/* Можно модифицировать */
    WaitTime# number := 3; -- Задержка для сбора данных
    ShowRows# number := 20; -- Сколько строк выводить
-------------------------------------------------

    cursor c_Latch is
        select lh.sid sid ,lh.name name
        from v$latchholder lh;

    type latchRec is record(
            sid number,
            name varchar2(50),
            cnt number);

    type Latch_array_t is table of LatchRec
        index by binary_integer;

    arr1        Latch_array_t;
    arr2        Latch_array_t;

    max_j       number := 0;
    tmp LatchRec;
    addrec boolean;

    StartTime date;
    EndTime   date;
    CurTime   date;
    n_i       number;
    ErrPos number;
begin
    dbms_output.enable(100000);
    select sysdate into StartTime from dual;
    EndTime := StartTime + WaitTime#/24/60/60;
-------------------------------------------
    n_i := 1;
------ Сбор статистики

    LOOP
    select sysdate into CurTime from dual;
    EXIT when CurTime > EndTime;
---------------------------------------------
    for r_Latch in c_Latch loop
        arr1(n_i).sid  := r_Latch.sid;
        arr1(n_i).name := r_Latch.name;
        arr1(n_i).cnt  := 1;
        n_i := n_i + 1;
    end loop;
---------------------------------------------
    END LOOP;

-----------------------------------
-- анализ статистики по латчам
-----------------------------------
    max_j := 1;
    arr2(1) := arr1(1);
    arr2(1).cnt := 0;
    n_i := n_i -1;
    
    for i in 1..n_i loop
            tmp := arr1(i);
            addrec := true;            

            for j in 1..max_j loop
                if arr2(j).sid = tmp.sid and
                   arr2(j).name = tmp.name then
                   arr2(j).cnt := arr2(j).cnt +1;
                   addrec := false;
                end if;
            end loop;

                if addrec = true then
                arr2(max_j+1) := tmp;
                max_j := max_j +1;
                end if;
    end loop;
   --------------------------------------------------------
   -- сортировка массива по количеству запросов
   --------------------------------------------------------
        for j in 1..max_j-2 loop
        for i in 1..max_j-2 loop
            if arr2(i+1).cnt > arr2(i).cnt then
               tmp := arr2(i+1);
               arr2(i+1) := arr2(i);
               arr2(i) := tmp;
            end if;
        end loop;
        end loop;

   --------------------------------------------------------

    dbms_output.put_line('LIST TOP SESSION LATCH REQUESTS');
    dbms_output.put_line('---------------------------------------------');
    dbms_output.put_line('SID   LATCH NAME                     REQUESTS');
    dbms_output.put_line('---------------------------------------------');

    for i in 1..least(ShowRows#,max_j-1) loop
        dbms_output.put_line(rpad(arr2(i).sid, 5) || ' ' ||
            rpad(arr2(i).name,30)||' '||
            to_char(arr2(i).CNT, '999999'));
    end loop;

end;
/

set feedback on
