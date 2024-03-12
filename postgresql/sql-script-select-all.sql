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
