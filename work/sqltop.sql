-------------------------------------
-- Disk statistic by sessions
-------------------------------------
set linesize 90
set serveroutput on
set ver off
set scan on
set feedback off

prompt Incremental SQL statisticts
prompt SORT MODE:
prompt 1 (TOP DISK READ)
prompt 2 (TOP BUFFER GET)


accept sortmode prompt "ENTER SORT MODE:"

prompt Wait please...

declare
---------------------------------------------------------
/* Можно модифицировать */
    WaitTime# number := 5; -- Задержка для сбора данных
    ShowRows# number := 20; -- Сколько строк выводить
---------------------------------------------------------

    cursor c_Sessions is
        select s.sid,s.serial#,p.spid,sq.disk_reads,
        sq.buffer_gets,sq.executions,sq.sql_text,
        t.hsecs time$,round(sq.hash_value/1000000) hv
        from v$sql sq, v$timer t,v$session s,v$process p
        where sq.address = s.sql_address
        and sq.hash_value = s.sql_hash_value
        and p.addr = s.paddr
        and (sq.disk_reads != 0 OR sq.buffer_gets != 0);
        
    type timed_array is table of c_Sessions%ROWTYPE
        index by binary_integer;

    arr1        timed_array;
    arr2        timed_array;

    max_i       number := 0;
    blksize     number;
    smode number;

begin
    smode :=  &&sortmode;
    for sess in c_Sessions loop
        arr1(sess.hv*sess.spid) := sess;
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
            r_new.disk_reads := round((sess.disk_reads - arr1(sess.hv*sess.spid).disk_reads)/(sess.time$ - arr1(sess.hv*sess.spid).time$)*100,2);
            r_new.buffer_gets := round((sess.buffer_gets - arr1(sess.hv*sess.spid).buffer_gets)/(sess.time$ - arr1(sess.hv*sess.spid).time$)*100,2);
-------------------------------------------
 -- Сортировка по disk_read
-------------------------------------------
	if smode = 1 then

            for i in 1..max_i loop
                if r_new.disk_reads
                        > arr2(i).disk_reads
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
-- Сортировка по buffer_get
-------------------------------------------
     if smode = 2 then
            for i in 1..max_i loop
                if r_new.buffer_gets
                        > arr2(i).buffer_gets
                then
                    r_temp := arr2(i);
                    arr2(i) := r_new;
                    r_new := r_temp;
                end if;
            end loop;
            max_i := max_i + 1;
            arr2(max_i) := r_new;
      end if;
---------------------------------------------------------------
        exception
            when NO_DATA_FOUND then null;
        end;
    end loop;

    dbms_output.put_line('TOP IO SQL STATISTICS FOR CURRENT SESSIONS');
    dbms_output.put_line('SID   SERIAL SPID   DISK READ(O/S) BUFFER GET(O/S) SQL TEXT');
    dbms_output.put_line('----- ------ ------ -------------- --------------- ----------------------------');

    for i in 1 .. least(ShowRows#,max_i) loop
        dbms_output.put_line(rpad(arr2(i).sid, 5) || ' ' ||
            rpad(arr2(i).serial#, 6) || ' ' ||
            rpad(arr2(i).spid, 6) || ' ' ||
            to_char(arr2(i).disk_reads, '9999999990.99') || ' ' ||
            to_char(arr2(i).buffer_gets, '9999999990.99') || '  ' ||
            upper(substr(arr2(i).sql_text,1,30)));
    end loop;
end;
/

set feedback on
