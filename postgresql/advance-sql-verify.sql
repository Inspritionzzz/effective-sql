-- update匹配多行问题

-- 使用SQL实现字符串中的括号匹配

-- 问题SQL
-- 为什么会出现多啊条数据
-- distinct为什么没生效
select distinct
    prob_short_desp,prob_desp,*
from dmddata.dq_chk_rule_table_result_all_rslt_stat as a
left join dmddata.dq_chk_rule_table_ver as b on a.qual_prob_id = b.qual_prob_id
where stat_cycle = '20250625-20251222' and a.qual_prob_id like '%CCRM%'
      and b.rec_date = ${last_two_trd_date};

select *
from customers;

select *
from customers;


