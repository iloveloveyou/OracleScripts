select tablespace_name as tablespace_name,Tot_Size,Tot_Free, round(Pct_Free,2) Pct_Free,Max_Free from (
  SELECT a.tablespace_name,
         SUM (a.tots / 1048576) Tot_Size,
         SUM (a.sumb / 1048576) Tot_Free,
         SUM (a.sumb) * 100 / SUM (a.tots) Pct_Free,
         SUM (a.largest / 1024) Max_Free,
         SUM (a.chunks) Chunks_Free
    FROM (  SELECT tablespace_name,
                   0 tots,
                   SUM (bytes) sumb,
                   MAX (bytes) largest,
                   COUNT (*) chunks
              FROM dba_free_space a
          GROUP BY tablespace_name
          UNION
            SELECT tablespace_name,
                   SUM (bytes) tots,
                   0,
                   0,
                   0
              FROM dba_data_files
          GROUP BY tablespace_name) a
GROUP BY a.tablespace_name
ORDER BY pct_free
) where pct_free<10
and tablespace_name not in 
  (select TABLESPACE_NAME 
      from dba_data_files
      where AUTOEXTENSIBLE='YES' and (maxbytes-bytes)>4000000000); 


