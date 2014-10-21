set scan on
set feedback off
set ver off
set heading off

accept num prompt 'NUMBER: '
prompt **************************
set serveroutput on

declare
Cursor NumCur is
select i.surname,i.name,i.PATRONYMIC_NAME,td.msisdn,
cust.customer_address.get_address(c.REG_ADDRESS_ID) address
from cust.terminal_device td,
cust.personal_account_td patd,cust.personal_account pa,
cust.contract_personal_account cpa,cust.customer_contract cc,
cust.customer c,cust.individual_name i
where patd.terminal_device_id = td.terminal_device_id
and patd.personal_account_id = pa.personal_account_id
and cpa.personal_account_id = pa.personal_account_id
and cpa.contract_id = cc.contract_id
and cc.customer_id = c.customer_id
and c.customer_id = i.customer_id
and td.date_to is null
and patd.date_to is null
and pa.date_to is null
and cpa.date_to is null
and cc.date_to is null
and c.date_to is null
and i.date_to is null
and td.msisdn = '&&num';
begin
dbms_output.enable(2000000);

For NumRec in NumCur loop
	dbms_output.put_line(NumRec.surname||' '||NumRec.name||' '||NumRec.PATRONYMIC_NAME);
	dbms_output.put_line(NumRec.address);
	dbms_output.put_line('Mobile number: '||NumRec.msisdn);
end loop;
end;
/

set ver on
set feedback on
set heading on
