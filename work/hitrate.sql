-------------------------------------
-- Disk statistic by sessions
-------------------------------------
set linesize 80
set serveroutput on
set ver off
set scan on

prompt One moment please...

declare
---------------------------------------------------------
/* Можно модифицировать */
    WaitTime# number := 60; -- Задержка для сбора данных
---------------------------------------------------------

    cursor c_sysstat is
        select statistic#,value from v$sysstat
	where statistic# in (38,39,40);

    type timed_array is table of c_sysstat%ROWTYPE
        index by binary_integer;

    arr1	timed_array;
    arr2	timed_array;    

begin
	
    for stat in c_sysstat loop
        arr1(stat.statistic#) := stat;
    end loop;

	
    dbms_lock.sleep(WaitTime#);

    for stat in c_sysstat loop
        arr2(stat.statistic#) := stat;
    end loop;

    dbms_output.enable(100000);
--------------------------------------------------------

    dbms_output.put_line('HIT RATE:');
    dbms_output.put_line(to_char(round(
	100-(arr2(40).value-arr1(40).value)*100/
	((arr2(38).value-arr1(38).value)+(arr2(39).value-arr1(39).value)),2)
	)||'%');

end;
/

