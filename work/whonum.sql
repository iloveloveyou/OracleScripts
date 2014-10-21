set scan on
set feedback off
set ver off
set heading off


 
accept phone prompt 'PHONE: '
prompt **************************
set serveroutput on


declare
mob_number# varchar2(50):=&&phone;
cursor AbonCur(mob_num# varchar2) is
select person.n,person.sirname,
person.name,person.secname,person.born,
address.city,address.street,address.house,
address.flat
from mts24e.links links,mts24e.app app,
mts24e.person person,mts24e.links links2,
mts24e.address address
where links.n1 = app.up
and links.up = 1233
and app.mob_num = mob_num#
and links.n2 = person.n
and links.spec = 2
and links2.spec = 1
and person.n = links2.N2
and address.n = links2.N1
and links2.up = 3133;
--and sysdate between app.fd and app.td
--and sysdate between links.fd and links.td
--and sysdate between person.fd and person.td
--and sysdate between links2.fd and links2.td
--and sysdate between address.fd and address.td;
AbonRec AbonCur%rowtype;
Cursor TermCur (dic# number,term# number) is
select dic_data.term 
from mts24e.dic_data dic_data
where dic_data.up = dic#
and dic_data.code = term#
and dic_data.lang = 2
and sysdate between dic_data.fd and dic_data.td;
CityRec TermCur%rowtype;
StreetRec TermCur%rowtype;
Cursor PassportCur(person# number) is
select ser,num,wd,org from mts24e.passport
where up = person#;
PassportRec PassportCur%rowtype;
begin
open AbonCur(mob_number#);
fetch AbonCur into AbonRec;
    if AbonCur%found then
        open TermCur(12,AbonRec.city);
        fetch TermCur into CityRec;
        close TermCur;
        open TermCur(306,AbonRec.street);
        fetch TermCur into StreetRec;
        close TermCur;
	open PassportCur(AbonRec.n);
	fetch PassportCur into PassportRec;
	close PassportCur;
        
        dbms_output.enable;
        dbms_output.put_line(AbonRec.sirname||' '||AbonRec.name||' '||
        AbonRec.secname||' '||to_char(AbonRec.born,'dd.mm.yyyy'));
        dbms_output.put_line(CityRec.term||' '||StreetRec.term||' '||
        AbonRec.house||' '||AbonRec.flat);
	dbms_output.put_line('Паспорт: '||PassportRec.ser||' '||
	PassportRec.num||' '||
	to_char(PassportRec.wd,'dd.mm.yyyy')||' '||PassportRec.org);
   
    end if;
close AbonCur;
end;
/

set ver on
set feedback on
set heading on
