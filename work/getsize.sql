set scan on
set feedback on

prompt Show object size

accept oname prompt ' Name:'
accept own   prompt ' Owner:'
accept pname prompt ' Partition:'

prompt ********************************


select round(bytes/1024/1024,2) " Bytes(Mb)" 
from dba_segments
where segment_name = upper('&&oname')
and owner = upper('&&own')
and nvl(partition_name,'xxxxxxxx') = nvl(upper('&&pname'),'xxxxxxxx')
/


