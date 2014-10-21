-------------------------------------
-- Disk statistic by files
-------------------------------------
set linesize 90
set serveroutput on
set ver off
set scan on
set feedback off

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
        select io.block_gets block_gets,
        io.physical_reads physical_reads,
        io.consistent_gets consistent_gets,
        fs.file# FILE#,fs.PHYRDS PHYRDS,
        fs.PHYWRTS PHYWRTS ,f.name NAME,
        sw.sid SID,
        t.hsecs time$
        from v$filestat fs,v$dbfile f,v$session_wait sw,
        v$sess_io io, v$timer t
        where f.file# = fs.file#
        and sw.p1 = f.file#
        and sw.p1text in ('file#')
        and io.sid = sw.sid;

    type timed_array is table of c_Sessions%ROWTYPE
        index by binary_integer;

    arr1        timed_array;
    arr2        timed_array;

    max_i       number := 0;
    smode       number;
    blksize     number;
    
begin
    smode :=  &&sortmode;
    if smode not in (1,2) then
       smode := 1;
    end if;

    for sess in c_Sessions loop 
        arr1(sess.SID*sess.FILE#+sess.FILE#) := sess;
    end loop;

    select value/1024 into blksize from v$parameter where name = 'db_block_size';

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
            r_new.PHYRDS          := sess.PHYRDS - arr1(sess.SID*sess.FILE#+sess.FILE#).PHYRDS;
            r_new.PHYWRTS         := sess.PHYWRTS - arr1(sess.SID*sess.FILE#+sess.FILE#).PHYWRTS;
            r_new.block_gets := round((sess.block_gets - arr1(sess.SID*sess.FILE#+sess.FILE#).block_gets)/(sess.time$ - arr1(sess.SID*sess.FILE#+sess.FILE#).time$)*100,2);
            r_new.physical_reads := round((sess.physical_reads - arr1(sess.SID*sess.FILE#+sess.FILE#).physical_reads)/(sess.time$ - arr1(sess.SID*sess.FILE#+sess.FILE#).time$)*100,2);
            r_new.consistent_gets := round((sess.consistent_gets - arr1(sess.SID*sess.FILE#+sess.FILE#).consistent_gets)/(sess.time$ - arr1(sess.SID*sess.FILE#+sess.FILE#).time$)*100,2);
 

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

    dbms_output.put_line('INCREMENTAL FILE STATISTICS FOR SESSIONS');
    dbms_output.put_line('SID   FILE NAME                         READ  WRITE      LREAD(K/S)   PREAD(K/S)');
    dbms_output.put_line('----- -------------------------------- ------ ---------- ------------ ----------');

    for i in 1 .. least(ShowRows#,max_i) loop
        dbms_output.put_line(rpad(arr2(i).SID,5)||' ' ||
            rpad(arr2(i).NAME,30) || ' ' ||
            rpad(to_char(arr2(i).PHYRDS,'999999'),6)  || ' ' ||
            rpad(to_char(arr2(i).PHYWRTS,'999999'),6) || ' ' ||
            to_char( (arr2(i).block_gets+arr2(i).consistent_gets)*blksize, '999999990.99') || ' ' ||
            to_char( arr2(i).physical_reads*blksize, '9999999990.99'));
    end loop;
end;
/

set feedback on
