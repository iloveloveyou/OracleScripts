/* Kill distribution transaction */

alter session set "_smu_debug_mode" = 4;
rollback force '&1';
execute sys.dbms_transaction.purge_lost_db_entry('&1');
commit;
alter session set "_smu_debug_mode" = 0;

