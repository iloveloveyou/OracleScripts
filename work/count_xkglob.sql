connect internal

insert into pasha.latch_x_kglob_count (dt, count_rows)
--create table pasha.latch_x_kglob_count as
select sysdate as dt, count(*) count_rows from sys.x$kglob
/

commit
/

quit
