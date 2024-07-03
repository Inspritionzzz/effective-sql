



convert(varchar(12), OPDATE, 112) = convert(varchar(12), DATEADD(day, -1, getdate()), 112);

delete from dmddata.uif_wande_asharemanagementholdreward
where cast(to_char(OPDATE, 'yyyymmdd') as integer) = cast(to_char(current_date - interval '1 day', 'yyyymmdd') as integer);

-- DM数据交换任务_统一资讯平台_万得_asharemanagementholdreward
--
-- DM数据交换任务_统一资讯平台_万得_asharemanagement
--
-- DM数据交换任务_统一资讯平台_万得_asharebalancesheet
--
-- DM数据交换任务_统一资讯平台_万得_asharemanagementexpense
--
-- DM数据交换任务_统一资讯平台_万得_asharestaff

select timestamp;

select to_char(current_date, 'yyyymmdd');


-- insert into dmddata.dq_chk_rule_table(rec_date, prob_cls, check_dim, prob_short_desp, prob_desp, check_freq, involve_sys_chs_name, involve_sys_en_name, involve_table_name, dtl_rslt_table_name
--                                                                            ,qual_prob_id, ref_biz, dept, check_rule_ver_and_desp, check_rule_ver_date, check_rule_stat, rmk)
-- values('20240611', '主数据', '唯一性', '产品主数据问题', '相同名称的产品重复编制P码', '每日',
--         '总公司-非自然人客户编码系统', 'CCRM', 'dwodata.ccm_zxjtcrm_jg_prod_new_basic_info', 'dmddata.dq_chk_dtl_ccrm_01'
--             ,'CCRM-01', '', '信息技术部', 'CCRM-01-相同名称的产品重复编制P码-V1', '20240611', '启用', '');






