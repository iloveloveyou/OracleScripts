set linesize 90
set pagesize 50
set heading on
set ver off
set feedback on
set scan on

col index_name format a30
col column_name format a30
col data_type format a15

break on index_name

accept name prompt 'TABLE NAME: '
prompt ______________________________

select substr(ic.index_name,0,30) index_name,
substr(ic.column_name,0,30) column_name,
substr(tc.data_type,0,20) data_type
from user_ind_columns ic,user_tab_columns tc where
ic.index_name in (
	select index_name from
	user_indexes where table_name = upper(replace('&&name',' ')))
and ic.table_name = tc.table_name
and ic.column_name = tc.column_name
order by ic.index_name,ic.column_position
/

                   