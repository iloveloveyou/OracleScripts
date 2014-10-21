--LIST TOP SESSIONS FOR REDO LOG ACTIVITY (Kb/C)                                                                                                      
----------------------------------------------------                                                                                                  
--SID   SPID    REDO SIZE MASHINE               SQL                                                                                                   
----- ----- ----------- --------------------- ------------                                                                                            
--2963  20798         418 CBOSS\GENER-3         begin kk_sql.Set_Big_Rollback(:is_commit=1); end;                                                     
--4043  21338         410 CBOSS\GENER-3         begin kk_sql.Set_Big_Rollback(:is_commit=1); end;                                                     
--4752  20606         258 CBOSS\GENER-3         insert into calls_discard_heap (reason,r_cdr_block,record_ty                                          
--3829  15331          94 SERVER JOB            SELECT AMOUNT$ - NVL(CDR_CHARGE$,0) ,SYSDATE - NVL(TREAT_DT,                                          
--2198  9837           62 CBOSS\GENER-1         begin kk_sql.Set_Big_Rollback(:is_commit=1); end;                                                     
--3720  21743          51 TULA\FINX4            SELECT SID,AUDSID,USER#,USERNAME,OSUSER,PROGRAM,MACHINE,TERM                                          
--4187  9722           50 CBOSS\GENER-1         insert into num_calls (N_BLK, UP ,SRV_A ,SRV_B ,IND_B,STRT ,                                          
--2391  9724           44 CBOSS\GENER-1         insert into num_calls (N_BLK, UP ,SRV_A ,SRV_B ,IND_B,STRT ,                                          
--2377  1809           38 CBOSS\FAX7            SELECT B.LOC,C.ROWID RW,R_CALLS_LOG,DUR,SERVICES,NVL(AIR,0)                                           
--4169  3767           30 MQS\MQS000104         begin  TA_INTERTAB.Delivery_Message(ID_in => :ID,Receiver_ID                                          
--2442  3285           29 MQS\MQS000102         begin  TA_INTERTAB.Delivery_Message(ID_in => :ID,Receiver_ID                                          
--369   2331           27 MQS\MQS000101         begin  TA_INTERTAB.Delivery_Message(ID_in => :ID,Receiver_ID                                          
--4585  15294          26 SERVER JOB            SELECT /*+ index(balance balance$up)  */AMOUNT,FD   FROM BAL                                          
--4623  15346          23 SERVER JOB            SELECT /*+ index(s service$up$srv) */N,PAR2   FROM SERVICE S                                          
--4211  22819          23 MTSMSK\Y001747        SELECT SYSDATE   FROM SYS.DUAL                                                                        
--1294  3815           19 MQS\MQS000104         begin  TA_INTERTAB.Delivery_Message(ID_in => :ID,Receiver_ID                                          
--3693  3792           18 MQS\MQS000104         begin  TA_INTERTAB.Delivery_Message(ID_in => :ID,Receiver_ID                                          
--133   6985           18 MQS\MQS000103         begin  TA_INTERTAB.Delivery_Message(ID_in => :ID,Receiver_ID                                          
--4146  8691           17 MTSMSK\Y000985        SELECT SYSDATE   FROM SYS.DUAL                                                                        
--456   18178          14 CBOSS\VOICE1          begin :RETVAL:=kk_sms_info.NextXXXX(:o_DstAddr,:o_ScriptTxt,                                          
alter system kill session '2963,35213';                                                                                                               
alter system kill session '4043,46699';                                                                                                               
alter system kill session '4752,31251';                                                                                                               
alter system kill session '3829,28336';                                                                                                               
alter system kill session '2198,58199';                                                                                                               
alter system kill session '3720,38693';                                                                                                               
alter system kill session '4187,50845';                                                                                                               
alter system kill session '2391,35544';                                                                                                               
alter system kill session '2377,34240';                                                                                                               
alter system kill session '4169,26802';                                                                                                               
alter system kill session '2442,27541';                                                                                                               
alter system kill session '369,4178';                                                                                                                 
alter system kill session '4585,26570';                                                                                                               
alter system kill session '4623,49604';                                                                                                               
alter system kill session '4211,33646';                                                                                                               
alter system kill session '1294,23248';                                                                                                               
alter system kill session '3693,17322';                                                                                                               
alter system kill session '133,18739';                                                                                                                
alter system kill session '4146,38732';                                                                                                               
alter system kill session '456,61';                                                                                                                   
