-- На каких объектах из Library cache зависли сессии, которые ждут Library cache pin/lock
select kglnaown "Owner", kglnaobj "Object",w.*
from x$kglob l, v$session_wait w
where w.event like 'library cache%'
and l.kglhdadr=w.p1raw
;
quit
