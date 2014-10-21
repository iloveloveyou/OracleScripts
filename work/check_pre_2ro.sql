SELECT s.*, v.*
   FROM v$session s, v$transaction v, SYS.x_$ktuxe t
  WHERE v.xidusn = ktuxeusn
    AND v.xidslot = ktuxeslt
    AND v.xidsqn = ktuxesqn
    AND s.taddr = v.addr
    AND t.ktuxecfl = 'DEAD'
/

