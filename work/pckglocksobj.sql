set linesize 160
set pagesize 30
set heading on
set ver off
set feedback on
set scan on

col "Object"   format a40
col kglhdadr	format a16
col "Mode"	format a6
col "Req"	format a6
col machine    format a20
col program    format a15
col client_info    format a15
col terminal    format a10

SELECT distinct 
	    	  lpad(s.sid,5) sid,o.kglnaown||'.'||o.kglnaobj "Object"
			  ,o.kglhdadr
			  ,rpad(decode(pn.kglpnmod, 0, 'None', 1, 'Null', 2, 'Share', 3, 'Exclusive',
			  	   to_char(pn.kglpnmod)),6) "Mode"
			  ,rpad(decode(pn.kglpnreq, 0, 'None', 1, 'Null', 2, 'Share', 3, 'Exclusive',
			  	   to_char(pn.kglpnreq)),6) "Req"
	   		  ,s.machine
			  ,s.client_info
         FROM x$kglpn pn, v$session s, x$kglob o
        WHERE pn.kglpnuse=s.saddr  and s.type!='BACKGROUND'
          AND pn.kglpnhdl=o.kglhdadr		  
--		  and upper(o.kglnaown) like '%MTS24E%'
		  and upper(o.kglnaobj) like upper('%&1%')
--		  and pn.kglpnhdl='00000009441740F0'  
		  order by sid,  "Object"
/
quit

