-------------------------------------
-- Disk statistic by files
-------------------------------------
set linesize 80
set serveroutput on
set ver off
set scan on

prompt Incremental file statistic
prompt SORT MODE:
prompt 1 (TOP READ)
prompt 2 (TOP WRITE)
accept sortmode prompt "ENTER SORT MODE:"

prompt Wait please...

declare
---------------------------------------------------------
/* Можно модифицировать */
    WaitTime# number := 5; -- Задержка для сбора данных
    ShowRows# number := 20; -- Сколько строк выводить
---------------------------------------------------------

    cursor c_Sessions is
        select  fs.file# FILE#,fs.PHYRDS PHYRDS,
        fs.PHYWRTS PHYWRTS ,f.name NAME
        from v$filestat fs,v$dbfile f
        where f.file# = fs.file#;

    type timed_array is table of c_Sessions%ROWTYPE
        index by binary_integer;

    arr1        timed_array;
    arr2        timed_array;

    max_i       number := 0;
    smode number;

begin
    smode :=  &&sortmode;
    if smode not in (1,2) then 
       smode := 1; 
    end if;
    
    for sess in c_Sessions loop
        arr1(sess.FILE#) := sess;
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
            r_new.PHYRDS := sess.PHYRDS - arr1(sess.FILE#).PHYRDS;
            r_new.PHYWRTS :=sess.PHYWRTS - arr1(sess.FILE#).PHYWRTS;
-------------------------------------------
 -- Сортировка по чтению
-------------------------------------------
	if smode = 1 then

            for i in 1..max_i loop
                if r_new.PHYRDS  > arr2(i).PHYRDS
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
-- Сортировка по записи
-------------------------------------------
     if smode = 2 then
            for i in 1..max_i loop
                if r_new.PHYWRTS > arr2(i).PHYWRTS
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

    dbms_output.put_line('INCREMENTAL FILE STATISTICS');
    dbms_output.put_line(' N   FILE NAME                                 PHYRDS     PHYWRTS');
    dbms_output.put_line('------------------------------------------ ---------- -----------');

    for i in 1 .. least(ShowRows#,max_i) loop
        dbms_output.put_line(rpad(arr2(i).FILE#,4) || ' ' ||
            rpad(arr2(i).NAME,36) || ' ' ||
            to_char(arr2(i).PHYRDS,'9999999999') || ' ' ||
            to_char(arr2(i).PHYWRTS,'9999999999'));
    end loop;
end;
/

