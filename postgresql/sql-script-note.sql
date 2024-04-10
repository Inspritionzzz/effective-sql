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
SELECT age(timestamp '2024-01-01', timestamp '2024-04-01') AS date_difference;

SELECT '2024-01-01'::date - '2024-04-01'::date AS days_difference;
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
-- 1.13.1 创建表
-- CREATE TABLE tysql5.products
-- (
--  prod_id CHAR(10) NOT NULL,
--  vend_id CHAR(10) NOT NULL,
--  prod_name CHAR(254) NOT NULL,
--  prod_price DECIMAL(8,2) NOT NULL,
--  prod_desc VARCHAR(1000) NULL
-- );
-- 注：如果不指定not null，则默认指定的为null；

-- 指定默认值：常用于日期或者时间戳，如default current_date；
CREATE TABLE tysql5.orderitems
(
 order_num INTEGER NOT NULL,
 order_item INTEGER NOT NULL,
 prod_id CHAR(10) NOT NULL,
 quantity INTEGER NOT NULL DEFAULT 1,   -- 指定默认值
 item_price DECIMAL(8,2) NOT NULL
);

-- 1.13.2 表结构变更
-- （1）理想情况下，不要在表中包含数据时对其进行更新。应该在表的设计过程中充分考虑未来可能的需求，避免今后对表的结构做大改动。
-- （2） 所有的 DBMS 都允许给现有的表增加列，不过对所增加列的数据类型（以及 NULL 和 DEFAULT 的使用）有所限制。
-- （3） 许多 DBMS 不允许删除或更改表中的列。
-- （4）多数 DBMS 允许重新命名表中的列。
-- （5）许多 DBMS 限制对已经填有数据的列进行更改，对未填有数据的列几乎没有限制。
-- ALTER TABLE tysql5.vendors ADD vend_phone CHAR(20);
-- ALTER TABLE tysql5.vendors DROP COLUMN vend_phone;
-- 注：删除表需要确认的外部依赖：触发器、存储过程、索引和外键；

-- 1.13.3 删除表
-- DROP TABLE tysql5.custcopy;

-- 1.13.4 重命名表
-- 每个 DBMS 对表重命名的支持有所不同。对于这个操作，不存在严格的标准。DB2、MariaDB、MySQL、Oracle 和 PostgreSQL 用户使用 RENAME
-- 语句，SQL Server 用户使用 sp_rename 存储过程，SQLite 用户使用 ALTER TABLE 语句。

-- 1.14 使用视图
-- 所有的DBMS非常一致的支持视图创建语法；
-- 为什么使用视图：
-- （1）重用 SQL 语句。
-- （2）简化复杂的 SQL 操作。在编写查询后，可以方便地重用它而不必知道其基本查询细节。
-- （3）使用表的一部分而不是整个表。
-- （4）保护数据。可以授予用户访问表的特定部分的权限，而不是整个表的访问权限。
-- （5）更改数据格式和表示。视图可返回与底层表的表示和格式不同的数据。
-- 注：因为视图不包含数据，所以每次使用视图时，都必须处理查询执行时需要的所有检索。如果你用多个联结和过滤创建了复杂的视图或者嵌
--    套了视图，性能可能会下降得很厉害。因此，在部署使用了大量视图的应用前，应该进行测试。

-- 视图的规则和限制：
-- （1）与表一样，视图必须唯一命名（不能给视图取与别的视图或表相同的名字）。
-- （2）对于可以创建的视图数目没有限制。
-- （3）创建视图，必须具有足够的访问权限。这些权限通常由数据库管理人员授予。
-- （4）视图可以嵌套，即可以利用从其他视图中检索数据的查询来构造视图。所允许的嵌套层数在不同的 DBMS中有所不同（嵌套视图可能会严重降
--      低查询的性能，因此在产品环境中使用之前，应该对其进行全面测试）。
-- （5）许多 DBMS 禁止在视图查询中使用 ORDER BY 子句。
-- （6）有些 DBMS 要求对返回的所有列进行命名，如果列是计算字段。
-- （7）视图不能索引，也不能有关联的触发器或默认值。
-- （8）有些 DBMS 把视图作为只读的查询，这表示可以从视图检索数据，但不能将数据写回底层表。详情请参阅具体的 DBMS 文档。
-- （9）有些 DBMS 允许创建这样的视图，它不能进行导致行不再属于视图的插入或更新。例如有一个视图，只检索带有电子邮件地址的顾客。
--      如果更新某个顾客，删除他的电子邮件地址，将使该顾客不再属于视图。这是默认行为，而且是允许的，但有的 DBMS 可能会防止这种
--      情况发生。

-- 1.14.1 创建视图
-- drop view tysql5.productcustomers;
create view tysql5.productcustomers as
    select cust_name, cust_contact, prod_id
    from customers, orders, orderitems
    where customers.cust_id = orders.cust_id
          and orderitems.order_num = orders.order_num;
-- 注：覆盖或更新视图，必须先删除它，然后再重新创建；
-- 使用视图格式化检索出的数据
create view tysql5.vendorlocations as
    select rtrim(vend_name) + ' (' + rtrim(vend_country) + ')'
     as vend_title
    from vendors;

-- 1.15 存储过程
-- 为什么要使用存储过程
-- （1）通过把处理封装在一个易用的单元中，可以简化复杂的操作。
-- （2）由于不要求反复建立一系列处理步骤，因而保证了数据的一致性。如果所有开发人员和应用程序都使用同一存储过程，则所使用的代码都
--      是相同的。
-- （3）上一点的延伸就是防止错误。需要执行的步骤越多，出错的可能性就越大。防止错误保证了数据的一致性。
-- （4）简化对变动的管理。如果表名、列名或业务逻辑（或别的内容）有变化，那么只需要更改存储过程的代码。
-- （5）因为存储过程通常以编译过的形式存储，所以 DBMS 处理命令所需的工作量少，提高了性能。
-- （6）存在一些只能用在单个请求中的 SQL 元素和特性，存储过程可以使用它们来编写功能更强更灵活的代码。

-- 存储过程的缺陷
-- （1）不同 DBMS 中的存储过程语法有所不同。事实上，编写真正的可移植存储过程几乎是不可能的。不过，存储过程的自我调用（名字以及数
--      据如何传递）可以相对保持可移植。因此，如果需要移植到别的DBMS，至少客户端应用代码不需要变动。
-- 注：
-- 大多数 DBMS 将编写存储过程所需的安全和访问权限与执行存储过程所需的安全和访问权限区分开来。这是好事情，即使你不能（或
-- 不想）编写自己的存储过程，也仍然可以在适当的时候执行别的存储过程。

-- 1.15.1 执行存储过程
-- （1）参数可选，具有不提供参数时的默认值。
-- （2）不按次序给出参数，以“参数=值”的方式给出参数值。
-- （3）输出参数，允许存储过程在正执行的应用程序中更新所用的参数。
-- （4）用 SELECT 语句检索数据。
-- （5）返回代码，允许存储过程返回一个值到正在执行的应用程序。

-- Oracle版本
-- CREATE PROCEDURE MailingListCount (
--  ListCount OUT INTEGER
-- )
-- IS
--     v_rows INTEGER;
-- BEGIN
--      SELECT COUNT(*) INTO v_rows
--      FROM Customers
--      WHERE NOT cust_email IS NULL;
--      ListCount := v_rows;
-- END;

-- var ReturnValue NUMBER
-- EXEC MailingListCount(:ReturnValue);
-- SELECT ReturnValue;

-- Sql Server
-- CREATE PROCEDURE MailingListCount
-- AS
-- DECLARE @cnt INTEGER
-- SELECT @cnt = COUNT(*)
-- FROM Customers
-- WHERE NOT cust_email IS NULL;
-- RETURN @cnt;

-- DECLARE @ReturnValue INT
-- EXECUTE @ReturnValue=MailingListCount;
-- SELECT @ReturnValue;

-- CREATE PROCEDURE NewOrder @cust_id CHAR(10)
-- AS
-- -- 为订单号声明一个变量
-- DECLARE @order_num INTEGER
-- -- 获取当前最大订单号
-- SELECT @order_num=MAX(order_num)
-- FROM Orders
-- -- 决定下一个订单号
-- SELECT @order_num=@order_num+1
-- -- 插入新订单
-- INSERT INTO Orders(order_num, order_date, cust_id)
-- VALUES(@order_num, GETDATE(), @cust_id)
-- -- 返回订单号
-- RETURN @order_num;

-- CREATE PROCEDURE NewOrder @cust_id CHAR(10)
-- AS
-- -- 插入新订单
-- INSERT INTO Orders(cust_id)
-- VALUES(@cust_id)
-- -- 返回订单号
-- SELECT order_num = @@IDENTITY;

-- 注：所有DBMS都支持 -- ，因此注释代码最好使用这种语法；

-- 1.16 事务处理
-- 1.16.1 事务处理
-- 事务处理：确保成批的sql操作要么完全执行，要么完全不执行，来维护数据库的完整性；

-- 注：
-- 事务处理用来管理 INSERT、UPDATE 和 DELETE 语句。不能回退 SELECT语句（回退 SELECT 语句也没有必要），也不能回退 CREATE 或
-- DROP 操作。事务处理中可以使用这些语句，但进行回退时，这些操作也不撤销。

-- SQL Server
-- BEGIN TRANSACTION
-- ...
-- COMMIT TRANSACTION

-- PostgreSQL
-- BEGIN
-- ...

-- 注：
-- 多数实现没有明确标识事务处理在何处结束。事务一直存在，直到被中断。通常，COMMIT 用于保存更改，ROLLBACK 用于撤销；
-- 1.16.2 ROLLBACK
DELETE FROM tysql5.orders;
ROLLBACK;
select * from tysql5.orders;

-- 1.16.3 COMMIT
-- 一般的 SQL 语句都是针对数据库表直接执行和编写的。这就是所谓的隐式提交（implicit commit），即提交（写或保存）操作是自动进行的。

-- 1.16.4 保留点
-- BEGIN TRANSACTION
--     INSERT INTO Customers(cust_id, cust_name) VALUES(1000000010, 'Toys Emporium');
-- SAVE TRANSACTION StartOrder;
--     INSERT INTO Orders(order_num, order_date, cust_id) VALUES(20100,'2001/12/1',1000000010);
-- IF @@ERROR <> 0 ROLLBACK TRANSACTION StartOrder;
--     INSERT INTO OrderItems(order_num, order_item, prod_id, quantity, item_price) VALUES(20100, 1, 'BR01', 100, 5.49);
-- IF @@ERROR <> 0 ROLLBACK TRANSACTION StartOrder;
--     INSERT INTO OrderItems(order_num, order_item, prod_id, quantity, item_price) VALUES(20100, 2, 'BR03', 100, 10.99);
-- IF @@ERROR <> 0 ROLLBACK TRANSACTION StartOrder;
-- COMMIT TRANSACTION

-- 1.17 游标
-- 为什么使用游标
-- 有时，需要在检索出来的行中前进或后退一行或多行，这就是游标的用途所在。游标（cursor）是一个存储在 DBMS 服务器上的数据库查询，
-- 它不是一条 SELECT 语句，而是被该语句检索出来的结果集。在存储了游标之后，应用程序可以根据需要滚动或浏览其中的数据。

-- 游标常见的选项和特性：
-- （1）能够标记游标为只读，使数据能读取，但不能更新和删除。
-- （2）能控制可以执行的定向操作（向前、向后、第一、最后、绝对位置和相对位置等）。
-- （3）能标记某些列为可编辑的，某些列为不可编辑的。
-- （4）规定范围，使游标对创建它的特定请求（如存储过程）或对所有请求可访问。
-- （5）指示 DBMS 对检索出的数据（而不是指出表中活动数据）进行复制，使数据在游标打开和访问期间不变化。
-- 注：
-- 游标主要用于交互式应用，其中用户需要滚动屏幕上的数据，并对数据进行浏览或做出更改。

-- 使用游标
-- （1）在使用游标前，必须声明（定义）它。这个过程实际上没有检索数据，它只是定义要使用的 SELECT 语句和游标选项。
-- （2）一旦声明，就必须打开游标以供使用。这个过程用前面定义的 SELECT语句把数据实际检索出来。
-- （3） 对于填有数据的游标，根据需要取出（检索）各行。
-- （4） 在结束游标使用时，必须关闭游标，可能的话，释放游标（有赖于具体的 DBMS）。

-- 创建游标
declare cursor custcursor is
select * from tysql5.customers
where cust_email is null;
-- 使用游标
open cursor custcursor;
-- ...
-- 关闭游标
close custcursor

-- 1.18 高级sql特性（约束、索引和触发器）
-- 1.18.1 约束-主键
-- CREATE TABLE Vendors
-- (
--  vend_id CHAR(10) NOT NULL PRIMARY KEY,
--  vend_name CHAR(50) NOT NULL,
--  vend_address CHAR(50) NULL,
--  vend_city CHAR(50) NULL,
--  vend_state CHAR(5) NULL,
--  vend_zip CHAR(10) NULL,
--  vend_country CHAR(50) NULL
-- );
-- alter table tysql5.vendors add constraint primary key (vend_id);

-- 设置为主键的条件：
-- （1）任意两行的主键值都不相同。
-- （2）每行都具有一个主键值（即列中不允许 NULL 值）。
-- （3）包含主键值的列从不修改或更新。（大多数 DBMS 不允许这么做，但如果你使用的 DBMS 允许这样做，好吧，千万别！）
-- （4）主键值不能重用。如果从表中删除某一行，其主键值不分配给新行。

-- 1.18.2 约束-外键
-- 外键是表中的一列，其值必须列在另一表的主键中。
-- CREATE TABLE Orders
-- (
--  order_num INTEGER NOT NULL PRIMARY KEY,
--  order_date DATETIME NOT NULL,
--  cust_id CHAR(10) NOT NULL REFERENCES Customers(cust_id)
-- );
-- ALTER TABLE Orders ADD CONSTRAINT FOREIGN KEY (cust_id) REFERENCES Customers (cust_id);

-- 注：
--（1）在定义外键后，DBMS 不允许删除在另一个表中具有关联行的行。例如，不能删除关联订单的顾客。删除该顾客的唯一方法是首先删除相
-- 关的订单（这表示还要删除相关的订单项）。由于需要一系列的删除，因而利用外键可以防止意外删除数据。
--（2）有的 DBMS 支持称为级联删除（cascading delete）的特性。如果启用，该特性在从一个表中删除行时删除所有相关的数据。
--    例如，如果启用级联删除并且从 Customers 表中删除某个顾客，则任何关联的订单行也会被自动删除。

-- 1.18.3 约束-唯一约束
-- 唯一约束既可以用 UNIQUE 关键字在表定义中定义，也可以用单独的 CONSTRAINT 定义。
-- 唯一约束和主键的区别：
-- （1）表可包含多个唯一约束，但每个表只允许一个主键。
-- （2）唯一约束列可包含 NULL 值。
-- （3）唯一约束列可修改或更新。
-- （4）唯一约束列的值可重复使用。
-- （5）与主键不一样，唯一约束不能用来定义外键。

-- 1.18.4 约束-检查约束
-- 检查约束用来保证一列（或一组列）中的数据满足一组指定的条件。
-- 检查约束应用场景：
-- （1）检查最大值或最小值；
-- （2）指定范围；
-- （3）只允许特定的值；
-- CREATE TABLE OrderItems
-- (
--  order_num INTEGER NOT NULL,
--  order_item INTEGER NOT NULL,
--  prod_id CHAR(10) NOT NULL,
--  quantity INTEGER NOT NULL CHECK (quantity > 0),
--  item_price MONEY NOT NULL
-- );
-- ADD CONSTRAINT CHECK (gender LIKE '[MF]');

-- 用户定义数据类型：
-- 有的 DBMS 允许用户定义自己的数据类型。它们是定义检查约束（或其他约束）的基本简单数据类型。例如，你可以定义自己的名为 gender
-- 的数据类型，它是单字符的文本数据类型，带限制其值为 M 或 F（对于未知值或许还允许 NULL）的检查约束。然后，可以将此数据类型用
-- 于表的定义。定制数据类型的优点是只需施加约束一次（在数据类型定义中），而每当使用该数据类型时，都会自动应用这些约束。

-- 1.18.5 索引
-- 索引用来排序数据以加快搜索和排序操作的速度。主键数据总是排序的，这是 DBMS 的工作。因此，按主键检索特定行总是一种快速有效的操作。

-- 使用索引应注意：
-- （1）索引改善检索操作的性能，但降低了数据插入、修改和删除的性能。在执行这些操作时，DBMS 必须动态地更新索引。
-- （2）索引数据可能要占用大量的存储空间。
-- （3）并非所有数据都适合做索引。取值不多的数据（如州）不如具有更多可能值的数据（如姓或名），能通过索引得到那么多的好处。
-- （4）索引用于数据过滤和数据排序。如果你经常以某种特定的顺序排序数据，则该数据可能适合做索引。
-- （5）可以在索引中定义多个列。
-- CREATE INDEX prod_name_ind ON tysql5.products (prod_name);

-- 注：
-- 索引的效率随表数据的增加或改变而变化。许多数据库管理员发现，过去创建的某个理想的索引经过几个月的数据处理后可能变得不再理
-- 想了。最好定期检查索引，并根据需要对索引进行调整。

-- 1.18.6 触发器
-- 触发器是特殊的存储过程，它在特定的数据库活动发生时自动执行。触发器可以与特定表（单个表）上的 INSERT、UPDATE 和 DELETE 操作（或组合）相关联。

-- 触发器内的代码具有以下数据的访问权：
-- （1）INSERT 操作中的所有新数据；
-- （2）UPDATE 操作中的所有新数据和旧数据；
-- （3）DELETE 操作中删除的数据。

-- 触发器的用途：
-- （1）保证数据一致。例如，在 INSERT 或 UPDATE 操作中将所有州名转换为大写。
-- （2）基于某个表的变动在其他表上执行活动。例如，每当更新或删除一行时将审计跟踪记录写入某个日志表。
-- （3）进行额外的验证并根据需要回退数据。例如，保证某个顾客的可用资金不超限定，如果已经超出，则阻塞插入。
-- （4）计算计算列的值或更新时间戳。

create trigger customer_state
after insert or update
for each row
begin
    update tysql5.customers
    set cust_state = upper(cust_state)
    where customers.cust_id = :old.cust_id;
end;

-- 注：一般来说，约束的处理比触发器快，因此在可能的时候，应该尽量使用约束。

-- 1.18.7 数据库安全
-- 安全性使用 SQL 的 GRANT 和 REVOKE 语句来管理。
-- 常见措施：
-- （1）对数据库管理功能（创建表、更改或删除已存在的表等）的访问；
-- （2）对特定数据库或表的访问；
-- （3）访问的类型（只读、对特定列的访问等）；
-- （4）仅通过视图或存储过程对表进行访问；
-- （5）创建多层次的安全措施，从而允许多种基于登录的访问和控制；
-- （6）限制管理用户账号的能力。














































