/* Formatted on 09/09/2013 17:22:41 (QP5 v5.227.12220.39754) */
  SELECT SESS.Username,
         SESS_IO.Block_Gets,
         SESS_IO.Consistent_Gets,
         SESS_IO.Physical_Reads,
         ROUND (
              100
            * (  SESS_IO.Consistent_Gets
               + SESS_IO.Block_Gets
               - SESS_IO.Physical_Reads)
            / (DECODE (SESS_IO.Consistent_Gets,
                       0, 1,
                       SESS_IO.Consistent_Gets + SESS_IO.Block_Gets)),
            2)
            session_hit_ratio
    FROM V$SESS_IO sess_io, V$SESSION sess
   WHERE SESS.Sid = SESS_IO.Sid AND SESS.Username IS NOT NULL
ORDER BY Username;