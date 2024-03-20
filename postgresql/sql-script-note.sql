-- 1.1 简单查询
select prod_name
from tysql5.products;

select *
from tysql5.products;

select distinct vend_id
from tysql5.products;   -- distinct作用于所有的列；

select prod_name
from tysql5.products
fetch first 5 rows only; -- DB2语法

-- select prod_name from tysql5.products where rownum <= 5; -- Oracle语法
-- select top 5 prod_name from tysql5.products; -- Sql Server语法
-- select prod_name from tysql5.products limit 5; -- Mysql、PostgreSQL语法

select prod_name
from tysql5.products
limit 5 offset 5; -- 从0开始计数，limit 1 offset 1会检索第2行，而不是第1行；

select prod_id, prod_name, prod_price
from tysql5.products order by 2, 3;

select prod_id, prod_name, prod_price
from tysql5.products order by prod_name desc, prod_price; -- 不指定则默认ASC

-- 1.2 过滤数据
select *
from tysql5.products;

select prod_id, prod_price, prod_name
from tysql5.products
where vend_id = 'DLL01' OR vend_id = 'BRS01';

select vend_id, prod_name, prod_price
from tysql5.products
where vend_id = 'DLL01' or vend_id = 'BRS01' and prod_price >= 10;   -- and的优先级高于or

select prod_name, prod_price
from tysql5.products
where (vend_id = 'DLL01' OR vend_id = 'BRS01') and prod_price >= 10;

select prod_name, prod_price
from tysql5.products
where vend_id in ('DLL01','BRS01') order by prod_name;    -- in比or执行更快

select prod_name
from tysql5.products
where not vend_id = 'DLL01' order by prod_name;

select prod_id, prod_name
from tysql5.products
where prod_name like 'Fish%';

select prod_id, prod_name
from tysql5.products
where prod_name like '%bean bag%';

select prod_name
from tysql5.products
where prod_name like 'F%y'; -- like能匹配0个、1个、多个字符；

select prod_name
from tysql5.products
where prod_name like 'F%y%'; -- 应对数据库自动补充空格的情况；

select prod_name
from tysql5.products
where prod_name like '%'; -- 不会匹配null；

select prod_id, prod_name
from tysql5.products
where prod_name like '__ inch teddy bear'; -- _匹配单个字符；

select prod_id, prod_name
from tysql5.products
where prod_name like '__ inch teddy bear'; -- ；

select cust_contact
from tysql5.customers
where ltrim(cust_contact) like '[JM]%' -- ???
order by cust_contact;

select cust_contact
from tysql5.customers
where cust_contact like '[^JM]%' -- ???
order by cust_contact;

-- 1.3 计算字段
-- select vend_name + '(' + vend_country + ')'
-- from tysql5.vendors  -- 适用于Sql Server
-- order by vend_name;

select vend_name || '(' || vend_country || ')'
from tysql5.vendors -- 适用于DB2、Oracle、PostgreSQL、SQLite
order by vend_name;

select concat(vend_name, ' (', vend_country, ')')
from tysql5.vendors -- MySQL、MariaDB
order by vend_name;

select
    trim(vend_name) || ' (' || rtrim(vend_country) || ')' as vend_title  -- 去掉右边所有的空格，另外还有ltrim()、trim()
from tysql5.vendors
order by vend_name;

-- 注：使用别名的场景包括：实际列名中包含不合法的字符（如空格）时需要重新命名；
select prod_id, quantity, item_price
from tysql5.orderitems
where order_num = 20008;

select
       prod_id,
       quantity,
       item_price,
       quantity * item_price as expanded_price
from tysql5.orderitems
where order_num = 20008;

-- 1.4 函数
-- 各DBMS通用型函数：
-- （1）提取字符串：substr() substring()
-- （2）数据类型转换：cast() convert()
-- （3）取当前日期：current_date curdate() getdate() date() sysdate
-- 大多数SQL支持的函数：
-- 1.4.1 用于处理文本字符串（如删除或填充值，转换值为大写或小写）的文本函数。
    -- LEFT()（或使用子字符串函数） 返回字符串左边的字符
    -- LENGTH()（也使用DATALENGTH()或LEN()） 返回字符串的长度
    -- LOWER() 将字符串转换为小写
    -- LTRIM() 去掉字符串左边的空格
    -- RIGHT()（或使用子字符串函数） 返回字符串右边的字符
    -- RTRIM() 去掉字符串右边的空格
    -- SUBSTR()或SUBSTRING() 提取字符串的组成部分
    -- SOUNDEX() 返回字符串的SOUNDEX值（postgre不支持）
    -- UPPER() 将字符串转换为大写
-- 1.4.2 用于在数值数据上进行算术操作（如返回绝对值，进行代数运算）的数值函数。
    -- ABS() 返回一个数的绝对值
    -- COS() 返回一个角度的余弦
    -- EXP() 返回一个数的指数值
    -- PI() 返回圆周率 π 的值
    -- SIN() 返回一个角度的正弦
    -- SQRT() 返回一个数的平方根
    -- TAN() 返回一个角度的正切
-- 1.4.3 用于处理日期和时间值并从这些值中提取特定成分（如返回两个日期之差，检查日期有效性）的日期和时间函数。
-- 日期函数（参考：https://blog.csdn.net/weixin_40594160/article/details/100139852）
select date_part('year', current_date);
select extract('year' from current_date);
select substr(''); -- 函数名不区分大小写
select upper('abc');
select date_trunc('week', current_date) + interval '1 day' AS first_day;
select now();
select current_timestamp;
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
select extract(week from now());
select now();
select extract(doy from now());
select extract(epoch from now());
select now() + '10 min';
select timestamp with time zone 'epoch' + 1369755555 * interval '1 second';
select cast(to_char(current_date, 'yyyymmdd') as integer); -- 当日
select cast(to_char(current_date - interval '1 day', 'yyyymmdd') as integer); -- 昨日
select extract(week from cast('2024-02-29' as date));
-- 1.4.4 用于生成美观好懂的输出内容的格式化函数（如用语言形式表达出日期，用货币符号和千分位表示金额）。
-- 1.4.5 返回 DBMS 正使用的特殊信息（如返回用户登录信息）的系统函数。

-- 1.5 汇总数据
-- 1.5.1 聚集函数
-- AVG() 返回某列的平均值：列名必须作为函数参数给出，函数忽略列值为null 的行；
select avg(prod_price) as avg_price
from tysql5.products;

select avg(prod_price) as avg_price
from tysql5.products
where vend_id = 'DLL01';
-- COUNT() 返回某列的行数：如果指定列名，则 COUNT()函数会忽略指定列的值为 NULL 的行，但如果 COUNT()函数中用的是星号（*），则不忽略。
select count(*) as avg_price -- 使用 COUNT(*)对表中行的数目进行计数，不管表列中包含的是空值（NULL）还是非空值。
from tysql5.products;

select count(prod_id) as avg_price -- 使用 COUNT(column)对特定列中具有值的行进行计数，忽略 NULL 值。
from tysql5.products;
-- MAX() 返回某列的最大值：虽然 MAX()一般用来找出最大的数值或日期值，但许多（并非所有）DBMS 允许将它用来返回任意列中的最大值，
--                        包括返回文本列中的最大值。在用于文本数据时，MAX()返回按该列排序后的最后一行。MAX()函数忽略列值为 NULL 的行。
select max(prod_price) as max_price
from tysql5.products;
-- MIN() 返回某列的最小值:虽然 MIN()一般用来找出最小的数值或日期值，但许多（并非所有）DBMS 允许将它用来返回任意列中的最小值，
--                       包括返回文本列中的最小值。在用于文本数据时，MIN()返回该列排序后最前面的行。MIN()函数忽略列值为 NULL 的行。
select min(prod_price) as min_price
from tysql5.products;
-- SUM() 返回某列值之和:SUM()函数忽略列值为 NULL 的行。
select sum(quantity) as items_ordered
from tysql5.orderitems
where order_num = 20005;

select sum(item_price * quantity) as items_ordered
from tysql5.orderitems
where order_num = 20005;
-- 1.5.2 聚集不同值：
-- （1）如果指定列名，则 DISTINCT 只能用于 COUNT()。DISTINCT 不能用于 COUNT(*)。类似地，DISTINCT 必须使用列名，不能用于计算或表达式。
-- （2）虽然 DISTINCT 从技术上可用于 MIN()和 MAX()，但这样做实际上没有价值。一个列中的最小值和最大值不管是否只考虑不同值，结果都是相同的。
select avg(distinct prod_price) as avg_price
from tysql5.products
where vend_id = 'DLL01';
-- 1.5.3 组合聚集函数
select
    count(*) as num_items
    ,min(prod_price) as price_min
    ,max(prod_price) as price_max
    ,avg(prod_price) as price_avg
from tysql5.products;

-- 1.6 数据分组
-- 1.6.1 group by
-- （1）GROUP BY 子句可以包含任意数目的列，因而可以对分组进行嵌套，更细致地进行数据分组。
-- （2）如果在 GROUP BY 子句中嵌套了分组，数据将在最后指定的分组上进行汇总。换句话说，在建立分组时，指定的所有列都一起计算（所以
--      不能从个别的列取回数据）。
-- （3）GROUP BY 子句中列出的每一列都必须是检索列或有效的表达式（但不能是聚集函数）。如果在 SELECT 中使用表达式，则必须在 GROUP BY
--      子句中指定相同的表达式。不能使用别名。
-- （4）大多数 SQL 实现不允许 GROUP BY 列带有长度可变的数据类型（如文本或备注型字段）。
-- （5） 除聚集计算语句外，SELECT 语句中的每一列都必须在 GROUP BY 子句中给出。
-- （6）如果分组列中包含具有 NULL 值的行，则 NULL 将作为一个分组返回。如果列中有多行 NULL 值，它们将分为一组。
-- （7）GROUP BY 子句必须出现在 WHERE 子句之后，ORDER BY 子句之前。
select
    vend_id, count(*) as num_prods
from tysql5.products
group by vend_id;
-- 1.6.2 having
-- （1）where过滤行，having过滤分组；
-- （2）where 在数据分组前进行过滤，having在数据分组后进行过滤，where排除的行不包括在分组中；
select
    cust_id, count(*) as orders
from tysql5.orders
group by cust_id
having count(*) >= 2;

select
    vend_id, count(*) as num_prods
from tysql5.products
where prod_price >= 4
group by vend_id
having count(*) >= 2;

-- 1.6.3 分组和排序
-- 一般在使用 GROUP BY 子句时，应该也给出 ORDER BY 子句。这是保证数据正确排序的唯一方法。千万不要仅依赖 GROUP BY 排序数据。
select
    order_num, count(*) as items
from tysql5.orderitems
group by order_num
having count(*) >= 3
order by items, order_num;
-- SELECT 子句顺序:
-- SELECT 要返回的列或表达式 是
-- FROM 从中检索数据的表 仅在从表选择数据时使用
-- WHERE 行级过滤 否
-- GROUP BY 分组说明 仅在按组计算聚集时使用
-- HAVING 组级过滤 否
-- ORDER BY 输出排序顺序 否