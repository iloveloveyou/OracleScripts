set term off
column name new_value tstamp;
select to_char( sysdate, '_YYYYMMDD_HH24MI' ) name from dual;
set term on

spool latch98&&tstamp..log

select to_char( sysdate, 'DD.MM HH24:MI' ) from dual;

drop table ego_latch_children;
create table ego_latch_children( 
  i      number,
  child# number,
  addr   raw(8),
  gets   number,
  misses number,
  sleeps number  );

begin
  for i in 1..2 loop
    insert into ego_latch_children( 
      select i, CHILD#, ADDR, GETS, MISSES, SLEEPS  
        from v$latch_children 
        where name = 'cache buffers chains' );
    commit;
    dbms_lock.sleep( 20 );
  end loop;
end;
/

drop table ego_top_latch;
create table ego_top_latch as
  select rownum top, d.* 
    from ( select b.addr, 
                  (b.gets-e.gets) d_gets, 
                  (b.sleeps-e.sleeps) d_sleeps
             from ego_latch_children b, 
                  ego_latch_children e
             where b.i=2 and e.i=1 and b.child#=e.child# and b.addr=e.addr and
                   (b.sleeps-e.sleeps)>0
             order by 3 desc ) d
    where rownum<11;
select * from ego_top_latch order by top;

--column segment_name format a35
--select /*+ RULE */
--       e.owner ||'.'|| e.segment_name  segment_name,
--       e.extent_id  extent#,
--       x.dbablk - e.block_id + 1  block#,
--       x.tch,
--       l.child#
--  from sys.v$latch_children l,
--       sys.x$bh  x,
--       sys.dba_extents  e
--  where x.hladdr  = hextoraw(:a) and
--        e.file_id = x.file# and
--        x.hladdr = l.addr and
--        x.dbablk between e.block_id and e.block_id + e.blocks -1
--     order by x.tch desc ;

variable a1 varchar2(32)
variable a2 varchar2(32)
variable a3 varchar2(32)
begin
  select rawtohex( addr ) into :a1 from ego_top_latch where top=1;
  select rawtohex( addr ) into :a2 from ego_top_latch where top=2;
  select rawtohex( addr ) into :a3 from ego_top_latch where top=3;
end;
/

select /*+ RULE */ x.file#, x.dbablk, x.obj, x.tch, l.child#
  from sys.v$latch_children l, sys.x$bh x
  where x.hladdr  = hextoraw(:a1) and x.hladdr = l.addr 
  order by x.tch desc ;

select to_char( sysdate, 'DD.MM HH24:MI' ) from dual;

select /*+ RULE */ x.file#, x.dbablk, x.obj, x.tch, l.child#
  from sys.v$latch_children l, sys.x$bh x
  where x.hladdr  = hextoraw(:a2) and x.hladdr = l.addr 
  order by x.tch desc ;

select to_char( sysdate, 'DD.MM HH24:MI' ) from dual;

select /*+ RULE */ x.file#, x.dbablk, x.obj, x.tch, l.child#
  from sys.v$latch_children l, sys.x$bh x
  where x.hladdr  = hextoraw(:a2) and x.hladdr = l.addr 
  order by x.tch desc ;

select to_char( sysdate, 'DD.MM HH24:MI' ) from dual;

spool off;
