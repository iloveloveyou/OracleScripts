set linesize 80
set pagesize 25
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

-- »стори€ блокировок. ¬ыполн€етс€ долго, пор€дка 2-3 мин. 
-- ≈сли кто-то когда-либо юзал 
-- данный пакет, то у него остаетс€ блокировка типа null ("Lock" x$kgllk )
-- ѕосле вкатывани€ package body у этих сессий по€в€тс€ 
-- Ora-6508 "PL/SQL: could not find program unit being called" 
-- ora-4068 "existing state of packages%s%s%s has been discarded"
-- и их надо будет перезагрузить.
-- ѕеред вкатыванием пакета надо определить 
-- весь список таких машин и разослать им сообщение
select  s.sid,
	    decode(ob.kglhdnsp, 0, 'Cursor', 1, 'Table/Procedure/Type', 2, 'Body', 
	     3, 'trigger', 4, 'Index', 5, 'Cluster', 13, 'Java Source',
             14, 'Java Resource', 32, 'Java Data', to_char(ob.kglhdnsp))
	  || ' Definition ' || lk.kgllktype "Lock type",
    decode(lk.kgllkmod, 0, 'None', 1, 'Null', 2, 'Share', 3, 'Exclusive',
	   to_char(lk.kgllkmod)) "Mode",
    decode(lk.kgllkreq,  0, 'None', 1, 'Null', 2, 'Share', 3, 'Exclusive',
	   to_char(lk.kgllkreq)) "Req",
    decode(ob.kglnaown, null, '', ob.kglnaown || '.') || ob.kglnaobj ||
    decode(ob.kglnadlk, null, '', '@' || ob.kglnadlk) "Object"
	,ob.kglnatim
--    ,rawtohex(lk.kgllkhdl)
	, s.machine, s.TERMINAL,s.osuser, s.program
	,s.username, s.schemaname,s.osuser,s.terminal
	,s.logon_time,s.module,s.client_info
   from v$session s, x$kglob ob, dba_kgllock lk
     where lk.kgllkhdl = ob.kglhdadr
      and  lk.kgllkuse = s.saddr
      and  upper(ob.kglnaobj) like upper('%&&NAME')
      and  upper(ob.kglnaown) = upper('&&SHEMA')
--	  and  ob.kglnaown = 'MTS24E'
--	  and  ob.kglnaobj like '%SELECT%FROM%INTERFACE_TABLE%IS_FOR_GET%'
--	  and  ob.kglnaobj like '%KK_SCH_TASKS%'
--	  and  s.sid = 1065
--	  and ob.kglhdadr='B71CA29C'
--and  ob.kglnaobj like 'SELECT N   FROM ADDRESS_STOP  WHERE :b1 BETWEEN FD AND TD  AND (ZIP IS NULL  OR ZIP = NVL(:b2,ZIP) ) AND (COUNTRY IS NULL  OR COUNTRY = NVL(:b3,COUNTRY) ) AND (CITY IS NULL  OR CITY = NVL(:b4,CITY) ) AND (ADDRESS IS NULL  OR ADDRESS = NVL(:b5,ADDRESS) ) AND (HOUSE IS NULL  OR HOUSE = NVL(:b6,HOUSE) ) AND (BULK IS NULL  OR BULK = NVL(:b7,BULK) ) AND (FLAT IS NULL  OR FLAT = NVL(:b8,FLAT) ) AND (STREET IS NULL  OR STREET = NVL(:b9,STREET) )'
/

spool off
