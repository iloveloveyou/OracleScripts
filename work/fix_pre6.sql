set serveroutput on
declare
  cursor c1 is select up as account from abrysov.prebalance_lock_one; --подставить имя таблицы со списокм счетов
  first_call date; -- first_cdr из prebalance
  old_pre_amount number:=0;
  old_pre_tax number:=0;
  acc_call date; -- first_cdr из acc_billing
  our_call date:=sysdate-60; -- устанавливаемый нами порог
  begin_date date:=sysdate; -- начало работы скрипта
  end_date date:=sysdate; -- конец работы скрипта
  test_mode boolean:=TRUE; -- режим проверки наличия необил. звонков до рассматриваемой даты
  number_of_accounts number:=0; -- все рассмотренные счета
  sync_result boolean;
  l_Err_Str varchar2(2000);
begin
  for r1 in c1 loop -- цикл по лицевым счетам
    select nvl(first_cdr,to_date('01-01-1991 00.00.00','dd-mm-yyyy hh24.mi.ss')),amount$,tax$
      into first_call,old_pre_amount,old_pre_tax from prebalance where up=r1.account;
    if test_mode then
      begin
        sync_result:=kk_prebalance.Lock_And_Synchronize(r1.account,true,null);
--        update tmp_fix_prebalance set repair_date=sysdate,old_amount$=old_pre_amount,
--        old_tax$=old_pre_tax,old_first_cdr=first_call where rowid=r1.t_rowid;
        commit;
      exception when OTHERS then
        loop
          l_Err_Str := k_err.getnextsay;
          exit when l_Err_Str is null;
          dbms_output.put_line (l_Err_Str);
        end loop;
        rollback;
        dbms_output.put_line('OTHERS - lock and synchronize prebalance, account= '||to_char(r1.account));
        exit;
      end;
    else
      begin
          begin
            sync_result:=kk_prebalance.Lock_And_Synchronize(r1.account,true,least(first_call,our_call));
  --          update tmp_fix_prebalance set repair_date=sysdate,old_amount$=old_pre_amount,
  --          old_tax$=old_pre_tax,old_first_cdr=first_call where rowid=r1.t_rowid;
            commit;
          exception when OTHERS then
            loop
              l_Err_Str := k_err.getnextsay;
              exit when l_Err_Str is null;
              dbms_output.put_line (l_Err_Str);
            end loop;
            rollback;
            dbms_output.put_line('OTHERS - lock and synchronize prebalance, account= '||to_char(r1.account));
            exit;
          end;
      exception when NO_DATA_FOUND then
        dbms_output.put_line('NO_DATA_FOUND - before prebalance, account= '||to_char(r1.account));
        exit;
      when OTHERS then
        dbms_output.put_line('OTHERS - before prebalance, account= '||to_char(r1.account));
        exit;
      end;
    end if;
    begin
      select nvl(first_cdr,to_date('01-01-1991 00.00.00','dd-mm-yyyy hh24.mi.ss'))
        into first_call from prebalance where up=r1.account;
      select nvl(first_cdr,to_date('01-01-1991 00.00.00','dd-mm-yyyy hh24.mi.ss'))
        into acc_call from acc_billing where up=r1.account;
      if acc_call>first_call then
        update acc_billing set first_cdr=first_call where up=r1.account;
        commit;
      end if;
    exception when NO_DATA_FOUND then
      dbms_output.put_line('NO_DATA_FOUND - after prebalance, account= '||to_char(r1.account));
      exit;
    when OTHERS then
      dbms_output.put_line('OTHERS - after prebalance, account= '||to_char(r1.account));
      exit;
    end;
    number_of_accounts:=number_of_accounts+1;
  end loop;
  select sysdate into end_date from dual;
  dbms_output.put_line(' begin script: '||to_char(begin_date,'dd-mm-yyyy hh24.mi.ss'));
  dbms_output.put_line(' end script: '||to_char(end_date,'dd-mm-yyyy hh24.mi.ss'));
  dbms_output.put_line(' number of accounts: '||to_char(number_of_accounts));
end;
--rollback;
--commit;
--commit;
/