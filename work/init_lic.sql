begin
update noapp set td=sysdate-(1/24/60/60) where sysdate between fd and td
commit;
kk_lic_f.init(null);
end;
/
