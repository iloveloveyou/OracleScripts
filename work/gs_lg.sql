set feedback off
set heading off
set pagesize 0
spool lg.sql

select 'alter index '||index_name||
' modify partition '||partition_name||' logging;' stm
from user_ind_partitions where logging !='YES'
union all
select 'alter table '||table_name||
' modify partition '||partition_name||' logging;' stm
from user_tab_partitions where logging !='YES'
/

set feedback on
spool off