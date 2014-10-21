set feedback off
set serveroutput on
set scan on
set ver off

accept name   prompt 'OBJECT NAME    : '
accept subobj prompt 'SUBOBJECT NAME : '
prompt ______________________________________

declare
cursor ObjectTypeCur(object_name# varchar2,subobject_name# varchar2) is
select object_type,object_name,status from user_objects
where object_name = upper(object_name#)
and nvl(SUBOBJECT_NAME,'##########') = upper(nvl(subobject_name#,'##########'));
ObjectTypeRec ObjectTypeCur%rowtype;
cursor SegmentCur(segment_name# varchar2,partition_name# varchar2) is
select round(bytes/1024/1024,2) mbytes,
extents,round(initial_extent/1024/1024,2) initial_extent,
round(next_extent/1024/1024,2) next_extent,max_extents,pct_increase
from user_segments
where segment_name = upper(segment_name#)
and nvl(partition_name,'##########') = upper(nvl(partition_name#,'##########'));
SegmentRec SegmentCur%rowtype;
cursor IndColumnCur(index_name# varchar2) is
select ic.column_name,tc.data_type from user_ind_columns ic,user_tab_columns tc
where ic.index_name = index_name#
and ic.table_name = tc.table_name
and ic.column_name = tc.column_name
order by ic.column_position;
IndColumnRec IndColumnCur%rowtype;

object_name## varchar2(50) := '&&name';
subobject_name## varchar2(50) := '&&subobj';
partitioned# varchar2(30);
table_name# varchar2(30);
tablespace_name# varchar2(30);
degree# varchar2(10);
logging# varchar2(10);
status# varchar2(20);
size# number;
count# number;
begin
object_name## := replace(object_name##,' ');
subobject_name## := replace(subobject_name##,' ');
open ObjectTypeCur(object_name##,subobject_name##);
fetch ObjectTypeCur into ObjectTypeRec;
    if ObjectTypeCur%notfound then
        dbms_output.put_line('Object does not exist.');
    end if;
close ObjectTypeCur;
for ObjectTypeRec in ObjectTypeCur(object_name##,subobject_name##) loop
        dbms_output.put_line(rpad(ObjectTypeRec.object_type,16)||': '||rpad(ObjectTypeRec.object_name,30));
        dbms_output.put_line('--------------------------------------');
        if ObjectTypeRec.object_type = 'TABLE' then
            select partitioned,tablespace_name,degree,logging
            into partitioned#,tablespace_name#,degree#,logging# from user_tables
            where table_name = upper(object_name##);
            dbms_output.put_line('PARTITIONED     :'||lpad(partitioned#,15));
            dbms_output.put_line('DEGREE          :'||lpad(degree#,15));
            if partitioned# = 'NO' then
             open SegmentCur(object_name##,subobject_name##);
             fetch SegmentCur into SegmentRec;
                if SegmentCur%found then
                dbms_output.put_line('SIZE(Mb)        :'||lpad(to_char(SegmentRec.mbytes,'9999990.99'),15));
                dbms_output.put_line('EXTENTS         :'||lpad(to_char(SegmentRec.extents),15));
                dbms_output.put_line('INITIAL_EXT(Mb) :'||lpad(to_char(SegmentRec.initial_extent,'9999990.99'),15));
                dbms_output.put_line('NEXT_EXTENT(Mb) :'||lpad(nvl(to_char(SegmentRec.next_extent,'9999990.99'),'-'),15));
                dbms_output.put_line('MAX_EXTENTS     :'||lpad(to_char(SegmentRec.max_extents),15));
                dbms_output.put_line('PCTINCREASE     :'||lpad(nvl(to_char(SegmentRec.pct_increase),'-'),15));
                end if;
             close SegmentCur;
                dbms_output.put_line('TABLESPACE      : '||rpad(tablespace_name#,30));
                dbms_output.put_line('LOGGING         :'||lpad(logging#,15));
            else
                select round(sum(bytes)/1024/1024,2),count(*) into size#,count# from user_segments
                where segment_name = upper(object_name##);
                dbms_output.put_line('SIZE(Mb)        :'||lpad(to_char(size#,'9999990.99'),15));
                dbms_output.put_line('COUNT           :'||lpad(to_char(count#),15));
            end if;
            
        elsif ObjectTypeRec.object_type = 'INDEX' then
            select table_name,partitioned,tablespace_name,degree,logging,status
            into table_name#,partitioned#,tablespace_name#,degree#,logging#,status# from user_indexes
            where index_name = upper(object_name##);
            dbms_output.put_line('PARTITIONED     :'||lpad(partitioned#,15));
            dbms_output.put_line('DEGREE          :'||lpad(degree#,15));
            if partitioned# = 'NO' then
             open SegmentCur(object_name##,subobject_name##);
             fetch SegmentCur into SegmentRec;
                if SegmentCur%found then
                dbms_output.put_line('SIZE(Mb)        :'||lpad(to_char(SegmentRec.mbytes,'9999990.99'),15));
                dbms_output.put_line('EXTENTS         :'||lpad(to_char(SegmentRec.extents),15));
                dbms_output.put_line('INITIAL_EXT(Mb) :'||lpad(to_char(SegmentRec.initial_extent,'9999990.99'),15));
                dbms_output.put_line('NEXT_EXTENT(Mb) :'||lpad(nvl(to_char(SegmentRec.next_extent,'9999990.99'),'-'),15));
                dbms_output.put_line('MAX_EXTENTS     :'||lpad(to_char(SegmentRec.max_extents),15));
                dbms_output.put_line('PCTINCREASE     :'||lpad(nvl(to_char(SegmentRec.pct_increase),'-'),15));
                dbms_output.put_line('TABLESPACE      : '||rpad(tablespace_name#,30));
                dbms_output.put_line('LOGGING         :'||lpad(logging#,15));
                dbms_output.put_line('STATUS          :'||lpad(status#,15));
                end if;
             close SegmentCur;
            else
                select round(sum(bytes)/1024/1024,2),count(*) into size#,count# from user_segments
                where segment_name = upper(object_name##);
                dbms_output.put_line('SIZE(Mb)        :'||lpad(to_char(size#,'9999990.99'),15));
                dbms_output.put_line('COUNT           :'||lpad(to_char(count#),15));
             
            end if;
                dbms_output.put_line('--------------------------------------');
                dbms_output.put_line('TABLE           : '||rpad(table_name# ,30));
                dbms_output.put_line('FIELDS          ->');
                for IndColumnRec in IndColumnCur(upper(object_name##)) loop
                  dbms_output.put_line(rpad(IndColumnRec.column_name,30)||' '||rpad(IndColumnRec.data_type,20));
                end loop;
        elsif ObjectTypeRec.object_type = 'VIEW' then
            dbms_output.put_line('STATUS          : '||lpad(ObjectTypeRec.status,15));
        elsif ObjectTypeRec.object_type = 'PROCEDURE' then
            dbms_output.put_line('STATUS          : '||lpad(ObjectTypeRec.status,15));
        elsif ObjectTypeRec.object_type = 'FUNCTION' then
            dbms_output.put_line('STATUS          : '||lpad(ObjectTypeRec.status,15));
        elsif ObjectTypeRec.object_type like 'PACKAGE%' then
            dbms_output.put_line('STATUS          : '||lpad(ObjectTypeRec.status,15));
        elsif ObjectTypeRec.object_type = 'TRIGGER' then
            dbms_output.put_line('STATUS          : '||lpad(ObjectTypeRec.status,15));
        elsif ObjectTypeRec.object_type = 'CONSTRAINT' then
            null;        
        elsif ObjectTypeRec.object_type = 'SEQUENCE' then
            null;        
        end if;
      dbms_output.put_line('--------------------------------------');
    end loop;

end;
/

prompt
set feedback on
