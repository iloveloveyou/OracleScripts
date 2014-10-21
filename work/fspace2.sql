set line 132
col SUM(Mb) format 9999999.99
col FREE(Mb) format 9999999.99
col Occupied(Mb) format 9999999.9

SELECT tablespace_name,
       SUM(bytes)/1024/1024 AS "SUM(Mb)" ,
       ROUND(free/1024/1024,1) AS "FREE(Mb)",
       ROUND((SUM(bytes)-free)/1024/1024,1) "Occupied(Mb)",
       ROUND((SUM(bytes)-free)/(SUM(bytes)/100)) AS "OCCUPIED(%)",
       ROUND(le,1) "Max_extent(Mb)",
       fe "Blocks"
FROM dba_data_files,
    ( SELECT tablespace_name ts,SUM(bytes) free,MAX(bytes)/1024/1024 le,COUNT(block_id) fe
      FROM dba_free_space
      GROUP BY tablespace_name)
WHERE tablespace_name = ts
GROUP BY tablespace_name,free,le,fe
order by tablespace_name
/
