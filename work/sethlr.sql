update mts24e.srv_mtx_reqs s set DSC=''
where up in('10683706')
and typ=2
and dsc is not null
and INSTRC(s.dsc,'-=<SSA>=- ***') > 1
