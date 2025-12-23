---根据传入日期得到对于周的每一天及对应的星期数
select
    '第' || extract(week from cast(current_timestamp as date)) || '周'
    '（' ||
    cast(to_char(current_timestamp - (extract (dow from current_timestamp) - 1 || ' day')::interval, 'yyyymmdd') as varchar(20))
    ||  '-' ||
    cast(to_char(current_timestamp - (extract (dow from current_timestamp) - 7 || ' day')::interval, 'yyyymmdd') as varchar(20))
    || '）';

select
    '第' || extract(week from cast(current_timestamp as date)) || '周'
    '（' ||
    cast(to_char(current_timestamp - (extract (dow from current_timestamp) - 1 || ' day')::interval, 'yyyymmdd') as varchar(20))
    ||  '-' ||
    cast(to_char(current_timestamp - (extract (dow from current_timestamp) - 7 || ' day')::interval, 'yyyymmdd') as varchar(20))
    || '）';

select
	column_name, data_type, is_nullable, column_default
from information_schema.columns
where table_name = '';

select extract(week from cast(current_timestamp as date));
select extract(week from cast('20240811' as date));


select extract(week from cast('20240701' as date));

-- TITLE、TABLESIZE、CREATETIME、UPDATETIME、SYSTEM_NAME、SCHEMA、DB_NAME

select length('');

-- 查询视图创建语句
select pg_get_viewdef('public.all_cb_undel_view') as view_definition;

select current_user;

-- 10.16.232.185  crmweb Crmweb_2022
-- 10.16.232.41   sjglb  sjglb@123
