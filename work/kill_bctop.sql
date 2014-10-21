Elapsed time for first select (mc):435                                                                                                                
--Elapsed time for second select (mc):20                                                                                                              
--BLOCK CHANGE STATISTICS FOR CURRENT SESSIONS                                                                                                        
----------------------------------------------------                                                                                                  
--SID  SPID  BL. CHANGES MASHINE               SQL                                                                                                    
----- ------ ----------- --------------------- ------------                                                                                           
--824   22279           42 SERVER JOB            SELECT /*+ ordered use_nl(c) index (a app$up) index (c calc$                                         
--793   24516           37 SERVER JOB            SELECT /*+ ordered use_nl(c) index (a app$up) index (c calc$                                         
--2270  22166           35 SERVER JOB            SELECT B.LOC,C.ROWID RW,R_CALLS_LOG,DUR,SERVICES,NVL(AIR,0)                                          
--2923  24544           33 SERVER JOB            SELECT B.LOC,C.ROWID RW,R_CALLS_LOG,DUR,SERVICES,NVL(AIR,0)                                          
--1786  19287           29 SERVER JOB            UPDATE CALC SET R$BILLPAR$N=:b1,ORIGIN=DECODE(ORIGIN,2,2,:b2                                         
--1422  21978           29 SERVER JOB            INSERT INTO ACTIONS ( N,UP,WD,OD,R$OBJ$N,TBL,ACTION,R$REASON                                         
--456   24536           29 SERVER JOB            SELECT A.N NAP,C.AMOUNT,C.LEFT,C.TAX,C.TAX_MASK,C.DUR,C.AMOU                                         
--386   23944           28 SERVER JOB            INSERT INTO CALC ( R$BILLPAR$N,N,UP,R$TSERV$N,AMOUNT,LEFT,DU                                         
--1308  21821           27 SERVER JOB            INSERT INTO CALC ( R$BILLPAR$N,N,UP,R$TSERV$N,AMOUNT,LEFT,DU                                         
--1717  22316           25 SERVER JOB            SELECT /*+ ordered use_nl(c) index (a app$up) index (c calc$                                         
--1003  20653           25 SERVER JOB            SELECT MAX(N)   FROM INVOICE  WHERE UP = :b1  AND :b2 >= FDE                                         
--2598  24473           23 SERVER JOB            SELECT B.LOC,C.ROWID RW,R_CALLS_LOG,DUR,SERVICES,NVL(AIR,0)                                          
--1863  24280           22 SERVER JOB            SELECT DISTINCT T.FD   FROM TAX T  WHERE T.RESTYP = 1  AND G                                         
--2104  22212           22 SERVER JOB            begin kk_billing.Generate(208396,TRUE,FALSE,FALSE,2833918,29                                         
--1653  22789           21 CBOSS\S_GENER_01      begin kk_sql.Set_Big_Rollback(:is_commit=1); end;                                                    
--1197  21901           21 SERVER JOB            SELECT B.LOC,C.ROWID RW,R_CALLS_LOG,DUR,SERVICES,NVL(AIR,0)                                          
--3280  4148            19 SERVER JOB            SELECT /*+ index(balance balance$up)  */1   FROM BALANCE  WH                                         
--2122  20386           14 SERVER JOB            INSERT INTO ACTIONS ( N,UP,WD,OD,R$OBJ$N,TBL,ACTION,R$REASON                                         
--3933  22099           14 SERVER JOB            INSERT INTO ACTIONS ( N,UP,WD,OD,R$OBJ$N,TBL,ACTION,R$REASON                                         
--3828  24463           12 SERVER JOB            SELECT B.LOC,C.ROWID RW,R_CALLS_LOG,DUR,SERVICES,NVL(AIR,0)                                          
alter system kill session '824,44325';                                                                                                                
alter system kill session '793,20309';                                                                                                                
alter system kill session '2270,60643';                                                                                                               
alter system kill session '2923,31861';                                                                                                               
alter system kill session '1786,24115';                                                                                                               
alter system kill session '1422,44764';                                                                                                               
alter system kill session '456,12106';                                                                                                                
alter system kill session '386,44841';                                                                                                                
alter system kill session '1308,7076';                                                                                                                
alter system kill session '1717,49132';                                                                                                               
alter system kill session '1003,32576';                                                                                                               
alter system kill session '2598,47978';                                                                                                               
alter system kill session '1863,48021';                                                                                                               
alter system kill session '2104,55948';                                                                                                               
alter system kill session '1653,63423';                                                                                                               
alter system kill session '1197,52640';                                                                                                               
alter system kill session '3280,44047';                                                                                                               
alter system kill session '2122,41691';                                                                                                               
alter system kill session '3933,29038';                                                                                                               
alter system kill session '3828,30655';                                                                                                               
