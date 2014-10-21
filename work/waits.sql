-------------------------------------
-- Event waits statistics
-------------------------------------
set linesize 80
set serveroutput on
set ver off
set scan off
set feedback off

prompt EVENT WAITS STATISTICS


prompt Wait please...

declare
---------------------------------------------------------
/* Можно модифицировать */
    WaitTime# number := 15; -- Задержка для сбора данных
    ShowRows# number := 15; -- Сколько строк выводить
---------------------------------------------------------

    cursor c_Waits is
SELECT s.indx INDX,d.kslednam NAME,(S.KSLESTIM_BG+S.KSLESTIM_FG+S.KSLESTIM_UN) VAL,t.HSECS HSECS
FROM sys.X$KSLED D, sys.X$KSLEI S,v$timer t
WHERE S.INDX = D.INDX 
AND D.INST_ID = USERENV('INSTANCE')
AND D.KSLEDNAM IN ('alter system set mts_dispatcher',
'batched allocate scn lock request',
'BFILE check if exists',
'BFILE check if open',
'BFILE closure',
'BFILE get length',
'BFILE get name object',
'BFILE get path object',
'BFILE internal seek',
'BFILE open',
'BFILE read',
'buffer being modified waits',
'buffer busy due to global cache',
'buffer busy waits',
'buffer for checkpoint',
'buffer latch',
'buffer read retry',
'checkpoint completed',
'checkpoint range buffer not saved',
'Contacting SCN server or SCN lock master',
'control file parallel write',
'control file sequential read',
'control file single write',
'conversion file read',
'db file parallel read',
'db file parallel write',
'db file scattered read',
'db file sequential read',
'db file single write',
'debugger command',
'DFS db file lock',
'DFS enqueue lock acquisition',
'DFS enqueue lock handle',
'DFS enqueue request cancellation',
'DFS lock acquisition',
'DFS lock convert',
'DFS lock handle',
'DFS lock release',
'DFS lock request cancellation',
'direct access I/O',
'direct path read',
'direct path write',
'dispatcher shutdown',
'DLM generic wait event',
'dupl. cluster key',
'enqueue',
'file identify',
'file open',
'free buffer waits',
'free global transaction table entry',
'free process state object',
'global cache bg acks',
'global cache cr request',
'global cache freelist wait',
'global cache lock busy',
'global cache lock cleanup',
'global cache lock null to s',
'global cache lock null to x',
'global cache lock open null',
'global cache lock open s',
'global cache lock open ss',
'global cache lock open x',
'global cache lock s to x',
'global cache multiple locks',
'global cache pending ast',
'imm op',
'inactive session',
'inactive transaction branch',
'index block split',
'instance recovery',
'instance state change',
'IO clients wait for LMON to join GMS group',
'kcl bg acks',
'kdi: Done Message Dequeue - Coord',
'KOLF: Register LFI close',
'KOLF: Register LFI exists',
'KOLF: Register LFI isopen',
'KOLF: Register LFI length',
'KOLF: Register LFI lfimknm',
'KOLF: Register LFI lfimkpth',
'KOLF: Register LFI open',
'KOLF: Register LFI read',
'KOLF: Register LFI seek',
'ktpr: Done Message Dequeue - Coord',
'latch activity',
'latch free',
'library cache load lock',
'library cache lock',
'library cache pin',
'LMON wait for LMD to inherit communication channels',
'local write wait',
'lock element cleanup',
'lock element waits',
'lock manager wait for dlmd to shutdown',
'lock manager wait for remote message',
'log buffer space',
'log file parallel write',
'log file sequential read',
'log file single write',
'log file switch (archiving needed)',
'log file switch (checkpoint incomplete)',
'log file switch (clearing log file)',
'log file switch completion',
'log file sync',
'log switch/archive',
'name-service call wait',
'on-going reading of SCN to complete',
'parallel query create server',
'parallel query qref latch',
'parallel query server shutdown',
'parallel query signal server',
'pending ast',
'pending global transaction(s)',
'pipe put',
'pmon rdomain attach',
'process startup',
'queue messages',
'queue wait',
'read SCN lock',
'redo wait',
'refresh controlfile command',
'reliable message',
'resmgr:wait in actses run',
'resmgr:waiting in check',
'resmgr:waiting in check2',
'resmgr:waiting in end wait',
'resmgr:waiting in end wait2',
'resmgr:waiting in enter',
'resmgr:waiting in enter2',
'resmgr:waiting in run (queued)',
'resmgr:waiting in shutdown',
'resmgr:waiting in system stop',
'retry contact SCN lock master',
'secondary event',
'single-task message',
'slave exit',
'sort segment request',
'SQL*Net break/reset to client',
'SQL*Net break/reset to dblink',
'SQL*Net message to client',
'SQL*Net message to dblink',
'SQL*Net more data to client',
'SQL*Net more data to dblink',
'switch logfile command',
'Test if message present',
'trace continue',
'trace unfreeze',
'trace writer flush',
'trace writer I/O',
'transaction',
'unbound tx',
'undo segment extension',
'undo segment recovery',
'undo segment tx slot',
'Wait for a paralle reco to abort',
'Wait for a undo record',
'wait for checking DLM domain',
'Wait for credit - free buffer',
'Wait for credit - need buffer to send',
'Wait for credit - send blocked',
'wait for DLM latch',
'wait for DLM process allocation',
'wait for DLM reconfiguration to complete',
'wait for gms de-registration',
'wait for gms registration',
'wait for influx DLM latch',
'wait for lmd and pmon to attach DLM',
'wait for lock db to become frozen',
'wait for lock db to unfreeze',
'wait for ownership of group-owned lock',
'wait for pmon to exit',
'wait for reconfiguration to start',
'wait for recovery domain attach',
'wait for recovery domain latch in kjpr',
'wait for recovery validate to complete',
'wait for register recovery to complete',
'wait for send buffers to send DLM message',
'Wait for slaves to ACK - Query Coord',
'Wait for slaves to join - Query Coord',
'Wait for stopper event to be increased',
'wait for tickets to send DLM message',
'wakeup time manager',
'write complete waits',
'writes stopped by instance recovery',
'writes stopped by instance recovery or database suspension'
);


    type wait_array is table of c_Waits%ROWTYPE
        index by binary_integer;

    arr1        wait_array;
    arr2        wait_array;

    r_new       c_Waits%ROWTYPE;
    r_temp      c_Waits%ROWTYPE;
   
    max_i       number := 0;
    SumE        number := 0;
    Evalue      number;
begin

    for swait in c_Waits loop
        arr1(swait.indx) := swait;
    end loop;

--------------------------------------------------------
    dbms_lock.sleep(WaitTime#);
    dbms_output.enable(100000);
--------------------------------------------------------

    for swait in c_Waits loop
        begin
            r_new := swait;
            r_new.val := round((swait.val - arr1(swait.indx).val)/(swait.hsecs - arr1(swait.indx).hsecs));
            SumE := SumE +  r_new.val;
-------------------------------------------
-- Сортировка по изменению данных
-------------------------------------------
            for i in 1..max_i loop
                if r_new.val
                        > arr2(i).val
                then
                    r_temp := arr2(i);
                    arr2(i) := r_new;
                    r_new := r_temp;
                end if;
            end loop;
            max_i := max_i + 1;
            arr2(max_i) := r_new;
---------------------------------------------------------------
        exception
            when NO_DATA_FOUND then null;
        end;
    end loop;

    dbms_output.put_line('EVENT NAME                                               %');
    dbms_output.put_line('------------------------------------------------------ ------');

    for i in 1 .. least(ShowRows#,max_i) loop
if SumE != 0 then
        Evalue := round(arr2(i).val*100/SumE,2);
else
        Evalue := 0;
end if;
        dbms_output.put_line(rpad(arr2(i).name, 50) || ' ' ||
            to_char(Evalue , '99990.00')||'%');
    end loop;
end;
/

set feedback on
