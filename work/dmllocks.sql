set scan on
set ver off
set linesize 80
set pagesize 15

column sid	format 9990 heading 'SID'
column type	format a4
column lmode	format a9 heading 'HELD'
column request	format a9 heading 'REQUEST'
column others format a8
column object_name format a15
column object_type format a11
column owner format a10
column o1_o2 format a5


prompt Getting DML locks for object
accept NAME  prompt 'Enter object name: '
accept SHEMA prompt 'Enter shema  name: '

spool dmllocks.log

select  s.sid sid,
	    decode (l.lmode, 0, 'None',
			 1, 'Null',
			 2, 'Row Share',
			 3, 'Row Excl.',
			 4, 'Share',
			 5, 'S/Row Excl.',
			 6, 'Exclusive',
		      lmode, ltrim( to_char( lmode, '990'))) lmode,
	    decode (l.request, 0, 'None',
			 1, 'Null',
			 2, 'Row Share',
			 3, 'Row Excl.',
			 4, 'Share',
			 5, 'S/Row Excl.',
			 6, 'Exclusive',
		      request, ltrim( to_char( request, '990'))) request,
	    decode(l.block,
  	        0, 'No Blk',         /* Not blocking any other processes */
    		1, 'Blocking',       /* This lock blocks other processes */
    		2, 'Global',         /* This lock is global, so we can't tell */
    		to_char(l.block)) others,
        o.object_name object_name,
        o.object_type object_type,
        o.owner       owner,
        decode(l.id1, o.object_id,' 1 ','   ')||decode(l.id2, o.object_id,' 2 ','  ') o1_o2
    from v$lock l, dba_objects o, v$session s
    where l.sid = s.sid
        and (l.id1 = o.object_id or l.id2 = o.object_id)
        and o.object_name = upper('&&NAME')
        and o.owner = upper('&&SHEMA')
/


spool off
