-------------------------------------
-- Execution rate
-------------------------------------
set linesize 80
set serveroutput on
set ver off
set scan on
set feedback off

prompt Calculating current Execution Rate..

prompt Wait please...

declare
    cursor c_ExRate is
	SELECT VALUE,HSECS
	FROM V$SYSSTAT,V$TIMER
	WHERE STATISTIC# = 181;

ExRateFirst number;
ExRateSecond number;
TimeFirst number;
TimeSecond number;
SleepTime number := 10;
ExRate number;
begin
	open c_ExRate;
	fetch c_ExRate into ExRateFirst,TimeFirst;
	close c_ExRate;

	dbms_lock.sleep(SleepTime);
	
	open c_ExRate;
	fetch c_ExRate into ExRateSecond,TimeSecond;
	close c_ExRate;

ExRate := round((ExRateSecond - ExRateFirst)*100/(TimeSecond - TimeFirst));
dbms_output.put_line('Execution Rate: '||to_char(ExRate)||' Calls/Sec');
end;
/
set feedback on


