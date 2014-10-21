set scan on
set feedback off
set ver off
set heading off


 
accept sirname prompt 'SIRNAME: '
accept name    prompt '   NAME: '
accept secname prompt 'SECNAME: '
prompt **************************
set serveroutput on


declare
sirname## varchar2(100) := '&&sirname';
name##    varchar2(100) := '&&name';
secname## varchar2(100) := '&&secname';
--sirname## varchar2(100) := '+¨v¸þò';
--name##    varchar2(100) := 'Lûõú¸õù';
--secname## varchar2(100) := '+ûõóþòø¢';

cursor AbonCur(sirname# varchar2,name# varchar2,secname# varchar2) is
select app.n n_app,person.sirname,person.name,person.secname,app.mob_num,person.n,person.born,
address.city,address.street,address.house,address.flat
from mts24e.links links,mts24e.app app,
mts24e.person person,mts24e.links links2,
mts24e.address address
where
person.sirname = sirname#
and upper(person.name) = upper(nvl(name#,person.name)) 
and upper(person.secname) = upper(nvl(secname#,person.secname))
and links.n1 = app.up
and links.up = 1233
and links.n2 = person.n
and links.spec = 2
and links2.spec = 1
and person.n = links2.N2
and address.n = links2.N1
and links2.up = 3133
and sysdate between app.fd and app.td
and sysdate between links.fd and links.td
and sysdate between person.fd and person.td
and sysdate between links2.fd and links2.td
and sysdate between address.fd and address.td
and length(app.mob_num) > 1;
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
        dbms_output.enable;

open AbonCur(sirname##,name##,secname##);
loop
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
        dbms_output.put_line(AbonRec.sirname||' '||AbonRec.name||' '||AbonRec.secname);
        dbms_output.put_line('Born:'||to_char(AbonRec.born,'dd.mm.yyyy'));
        dbms_output.put_line(CityRec.term||' '||StreetRec.term||' '||AbonRec.house||' '||AbonRec.flat);
	dbms_output.put_line('Passport: '||PassportRec.ser||' '||PassportRec.num||' '||to_char(PassportRec.wd,'dd.mm.yyyy')||' '||PassportRec.org);
	dbms_output.put_line('Mobile number: '||AbonRec.mob_num);
	dbms_output.put_line('APP: '||AbonRec.n_app);
	dbms_output.put_line('--------------------------------');
    else
	dbms_output.put_line('--------------------------------');
	exit;
    end if;
end loop;
close AbonCur;
end;
/

set ver on
set feedback on
set heading on

