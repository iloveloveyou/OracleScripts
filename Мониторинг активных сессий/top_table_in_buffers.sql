select Object_Name,
Object_Type ,
count(*) Num_Buff
from X$BH a, SYS.DBA_OBJECTS b
where A.Obj = B.Object_Id
and Owner not in ('SYS','SYSTEM')
group by Object_Name, Object_Type
order by Num_Buff desc;