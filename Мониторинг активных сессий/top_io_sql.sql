  SELECT Buffer_Gets,
         Disk_Reads,
         Executions,
         Buffer_Gets / Executions B_E,
         sql_id,
         SQL_Text
    FROM V$SQL
   WHERE executions != 0
ORDER BY Disk_Reads DESC;