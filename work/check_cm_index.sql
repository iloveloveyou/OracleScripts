select BYTES from dba_segments
where segment_name = 'IDX_INTER_TABLE_IS_FOR_GET'
and owner  = 'CM'
/
/*
alter index cm.IDX_INTER_TABLE_IS_FOR_GET rebuild
*/