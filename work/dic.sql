undefine First_part_name_tab 
undefine Second_part_name_tab
select table_name from dictionary where table_name like upper('%&first_parth_name_tab%&second_part_name_tab%')
/
