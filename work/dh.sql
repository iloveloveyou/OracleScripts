set linesize 100
--Datafiles headers
column CHECKPOINT_CHANGE# format 9999999999999999 
rem column RESETLO
select file#,STATUS,RECOVER,FUZZY, 
to_char(checkpoint_change#,'9999999999999999999') checkpoint_change#,
to_char(CHECKPOINT_TIME,'dd-mm-yyyy hh24:mi:ss') CHECKPOINT_TIME,
to_char(RESETLOGS_TIME,'dd-mm-yyyy hh24:mi:ss') resetlogs_time
from v$datafile_header
where RECOVER='YES';
