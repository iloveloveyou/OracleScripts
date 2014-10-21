set linesize 80
set pagesize 12
set scan on
set ver off

col sid format 9990
col username format a10
col owner format a10
col name format a15
col type format a8
col held format a7
col request format a7

prompt Getting DDL locks for object
accept NAME  prompt 'Enter object  name: '
accept SHEMA prompt 'Enter object shema: '

spool ddllocks.log

--Ненулевые блокировки в данный момент
--Кто делает execute данному пакету в данный момент ("Pin" x$kglpn)
-- Перед тем как обновлять тело пакета (create or replace package body)
-- обязательно длительно понаблюдать, кто его юзает,
-- и эти сессии сразу после create or replace заставить перевойти
       SELECT distinct 
	    	  s.sid,o.kglnaown||'.'||o.kglnaobj "Object",o.kglnatim,o.kglhdadr
			  ,decode(pn.kglpnmod, 0, 'None', 1, 'Null', 2, 'Share', 3, 'Exclusive',
			  	   to_char(pn.kglpnmod)) "Mode"
			  ,decode(pn.kglpnreq, 0, 'None', 1, 'Null', 2, 'Share', 3, 'Exclusive',
			  	   to_char(pn.kglpnreq)) "Req"
	   		  , s.machine, s.TERMINAL,s.osuser, s.program, l.sql_text
			  ,s.username, s.schemaname,s.osuser,s.terminal
			  ,s.logon_time,s.module,s.client_info
--			  , 'alter system kill session '''||s.sid||','||s.serial#||''';'
			  ,'kill -9 '||p.spid||';'
			  --,p.*
         FROM x$kglpn pn, v$session s, x$kglob o, v$sql l , v$process p
        WHERE pn.kglpnuse=s.saddr  and s.type!='BACKGROUND'
          AND pn.kglpnhdl=o.kglhdadr		  
		  and p.addr = s.paddr
		  and l.hash_value(+)=s.sql_hash_value 
/*		  and  ( upper(o.kglnaobj) like '%KK_ACTIONS_IDT%' or upper(o.kglnaobj) like '%KK_DEALER_RM%' or
		  	     upper(o.kglnaobj) like '%KK_INFO2%' or upper(o.kglnaobj) like '%KK_WWW%' or
				 upper(o.kglnaobj) like '%KK_ICS_INET%' or upper(o.kglnaobj) like '%KK_ICS_API%' or
				 upper(o.kglnaobj) like '%KK_ICS_SHORTNUM%' or upper(o.kglnaobj) like '%KK_WWW_SMS%')
*/				  
		  and upper(o.kglnaobj) like upper('%&&NAME%')
          and  upper(o.kglnaown) = upper('&&SHEMA')
--		  and pn.kglpnhdl='00000009441740F0'  
--		  	  			'00000009441740F0'
--			and s.sid=2194
		  order by  "Object", o.kglnatim
/

spool off
