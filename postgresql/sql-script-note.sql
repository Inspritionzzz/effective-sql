-- 日期函数（参考：https://blog.csdn.net/weixin_40594160/article/details/100139852）
select now();

select current_timestamp;

select current_date;

select current_time;

select now() + interval '2 years';  -- 2015-04-12 15:49:03.168851+08 (1 row)

select now() + interval '2 year'; -- 2015-04-12 15:49:12.378727+08 (1 row)

select now() + interval '2 y'; -- 2015-04-12 15:49:25.46986+08 (1 row)

select now() + interval '2 Y'; -- 2015-04-12 15:49:28.410853+08 (1 row)

select now() + interval '2Y'; -- 2015-04-12 15:49:31.122831+08 (1 row)

select now() + interval '1 month';

select now() - interval '3 week';

-- 说明：
-- interval 可以不写，其值可以是：
-- Abbreviation	Meaning
-- Y	Years
-- M	Months (in the date part)
-- W	Weeks
-- D	Days
-- H	Hours
-- M	Minutes (in the time part)
-- S	Seconds

select age(timestamp '2007-09-15');

select extract(year from now());

select extract(week from  now() + interval '6 day');

select now() + interval '5 day';

select extract(month from now());

select now();

select extract(doy from now());

select extract(epoch from now());

select now() + '10 min';

select timestamp with time zone 'epoch' + 1369755555 * interval '1 second';

select cast(to_char(current_date, 'yyyymmdd') as integer); -- 当日

select cast(to_char(current_date - interval '1 day', 'yyyymmdd') as integer); -- 昨日

select extract(week from cast('2024-02-29' as date));

select 1;
select 1;

select
	column_name, data_type, is_nullable, column_default
from information_schema.columns
where table_name = 'dm_allbiz_idx';


