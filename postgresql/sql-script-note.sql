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

-- 1.7 使用子查询
-- 1.7.1 使用子查询进行过滤
select cust_id
from tysql5.orders
where order_num in (select order_num
                    from tysql5.orderitems
                    where prod_id = 'RGAN01');

select cust_name, cust_contact
from tysql5.customers
where cust_id in (select cust_id
                  from tysql5.orders
                  where order_num in (select order_num
                                      from tysql5.orderitems
                                      where prod_id = 'RGAN01'));

-- 1.7.2 作为计算资源使用子查询
select
    cust_name,
    cust_state,
    (select count(*)
     from tysql5.orders
     where tysql5.orders.cust_id =tysql5. customers.cust_id) as orders -- 需要使用完全限定列名；
from tysql5.customers
order by cust_name;

select
    cust_name,
    cust_state,
    (select count(*)
     from tysql5.orders
     where cust_id = cust_id) as orders -- 需要使用完全限定列名；
from tysql5.customers
order by cust_name;

-- 1.8 联结表
select vend_name, prod_name, prod_price
from tysql5.vendors, tysql5.products
where vendors.vend_id = products.vend_id;

select vend_name, prod_name, prod_price
from tysql5.vendors, tysql5.products;

select vend_name, prod_name, prod_price
from tysql5.vendors
inner join tysql5.products on vendors.vend_id = products.vend_id;

select prod_name, vend_name, prod_price, quantity
from tysql5.orderitems, tysql5.products, tysql5.vendors
where products.vend_id = vendors.vend_id
      and orderitems.prod_id = products.prod_id
      and order_num = 20007;

select cust_name, cust_contact
from tysql5.customers, tysql5.orders, tysql5.orderitems
where customers.cust_id = orders.cust_id
      and orderitems.order_num = orders.order_num
      and prod_id = 'RGAN01';

-- 1.9 创建高级联结
-- 1.9.1 表别名
select
    rtrim(vend_name) || ' (' || rtrim(vend_country) || ')' as vend_title
from tysql5.vendors
order by vend_name;

select cust_name, cust_contact
from tysql5.customers as c, tysql5.orders as o, tysql5.orderitems as oi
where c.cust_id = o.cust_id
      and oi.order_num = o.order_num
      and prod_id = 'RGAN01';
-- 1.9.2 使用不同类型的联结
-- 自联结：多数DBMS处理联结比处理子查询快的多；
select cust_id, cust_name, cust_contact
from tysql5.customers
where cust_name = (select cust_name
                   from tysql5.customers
                   where cust_contact = 'Jim Jones');

select c1.cust_id, c1.cust_name, c1.cust_contact
from tysql5.customers as c1, tysql5.customers as c2
where c1.cust_name = c2.cust_name
      and c2.cust_contact = 'Jim Jones';
-- 自然联结
select
    c.*, o.order_num, o.order_date,
    oi.prod_id, oi.quantity, oi.item_price
from tysql5.customers as c, tysql5.orders as o, tysql5.orderitems as oi
where c.cust_id = o.cust_id
and oi.order_num = o.order_num
and prod_id = 'RGAN01';

-- 外联结
select customers.cust_id, orders.order_num
from tysql5.customers
left outer join tysql5.orders on customers.cust_id = orders.cust_id;

select customers.cust_id, orders.order_num
from tysql5.customers
right outer join tysql5.orders on customers.cust_id = orders.cust_id;

select customers.cust_id, orders.order_num
from tysql5.customers
full outer join tysql5.orders on customers.cust_id = orders.cust_id;

-- 使用带聚集函数的联结
select
    customers.cust_id
    ,count(orders.order_num) as num_ord
from tysql5.customers
inner join tysql5.orders on customers.cust_id = orders.cust_id
group by customers.cust_id;

select
    customers.cust_id
    ,count(orders.order_num) as num_ord
from tysql5.customers
left outer join tysql5.orders on customers.cust_id = orders.cust_id
group by customers.cust_id;

-- 1.10 组合查询
-- union
-- （1）每个查询必须包含相同的列、表达式或聚集函数，各个列不需要以相同的次序列出；
-- （2）列数据类型必须兼容；
-- （3）union自动去除重复的行；
select cust_name, cust_contact, cust_email
from tysql5.customers
where cust_state in ('IL','IN','MI')
    union
select cust_name, cust_contact, cust_email
from tysql5.customers
where cust_name = 'Fun4All';
-- union all
select cust_name, cust_contact, cust_email
from tysql5.customers
where cust_state in ('IL','IN','MI')
    union all
select cust_name, cust_contact, cust_email
from tysql5.customers
where cust_name = 'Fun4All';

select cust_name, cust_contact, cust_email
from tysql5.customers
where cust_state in ('IL','IN','MI')
    union
select cust_name, cust_contact, cust_email
from tysql5.customers
where cust_name = 'Fun4All'
order by cust_name, cust_contact; -- 会排序整个结果集；

-- 1.11 插入数据
-- 1.11.1 插入完整行
insert into tysql5.customers
values(1000000006, 'Toy Land', '123 Any Street', 'New York', 'NY', '11111', 'USA', NULL, NULL);
-- 注：
-- （1）虽然这种语法很简单，但并不安全，应该尽量避免使用。上面的 SQL 语句高度依赖于表中列的定义次序，还依赖于其容易获得的次序信息。即
--      使可以得到这种次序信息，也不能保证各列在下一次表结构变动后保持完全相同的次序。因此，编写依赖于特定列次序的 SQL 语句是很不安全
--      的，这样做迟早会出问题。
-- （2）如果不提供列名，则必须给每个表列提供一个值；如果提供列名，则必须给列出的每个列一个值。否则，就会产生一条错误消息，相应的行不能成功插入。
insert into tysql5.customers(cust_id, cust_name, cust_address, cust_city, cust_state, cust_zip, cust_country, cust_contact, cust_email)
values(1000000006, 'Toy Land', '123 Any Street', 'New York', 'NY', '11111', 'USA', NULL, NULL); --表的结构改变，这条INSERT 语句仍然能正确工作。

-- 1.11.2省略列需要满足以下某个条件：
-- （1）该列定义为允许 NULL 值（无值或空值）；
-- （2）在表定义中给出默认值；
insert into tysql5.customers(cust_id, cust_name, cust_address, cust_city, cust_state, cust_zip, cust_country)
values(1000000006, 'Toy Land', '123 Any Street', 'New York', 'NY', '11111', 'USA');

-- 1.11.3 插入检索出的数据
insert into tysql5.customers(cust_id,
                             cust_contact,
                             cust_email,
                             cust_name,
                             cust_address,
                             cust_city,
                             cust_state,
                             cust_zip,
                             cust_country)
select cust_id,
       cust_contact,
       cust_email,
       cust_name,
       cust_address,
       cust_city,
       cust_state,
       cust_zip,
       cust_country
from tysql5.custnew;
-- 注：DBMS不关心select返回的列名，它使用的是列的位置，因此 SELECT 中的第一列（不管其列名）将用来填充表列中指定的第一列，第二列将用来填充表列中
-- 指定的第二列，如此等等。

-- 1.11.4 从一个表复制到另一个表
create table tysql5.custcopy as select * from tysql5.customers;
-- select * into tysql5.custcopy from tysql5.customers;    -- SqlServer写法

-- 1.12 更新和删除数据
-- 1.12.1 update
update tysql5.customers
set cust_email = 'kim@thetoystore.com'
where cust_id = 1000000005;

update tysql5.customers
set cust_contact = 'Sam Roberts',
    cust_email = 'sam@toyland.com'
where cust_id = 1000000006;

update tysql5.customers
set cust_email = null
where cust_id = 1000000006; -- 删除指定的列；

-- 1.12.2 delete
-- delete不删除表本身，删除全表建议用truncate，速度更快；
delete from tysql5.customers
where cust_id = 1000000006; -- 删除指定的行；

-- undo
-- 1.13 创建和操纵表
