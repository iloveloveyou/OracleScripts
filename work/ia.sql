declare
Cursor ExCur is
select 'alter index '||index_name||
' modify partition '||partition_name||' logging' stm
from user_ind_partitions where logging !='YES'
union all
select 'alter table '||table_name||
' modify partition '||partition_name||' logging' stm
from user_tab_partitions where logging !='YES';
ExRec ExCur%rowtype;
NeedEx boolean;
resource_busy EXCEPTION;
PRAGMA EXCEPTION_INIT(resource_busy, -54);
begin
NeedEx := true;
loop
exit when not NeedEx;
open ExCur;
fetch ExCur into ExRec;
	if ExCur%notfound then
		NeedEx := false;
	end if;	
close ExCur;
for ExRec in ExCur loop
	begin
	execute immediate ExRec.stm;
	exception
	when others then null;
	end;
end loop;
end loop;
end;
/
