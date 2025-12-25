-- 计算日期差
select ('2025-12-22'::date - '2025-06-25'::date) as days_diff;

select floor(extract(epoch from (ts1 - ts2)) / 86400) as total_days
from (select '2025-12-25 10:30:00'::timestamp as ts1, '2025-12-20 08:00:00'::timestamp as ts2) t;

select ('2025-12-25 10:30:00'::timestamp - '2025-12-20 08:00:00'::timestamp) as time_diff;

select age('2025-12-24'::date, '2000-05-15'::date);

-- 计算周、月、季度
select
  dt,
  extract(year from dt) as year,
  extract(month from dt) as month,
  extract(week from dt) as week,
  extract(quarter from dt) as quarter,
  ceil(extract(month from dt) / 6.0) as half_year
from (values ('2025-12-25'::date)) as t(dt);
