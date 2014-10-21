CREATE OR REPLACE PROCEDURE kill_my_session(
   p_sid       IN NUMBER                 
 , p_action    IN VARCHAR2 := 'DISCONNECT'
 , p_immediate IN VARCHAR2 := 'IMMEDIATE')
IS
--
-- Уничтожение сессии, принадлежащей тому же пользователю
-- Проверяется, что это не та сессия из которой вызвана процедура
--
-- p_sid       - SID уничтожаемой сессии
-- p_action    - 'DISCONNECT' или 'DISCONNECT POST_TRANSACTION' или 'KILL'
-- p_immediate - 'IMMEDIATE' или ''
--
-- Created on 12-APR-2002 by VSU
--
   ln_serial# NUMBER;
   ln_audsid  NUMBER;
   lv_sqlcmd VARCHAR2(249);
BEGIN
   -- Проверка входных параметров
   IF UPPER(TRIM(p_action)) NOT IN 
      ('DISCONNECT', 'DISCONNECT POST_TRANSACTION', 'KILL') 
   THEN
      raise_application_error(-20001
       , 'Invalid value of P_ACTION: "' || p_action || '"'); 
   END IF;
   --
   IF (UPPER(TRIM(p_immediate)) <> 'IMMEDIATE' 
       AND NVL(LENGTH(TRIM(p_immediate)), 0) <> 0) -- Если в будущем будет NULL не есть '' 
   THEN
      raise_application_error(-20002
       , 'Invalid value of P_IMMEDIATE: "' || p_immediate || '"'); 
   END IF;
   --
   -- Попытка выбора информации об указанной сессии
   SELECT serial#, audsid 
   INTO ln_serial#, ln_audsid 
   FROM v$session
   WHERE username = USER      
     AND ownerid = 2147483644 -- Not a Parallel Slave process session
     AND sid = kill_my_session.p_sid;
   --
   -- Блокировка "самоубийства"
   IF ln_audsid = USERENV('SESSIONID') THEN
      raise_application_error(-20003
       , 'Session self killing ("suicide") is prohibited. You can''t kill yourself.'); 
   END IF;
   --
   lv_sqlcmd := 'ALTER SYSTEM ' || p_action 
             || ' SESSION ''' || p_sid || ',' || ln_serial# || ''''
             || ' ' || p_immediate;  
   --
   EXECUTE IMMEDIATE lv_sqlcmd;
dbms_output.put_line(lv_sqlcmd);
EXCEPTION 
   WHEN NO_DATA_FOUND THEN
      raise_application_error(-20000
       , 'USER ' || USER || ' has no SESSION WITH SID=' || p_sid); 
END kill_my_session;
/
