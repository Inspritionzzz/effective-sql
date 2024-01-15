-- 1. 窗口函数
-- 1.1 基于行
-- order by [column] rows between <unbounded preceding> and <[num] preceding>
--                                 <[num] preceding>         <current row>
--                                 <current row>             <[num] following>
--                                 <[num] following>         unbounded following
select
    order_id
    ,order_date
    ,amount
    ,sum(amount) over(order by order_date rows between unbounded preceding and current row) as total_amount
from public.atguigu_greenplum_order_info;

-- 1.2 基于值
-- order by [column] range between <unbounded preceding> and <[num] preceding>
--                                 <[num] preceding>         <current row>
--                                 <current row>             <[num] following>
--                                 <[num] following>         unbounded following
select
    order_id
    ,order_date
    ,amount
    ,sum(amount) over(order by order_date range between unbounded preceding and current row) as total_amount
from public.atguigu_greenplum_order_info;

-- 1.3 分区
select
    order_id
    ,order_date
    ,amount
    ,sum(amount) over(partition by user_id order by order_date rows between unbounded preceding and current row) as total_amount
from public.atguigu_greenplum_order_info;

-- 1.4 缺省
-- over()中的三部分内容 partition by、order by、(rows|range) between ... and ... 均可省略不写；
-- partition by省略不写，表示不分区；
-- order by省略不写，表示不排序；
-- (rows|range) between ... and ... 省略不写，泽使用其默认值，默认值如下：
-- 若over()中包含order by，则默认值为：range between unbounded preceding and current row；
-- 若over()中不包含order by，则默认值为：range between unbounded preceding and unbounded following；

select
    order_id
    ,order_date
    ,amount
    ,sum(amount) over(partition by user_id order by order_date) as total_amount
from public.atguigu_greenplum_order_info;

-- 1.5 常用窗口函数
-- max(amount) over(...)
-- min(amount) over(...)
-- sum(amount) over(...)
-- avg(amount) over(...)
-- count(amount) over(...)
-- lead(amount) over(...)
-- lag(amount) over(...)
select
    order_id
    ,order_date
    ,amount
    ,lag(order_date, 1, '1970-01-01') over(partition by user_id order by order_date) as last_date
    ,lead(order_date, 1, '9999-12-31') over(partition by user_id order by order_date) as next_date
from public.atguigu_greenplum_order_info;

select
    order_id
    ,order_date
    ,amount
    ,first_value(order_date, false) over(partition by user_id order by order_date) as last_date
    ,last_value(order_date, false) over(partition by user_id order by order_date) as next_date
from public.atguigu_greenplum_order_info;

select
    order_id
    ,order_date
    ,amount
    ,rank() over(partition by course order by score desc) as rk
    ,dense_rank() over(partition by course order by score desc) as dense_rk
    ,row_number() over(partition by course order by score desc) as rn
from public.atguigu_greenplum_score_info;
