-------------------------------------
-- LATCH requests by sessions
-------------------------------------
set linesize 80
set serveroutput on
set ver off
set scan on
set feedback off

prompt Incremental LATCH REQUESTS BY NAME

prompt Wait please...

declare
-------------------------------------------------
/* Можно модифицировать */
    WaitTime# number := 5; -- Задержка для сбора данных
    ShowRows# number := 20; -- Сколько строк выводить
-------------------------------------------------

    cursor c_Latch is
        select lh.sid sid , ln.latch# latch#,lh.name name
        from v$latchholder lh ,v$latchname ln
        where ln.name = lh.name;

    r_Latch c_Latch%rowtype;

    type latchRec is record(
            sid number,
            latch# number,
            name varchar2(50),
            cnt number);

    type Latch_array_t is table of LatchRec
        index by binary_integer;

    arr1        Latch_array_t;
    arr2        Latch_array_t;
    arr3        Latch_array_t;

    max_j       number := 0;
    tmp LatchRec;

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
    n_i := 0;
    LOOP
    select sysdate into CurTime from dual;
    EXIT when CurTime > EndTime;

    for r_Latch in c_Latch loop
        arr1(n_i).sid  := r_Latch.sid;
        arr1(n_i).name := r_Latch.name;
        arr1(n_i).latch# := r_Latch.latch#;
        arr1(n_i).cnt  := 1;
        n_i := n_i + 1;
    end loop;

    END LOOP;

-----------------------------------
-- Сбор статистики по латчам

    for i in 0..n_i-1 loop
        if arr2.exists(arr1(i).latch#) then
           arr2(arr1(i).latch#).cnt :=  arr2(arr1(i).latch#).cnt +1;
        else
            arr2(arr1(i).latch#).cnt := 1;
            arr2(arr1(i).latch#).name := arr1(i).name;
        end if;
    end loop;

       for i in 1..n_i loop
        begin
            arr3(max_j) := arr2(i);
            max_j := max_j + 1;
        exception
        when others then null;
        end;
       end loop;

        for j in 1..max_j-2 loop
        for i in 1..max_j-2 loop
            if arr3(i+1).cnt > arr3(i).cnt then
               tmp := arr3(i+1);
               arr3(i+1) := arr3(i);
               arr3(i) := tmp;
            end if;
        end loop;
        end loop;
   --------------------------------------------------------

    dbms_output.put_line('LIST TOP LATCH REQUESTS');
    dbms_output.put_line('---------------------------------------');
    dbms_output.put_line('LATCH NAME                     REQUESTS');
    dbms_output.put_line('---------------------------------------');

    for i in 1..least(ShowRows#,max_j-1) loop
        dbms_output.put_line(rpad(arr3(i).name,30)||' '||
            to_char(arr3(i).CNT, '999999'));
    end loop;

end;
/

set feedback on
