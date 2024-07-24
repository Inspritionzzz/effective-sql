-- 授权schema
grant select on schema::matchseat to dwchaxun;

if db_id('testdb') is null
  create database testdb;
go

use testdb;

-- 尽量以分号结尾;
-- 指定架构;
if object_id('dbo.employees', 'u') is not null
    drop table dbo.employees;
create table dbo.employees
(
  empid     int         not null,
  firstname varchar(30) not null,
  lastname  varchar(30) not null,
  hiredate  date        not null,
  mgrid     int         null,
  ssn       varchar(20) not null,
  salary    money       not null
);
-- 主键约束
alter table dbo.employees
  add constraint pk_employees
  primary key(empid);

-- 唯一约束
alter table dbo.employees
  add constraint unq_employees_ssn
  unique(ssn);
-- 外键约束
if object_id('dbo.orders', 'u') is not null
  drop table dbo.orders;

create table dbo.orders
(
  orderid   int         not null,
  empid     int         not null,
  custid    varchar(10) not null,
  orderts   datetime    not null,
  qty       int         not null,
  constraint pk_orders
    primary key(orderid)
);
-- on delete和on update可以设置cascade、set default、set null选项
alter table dbo.orders
  add constraint fk_orders_employees
  foreign key(empid)
  references dbo.employees(empid);

alter table dbo.employees
  add constraint fk_employees_employees
  foreign key(mgrid)
  references employees(empid);
-- check
alter table dbo.employees
  add constraint chk_employees_salary
  check(salary > 0);
-- default
alter table dbo.orders
  add constraint dft_orders_orderts
  default(current_timestamp) for orderts;
------------------------------------------------------------------------------------------------------------------------
-- 2.1 执行顺序:from、where、group by、having、select、order by
select empid, year(orderdate) as orderyear, count(*) as numorders
from sales.orders
where custid = 71
group by empid, year(orderdate)
having count(*) > 1
order by empid, orderyear;

-- 2.1.1 from
-- SQL Server分割标识符使用[],标识符包含空格、特殊字符、数字开头、SQL Server保留字;ANSI SQL使用双引号
select orderid, custid, empid, orderdate, freight
from sales.orders;

-- 2.1.2 where
-- T-SQL使用的时三值谓词逻辑:true false unknown
select orderid, empid, orderdate, freight
from sales.orders
where custid = 71;

-- 2.1.3 group by
select empid, year(orderdate) as orderyear
from sales.orders
where custid = 71
group by empid, year(orderdate);

-- 如果一个元素不在group by列表,就只能作为聚合函数的输入(count、sum、avg、min、max)
-- count(*)不会忽略null;count(distinct *)
select empid,year(orderdate) as orderyear,sum(freight) as totalfreight,count(*) as numorders
from sales.orders
where custid = 71
group by empid, year(orderdate);

select empid,year(orderdate) as orderyear,count(distinct custid) as numcusts
from sales.orders
group by empid, year(orderdate);

-- 2.1.4 having子句
select empid, year(orderdate) as orderyear, count(*) as numorders
from sales.orders
where custid = 71
group by empid, year(orderdate)
having count(*) > 1;

-- 2.1.5 select子句
/*  查询结果集的列可以没有列名,但是这样就不满足关系模型,因此建议为调用函数得出的结果集设定列名;
    <表达式> as <别名>,<别名> = <表达式>,<表达式> <别名> (不建议！)
    注意：1 查询两个列时如果忘记加','则会当成别名处理;
         2  select最后执行,因此不能在where、having、group by中使用select定义的别名
         3  不要用select *,需要指明需要查询的列,因为select *是根据create table时的列进行查询,如果后来删除、添加、修改了列,
            会导致查询失效;
*/

select current_timestamp,getdate(),
       year(getdate()) as year,month(getdate()) as month,
       thisyear = year(getdate()),year(getdate()) this_year;

select empid, year(orderdate) as orderyear, count(*) as numorders
from sales.orders
where custid = 71
group by empid, year(orderdate)
having count(*) > 1;

-- distinct
select distinct empid, year(orderdate) as orderyear
from sales.orders
where custid = 71;

-- 别名同样不能直接用于select
/*
select orderid,
  year(orderdate) as orderyear,
  orderyear + 1 as nextyear
from sales.orders;
*/

select orderid,
  year(orderdate) as orderyear,
  year(orderdate) + 1 as nextyear
from sales.orders;

-- 2.1.6 order by子句:order by返回游标,但SQL的某些语言元素和运算预期(例如表表达式和集合运算)支队查询的表结果进行处理
--                   order by可以引用别名,可以引用select中未返回的列,默认ASC
select empid, year(orderdate) as orderyear, count(*) as numorders
from sales.orders
where custid = 71
group by empid, year(orderdate)
having count(*) > 1
order by empid, orderyear;

-- order by支持引用select列的位置序号,但是不建议使用！
select empid, year(orderdate) as orderyear, count(*) as numorders
from sales.orders
where custid = 71
group by empid, year(orderdate)
having count(*) > 1
order by 2, 1;

-- 如果使用了distinct,order by引用在select列表出现的那些元素
/*
select distinct(country),title
from hr.employees
order by country,address;
*/

-- 2.1.7 top选项：在select阶段执行,在distinct之后
select top (5) orderid, orderdate, custid, empid
from sales.orders
order by orderdate desc;

-- top百分比查询(此时order by的查询不具有唯一性)
select top (1) percent orderid, orderdate, custid, empid
from sales.orders
order by orderdate desc;

select top (5) orderid, orderdate, custid, empid
from sales.orders
order by orderdate desc, orderid desc;

-- with ties
select top (5) with ties orderid, orderdate, custid, empid
from sales.orders
order by orderdate desc;

-- 2.1.8 over子句:开窗函数,操作对象是行的集合,只有在from、order by阶段才允许使用over子句;
--                在保留基本行信息的同时聚合行数据;
--                开窗函数在distinct之前进行处理;
select orderid, custid, val,
sum(val) over() as totalvalue,
sum(val) over(partition by custid) as custtotalvalue
from sales.ordervalues;

-- 100.?
select orderid, custid, val,
100. * val / sum(val) over() as pctall,
100. * val / sum(val) over(partition by custid) as pctcust
from sales.ordervalues;

-- over支持排名函数:ntitle依赖于row_number(),如果分组有余数,余数则会添加到前面过的组,例如102行分成5组,则前两组会有21行
select orderid, custid, val,
row_number() over(order by val) as rownum,
rank()       over(order by val) as rank,
dense_rank() over(order by val) as dense_rank,
ntile(10)   over(order by val) as ntile
from sales.ordervalues
order by val;

-- 使用partition by进行分组排名
select orderid, custid, val,
row_number() over(partition by custid order by val) as rownum
from sales.ordervalues
order by custid, val;

-- 开窗函数在distinct之前执行,group by在select之前(开窗函数)执行,因此使用row_number()后没必要在使用distinct
select distinct val, row_number() over(order by val) as rownum
from sales.ordervalues;

select val, row_number() over(order by val) as rownum
from sales.ordervalues
group by val;

-- 2.2 谓词和运算符
-- in
select orderid, empid, orderdate
from sales.orders
where orderid in(10248, 10249, 10250);

-- between
select orderid, empid, orderdate
from sales.orders
where orderid between 10300 and 10310;

-- like(N 代表national,表示字符串是Unicode数据类型(NCHAR和NVARCHAR)即(CHAR和VARCHAR))
select empid, firstname, lastname
from hr.employees
where lastname like N'D%';

-- 运算符(=、>、<、>=、<=、<>、!=、!>、!<)最后三个是非标准的,建议不适用！
select orderid, empid, orderdate
from sales.orders
where orderdate >= '20080101';

-- 逻辑运算符:and not or
select orderid, empid, orderdate
from sales.orders
where orderdate >= '20080101'
and empid in(1, 3, 5);

-- 算数运算符: +, -, *, /, %
select orderid, productid, qty, unitprice, discount,
    qty * unitprice * (1 - discount) as val
from sales.orderdetails;

-- 两个int相除结果还是整数,如果变成小数需要加 .
declare @a int,@b int
select @a = 10,@b = 3
select 10 / 3,10. / 3,
       @a / @b,cast(@a as numeric(12,2)) / cast(@b as numeric(12,2));

-- 优先级(建议使用圆括号！)
-- and的优先级比or的优先级高
select orderid, custid, empid, orderdate
from sales.orders
where custid = 1 and empid in(1, 3, 5) or custid = 85 and empid in(2, 4, 6);

select orderid, custid, empid, orderdate
from sales.orders
where (custid = 1 and empid in(1, 3, 5))
    or
      (custid = 85 and empid in(2, 4, 6));

-- 2.3 case表达式
select productid, productname, categoryid,
  case categoryid
    when 1 then 'beverages'
    when 2 then 'condiments'
    when 3 then 'confections'
    when 4 then 'dairy products'
    when 5 then 'grains/cereals'
    when 6 then 'meat/poultry'
    when 7 then 'produce'
    when 8 then 'seafood'
    else 'unknown category'
  end as categoryname
from production.products;

select orderid, custid, val,
  case ntile(3) over(order by val)
    when 1 then 'low'
    when 2 then 'medium'
    when 3 then 'high'
    else 'unknown'
  end as titledesc,
  ntile(3) over(order by val)
from sales.ordervalues
order by val;

select orderid, custid, val,
  case
    when val < 1000.00                   then 'less then 1000'
    when val between 1000.00 and 3000.00 then 'between 1000 and 3000'
    when val > 3000.00                   then 'more than 3000'
    else 'unknown'
  end as valuecategory
from sales.ordervalues;

-- 2.4 NULL值:使用运算符与NULL比较均为unknown,过滤语句只接受true,用is null和is not null取代 = null和<> null
--            group by和order by认为两null相等
select custid, country, region, city
from sales.customers
where region = N'WA';

select custid, country, region, city
from sales.customers
where region <> N'WA';

select custid, country, region, city
from sales.customers
where region = null;

select custid, country, region, city
from sales.customers
where region is null;

select custid, country, region, city
from sales.customers
where region <> N'WA'
   or region is null;

-- 2.5 同时操作
/*
select orderid,year(orderdate) as orderyear,orderyear + 1 as nextyear
from sales.orders;
*/

/*  这种排除除数为0的方法错误:SQL Server的策略并不是短路求值,而是基于代价估计做出决定;
select col1, col2
from dbo.t1
where col1 <> 0 and col2 / col1 > 2;
*/

/*
select col1, col2
from dbo.t1
where
  case
    when col1 = 0 then 'no' -- or 'yes' if row should be returned
    when col2 / col1 > 2 then 'yes'
    else 'no'
  end = 'yes';
*/

/* 推荐写法
select col1, col2
from dbo.t1
where col1 <> 0 and col2 > 2*col1;
*/

-- 2.6 处理字符数据
-- 2.6.1 数据类型:普通字符(char、varchar)(一个字符一字节)和Unicode字符(nchar、nvchar)(一个字符俩字节);
--       varchar(25)最多支持25个字符,存储空间由实际长而定,适合读多写少的表;char(25)存储空间固定,适合写多的表;
-- 2.6.2 排序规则
-- 查询排序规则及描述:CI-不区分大小写;AS-区分重音;
-- 单引号用于分隔文字字符串,双引号用于分隔不规则的标识符！通过QUOTED_IDENTIFIER设置
-- 如果要表示abc'de应该写成'abc''de'
select name,description from sys.fn_helpcollations();
-- 不区分大小写
select empid, firstname, lastname
from hr.employees
-- where lastname collate latin1_general_ci_as = N'davis';
where lastname = N'davis';

-- 区分大小写
select empid, firstname, lastname
from hr.employees
where lastname collate latin1_general_cs_as = N'davis';
-- 2.6.3 运算符和函数
-- 字符串串联操作
select empid, firstname + N' ' + lastname as fullname
from hr.employees;
-- 如果为null,串联后还是null
select custid, country, region, city,
  country + N',' + region + N',' + city as location
from sales.customers;

-- 串联操作作为空字符串进行操作,不建议修改数据库的配置进行处理,建议使用编程的方式实现！
set concat_null_yields_null off;

set concat_null_yields_null on;

-- coalesce接收一列输入值,返回其中第一个不为null的值
select custid, country, region, city,
  country + N',' + coalesce(region, N'') + N',' + city as location
from sales.customers;

-- 一些常用的字符串处理函数:substring、left、right、len、charindex、patindex、replicate、stuff、upper、lower、rtrim、ltrim
select substring('abcde',1,3);
select right('abcde',3),left('abcde',3)

select len(N'abcde') -- 返回字符数,不包含尾随空格
select datalength(N'abcde') -- 返回字节数,包含尾随空格

select charindex(' ','itzik ben-gan') -- 查找第一个空格的位置
select charindex(' ','itzik ben-gan',7) -- 查找第一个空格的位置,从第7个位置查找空格,找不到返回0

select patindex('%[0-9]%', 'abcd123efgh'); -- 查找第一次出现数字的位置

select replace('1-a 2-b','-',':') -- 用:替换-
-- 统计e出现的次数
select empid, lastname,
  len(lastname) - len(replace(lastname, 'e', '')) as numoccur
from hr.employees;
-- 复制字符串
select replicate('abc',3);
-- 把0复制9次,串联supplierid,然后取后10位
select supplierid,
  right(replicate('0', 9) + cast(supplierid as varchar(10)),10) as strsupplierid
from production.suppliers;

-- 对'xyz'从第2个位置删除1个指定长度的字符,然后用'abc'进行填充
select stuff('xyz', 2, 1, 'abc'); -- 'xabcz'
select upper('itzik ben-gan');
select lower('ITZIK BEN-GAN');
select rtrim(ltrim(' abc ')); --删除前导空格和尾随空格

-- 2.6.4 like
-- 以d开头
select empid, lastname
from hr.employees
where lastname like N'd%';
-- 第二个位置为e
select empid, lastname
from hr.employees
where lastname like N'_e%';

-- 以a或b或c开头的字符串
select empid, lastname
from hr.employees
where lastname like N'[abc]%';
-- 返回a - e范围内开头的字符串
select empid, lastname
from hr.employees
where lastname like N'[a-e]%';

-- 返回不是以a - e范围开头的字符串
select empid, lastname
from hr.employees
where lastname like N'[^a-e]%';

-- 特殊字符(%,_,[,])
-- col1 like '%!_%' escape '!' -- 使用escape指定转义字符
-- col1 like '%[_]%' -- 使用方括号(%,_,[),不适用于']'

-- 2.7.1 日期和时间数据
-- 2.7.2 字符串文字:SQL Server并没有提供表达日期和时间字符串的具体方法,而是将字符串文字显示或隐式的转换成相应的日期和
--                  时间数据类型,应当把使用字符串表示日期和时间作为一种最佳实践！
select orderid, custid, empid, orderdate
from sales.orders
where orderdate = '20070212';

-- 上面的查询等价于(隐式转换):在这里字符串的优先级低于日期和时间数据类型;
select orderid, custid, empid, orderdate
from sales.orders
where orderdate = cast('20070212' as datetime);

-- 对于select 日期和时间: 1 输入给数据库(可设置有效语言选择解析方式,不同的语言对日期和时间的字符串解析方式不同);
--                       2 利用客户端输出(如OLEDB和ODBC都是按照'YYYY-MM-DD hh:mm:ss:nnn'的格式输出datetime的值);
-- 设置会话中的有效语言,下面两种语言就会把'02/12/2007'字符串解析成不同的日期！
-- 不建议修改默认语言,并使用语言无关的字符串写法！

set language british; -- 设置dataformat为dmy
select cast('02/12/2007' as datetime);

set language us_english; -- 设置dataformat为mdy
select cast('02/12/2007' as datetime);

-- 对于日期和时间格式输出强烈建议按照语言无关的方式编写日期和时间字符串文字！这些写法语言无关,建议使用！
-- datetime:使用字符串格式语言无关
-- smalldatetime:使用字符转格式语言无关
-- date:'YYYYMMDD'    'YYYY-MM-DD'
-- datetime2:'YYYYMMDD hh:mm:ss.nnnnnnn'    'YYYY-MM-DD hh:mm:ss.nnnnnnn'   'YYYY-MM-DDThh:mm:ss.nnnnnnn'
--           'YYYYMMDD'    'YYYY-MM-DD'
-- datetimeoffset:'YYYYMMDD hh:mm:ss.nnnnnnn[+|-]hh:mm'    'YYYY-MM-DDThh:mm:ss.nnnnnnn[+|-]hh:mm'
--           'YYYYMMDD'    'YYYY-MM-DD'
-- time:'hh:mm:ss.nnnnnnn'
set language british;
select cast('20070212' as datetime);

set language us_english;
select cast('20070212' as datetime);

-- 如果坚持使用语言格式相关的格式表示日期和时间,可以使用convert函数！
select convert(datetime, '02/12/2007', 101);

select convert(datetime, '02/12/2007', 103);
-- 2.7.3 单独使用日期和时间
-- 当把字符串文字转换成datetime类型如果没指定时间,则默认使用00:00:00作为其时间值;
select orderid, custid, empid, orderdate
from sales.orders
where orderdate = '20070212';

select orderid, custid, empid, orderdate
from sales.orders
where orderdate >= '20070212'
  and orderdate < '20070213';

-- 默认使用基础日期1900-01-01
select cast('12:30:15.123' as datetime);

-- 2.7.4 过滤日期范围
-- 如果对过滤条件应用了一定的处理后,就不能有效的的使用索引了！
select orderid, custid, empid, orderdate
from sales.orders
where year(orderdate) = 2007;

-- 更建议！
select orderid, custid, empid, orderdate
from sales.orders
where orderdate >= '20070101' and orderdate < '20080101';
-- 对于月份同理
select orderid, custid, empid, orderdate
from sales.orders
where year(orderdate) = 2007 and month(orderdate) = 2;
-- 更建议！
select orderid, custid, empid, orderdate
from sales.orders
where orderdate >= '20070201' and orderdate < '20070301';

-- 2.7.5 日期和时间函数
-- 日期和时间函数(推荐使用current_timestamp！)
select
  getdate()           as [getdate],
  current_timestamp   as [current_timestamp],
  getutcdate()        as [getutcdate],
  sysdatetime()       as [sysdatetime],
  sysutcdatetime()    as [sysutcdatetime],
  sysdatetimeoffset() as [sysdatetimeoffset];

-- 只返回日期或时间
select
  cast(sysdatetime() as date) as [current_date],
  cast(sysdatetime() as time) as [current_time];
-- cast and convert(date和time是SQL Server2008新引入的)
select cast('20090212' as date);
select cast(sysdatetime() as date);
select cast(sysdatetime() as time);

-- 112
select convert(char(8), current_timestamp, 112);
select cast(convert(char(8), current_timestamp, 112) as datetime);
-- 114
select convert(char(12), current_timestamp, 114);
select cast(convert(char(12), current_timestamp, 114) as datetime);

-- switchoffset
select switchoffset(sysdatetimeoffset(), '-05:00');
select switchoffset(sysdatetimeoffset(), '+00:00'); -- 将当前的datetimeoffset调整为UTC时间
-- todatetimeoffset
select todatetimeoffset(sysdatetimeoffset(), '-05:00');
select todatetimeoffset(sysdatetime(), '-05:00');
-- dateadd
select dateadd(year, 1, '20090212');
-- datediff
select datediff(day, '20080212', '20090212');

-- 将当前系统日期和时间值 中的时间部分设置为午夜(2008之前)
select dateadd(day,datediff(day, '20010101', current_timestamp), '20010101');
-- 当月第一天(锚点要使用某月的第一天)
select dateadd(month,datediff(month, '20010101', current_timestamp), '20010101');
-- 当年的第一天(锚点要使用某年第一天)
select dateadd(year,datediff(year, '20010101', current_timestamp), '20010101');
-- 当月最后一天(锚点要使用某月最后一天)
select dateadd(month,datediff(month, '20091231', current_timestamp), '20091231');
-- 当年最后一天(锚点要使用某年最后一天)
select dateadd(year,datediff(year, '20091231', current_timestamp), '20091231');

-- datepart
select datepart(month, '20090212');
-- day, month, year函数
select
  day('20090212') as theday,
  month('20090212') as themonth,
  year('20090212') as theyear;
-- datename(与datepart类似,此函数返回日期的名称,依赖于语言,如果当前会话使用的是us_english,则月份返回February)
select datename(month, '20090212');
select datename(year, '20090212');
-- isdate(判断能否将字符串转化为日期和时间的数据类型)
select isdate('20090212');
select isdate('20090230');

-- 2.8 查询元数据(SQL Server联机丛书)
-- 2.8.1 目录视图(查询sys.table视图返回表和架构名称)
select schema_name(schema_id) as table_schema_name, name as table_name
from sys.tables;
-- 查询某个表的列信息(返回列名、数据类型、最大长度、排序规则名称、是否允许为NULL)
select
  name as column_name,
  type_name(system_type_id) as column_type,
  max_length,
  collation_name,
  is_nullable
from sys.columns
where object_id = object_id(N'sales.orders');
-- 2.8.2 信息架构视图
-- 列出用户表及它们的架构名称
select table_schema, table_name
from information_schema.tables
where table_type = N'base table';
-- 查询某个表的列信息
select
  column_name, data_type, character_maximum_length,
  collation_name, is_nullable
from information_schema.columns
where table_schema = N'sales'
  and table_name = N'orders';
-- 2.8.3 系统存储过程和函数
-- 返回可以在当前数据库查询的对象(表和视图)列表(sys架构是SQL Server2005中引入,在此之前存储过程位于dbo架构内)
exec sys.sp_tables;
-- 返回某个表的详细信息(列、索引、约束等)
exec sys.sp_help
    @objname = N'Sales.Orders';
-- 返回对象有关列的信息
exec sys.sp_columns
  @table_name = N'orders',
  @table_owner = N'sales';
-- 返回对象的约束信息
exec sys.sp_helpconstraint
  @objname = N'sales.orders';
-- 返回数据库实体的各属性信息;
-- 返回当前数据库实体(如SQL Server实例、数据库、对象、列等)的各属性信息,如版本级别(RTM,SP1,SP2);
select serverproperty('productlevel');
-- 返回当前数据库实例的特定属性信息,如排序规则;
select databasepropertyex(N'testdb', 'collation')
-- 返回指定对象的特定属性的信息,如orders表是否具有主键;嵌入object_id()读取对象的ID;
select objectproperty(object_id(N'sales.orders'), 'tablehasprimarykey');
-- 返回指定列上的特定属性信息,如Orders表的shipcountry列是否可以为NULL;
select columnproperty(object_id(N'sales.orders'), N'shipcountry', 'allowsnull');

-- 2.9 练习

-- 3 联接查询
-- 有join、apply、pivot、unpivot四种表运算符,这部分只介绍join;
-- join有三种基本类型:交叉连接(笛卡尔积)、内连接(笛卡尔积 —— 过滤)、外连接(笛卡尔积 —— 过滤 —— 添加外部行);

-- 3.1 交叉联接
-- ansi sql-92
-- 如果使用了别名就无法使用表的全名作为列名前缀;
select c.custid, e.empid
from sales.customers as c
cross join hr.employees as e;

-- ansi sql-89(旧语法,不推荐！)
select c.custid, e.empid
from sales.customers as c, hr.employees as e;
-- 自交叉联结(三种基本连接的类型都能进行交叉联接,需要指定别名)
select
  e1.empid, e1.firstname, e1.lastname,
  e2.empid, e2.firstname, e2.lastname
from hr.employees as e1
  cross join hr.employees as e2;

-- 生成数字表
if object_id('dbo.digits', 'u') is not null drop table dbo.digits;
create table dbo.digits(digit int not null primary key);

insert into dbo.digits(digit)
  values (0),(1),(2),(3),(4),(5),(6),(7),(8),(9);

/*
note:
above insert syntax is new in microsoft sql server 2008.
in earlier versions use:

insert into dbo.digits(digit) values(0);
insert into dbo.digits(digit) values(1);
insert into dbo.digits(digit) values(2);
insert into dbo.digits(digit) values(3);
insert into dbo.digits(digit) values(4);
insert into dbo.digits(digit) values(5);
insert into dbo.digits(digit) values(6);
insert into dbo.digits(digit) values(7);
insert into dbo.digits(digit) values(8);
insert into dbo.digits(digit) values(9);
*/

-- 利用自交叉联接生成数字表(666)
select d3.digit * 100 + d2.digit * 10 + d1.digit + 1 as n
from dbo.digits as d1
cross join dbo.digits as d2
cross join dbo.digits as d3
order by n;

--3.2 内联接
-- ansi sql-92
-- on语句的过滤只返回谓词结果为true的行;
select e.empid, e.firstname, e.lastname, o.orderid
from hr.employees as e
join sales.orders as o on e.empid = o.empid;

-- ansi sql-89(老语法,容易漏掉条件,不推荐！)
select e.empid, e.firstname, e.lastname, o.orderid
from hr.employees as e, sales.orders as o
where e.empid = o.empid;

-- 3.3 特殊的联接实例(组合联接、不等联接、多表联接)
-- 建立客户审核表;
if object_id('sales.orderdetailsaudit', 'u') is not null
  drop table sales.orderdetailsaudit;
create table sales.orderdetailsaudit
(
  lsn        int not null identity,
  orderid    int not null,
  productid  int not null,
  dt         datetime not null,
  loginname  sysname not null,
  columnname sysname not null,
  oldval     sql_variant,
  newval     sql_variant,
  constraint pk_orderdetailsaudit primary key(lsn),
  constraint fk_orderdetailsaudit_orderdetails
    foreign key(orderid, productid)
    references sales.orderdetails(orderid, productid)
);
-- 3.3.1 组合联接
select od.orderid, od.productid, od.qty,oda.dt, oda.loginname, oda.oldval, oda.newval
from sales.orderdetails as od
join sales.orderdetailsaudit as oda on od.orderid = oda.orderid and od.productid = oda.productid
where oda.columnname = N'qty';

-- 3.3.2 不等联接
-- 生成雇员之间的匹配(不考虑顺序)
select
  e1.empid, e1.firstname, e1.lastname,
  e2.empid, e2.firstname, e2.lastname
from hr.employees as e1
join hr.employees as e2 on e1.empid < e2.empid;

-- 3.3.3 多表联接
select
  c.custid, c.companyname, o.orderid,
  od.productid, od.qty
from sales.customers as c
join sales.orders as o on c.custid = o.custid
join sales.orderdetails as od on o.orderid = od.orderid;

-- 3.4 外联接(left outer join、right outer join、full outer join)
-- 3.4.1 外联接:on子句过滤掉后然后把外部行(对应内部行)添加上,即on不是最终过滤条件; where在from之后执行;
select c.custid, c.companyname, o.orderid
from sales.customers as c
left outer join sales.orders as o on c.custid = o.custid;

select c.custid, c.companyname
from sales.customers as c
left outer join sales.orders as o on c.custid = o.custid
where o.orderid is null;

-- 3.4.2 外联接高级主题
-- 输出20060101 - 20081231间的全部日期
set nocount on;
use testdb;
if object_id('dbo.Nums', 'u') is not null drop table dbo.Nums;
create table dbo.nums(n int not null primary key);
declare @i as int = 1;

/*
SQL Server2008之前申明变量的用法:
declare @i as int;
set @i = 1;
*/
begin tran
  while @i <= 100000
  begin
    insert into dbo.nums values(@i);
    set @i = @i + 1;
  end
commit tran
set nocount off;
go
-- 计算20060101 - 20081231之间的所有日期值(666)
select dateadd(day, n - 1, '20060101') as orderdate -- 返回20060101加上n-1天后的日期
from dbo.nums
where n <= datediff(day, '20060101', '20081231') + 1 -- 返回两个日期差;
order by orderdate;
-- 通过外联接计算20060101 - 20081231之间每天下订单的情况;
select dateadd(day, nums.n - 1, '20060101') as orderdate,o.orderid, o.custid, o.empid
from dbo.nums
left outer join sales.orders as o on dateadd(day, nums.n - 1, '20060101') = o.orderdate
where nums.n <= datediff(day, '20060101', '20081231') + 1
order by orderdate;

-- 注意:使用外联接时,用where子句对外部行进行了过滤,外部行在orderdate列的取值都为NULL,因此过滤掉了所有的外部行;
select c.custid, c.companyname, o.orderid, o.orderdate
from sales.customers as c
left outer join sales.orders as o on c.custid = o.custid
where o.orderdate >= '20070101';

-- 注意:多表联接时如果涉及内连接和外联接,顺序不同会导致结果不同;
-- 后使用的内联接抵消了外连接;
select c.custid, o.orderid, od.productid, od.qty
from sales.customers as c
left outer join sales.orders as o on c.custid = o.custid
join sales.orderdetails as od on o.orderid = od.orderid;
-- 为解决上面的问题,第一种方案:都是用左外联接;
select c.custid, o.orderid, od.productid, od.qty
from sales.customers as c
left outer join sales.orders as o on c.custid = o.custid
left outer join sales.orderdetails as od on o.orderid = od.orderid;
-- 第二种方案:先使用内联接在使用右外联接;
select c.custid, o.orderid, od.productid, od.qty
from sales.orders as o join sales.orderdetails as od on o.orderid = od.orderid
right outer join sales.customers as c on o.custid = c.custid;
-- 第三种方案:使用()改变联接顺序;
select c.custid, o.orderid, od.productid, od.qty
from sales.customers as c
left outer join
(sales.orders as o join sales.orderdetails as od on o.orderid = od.orderid) on c.custid = o.custid;

-- count(*)会把外部行也统计上;
select c.custid, count(*) as numorders
from sales.customers as c left outer join sales.orders as o on c.custid = o.custid
group by c.custid;
-- 使用count(<coulumn>)从非保留表中选择一列,这样count()函数在统计时就会忽略外部行;
select c.custid, count(o.orderid) as numorders
from sales.customers as c left outer join sales.orders as o on c.custid = o.custid
group by c.custid;

-- 4 子查询
use testdb;
-- 4.1.1 独立标量子查询;
-- 返回最大orderid的订单信息;
declare @maxid as int = (select max(orderid) from sales.orders);
select orderid, orderdate, empid, custid
from sales.orders
where orderid = @maxid;

select orderid, orderdate, empid, custid
from sales.orders
where orderid = (select max(o.orderid) from sales.orders as o);

-- 4.1.2 独立多值子查询;
-- 注意:子查询返回多个值的时候会出错！
select orderid
from sales.orders
where empid = (select e.empid from hr.employees as e
               where e.lastname like N'D%');
-- 使用联接查询还是子查询:
select orderid
from sales.orders
where empid in (select e.empid from hr.employees as e
                where e.lastname like N'd%');

select o.orderid
from hr.employees as e
join sales.orders as o on e.empid = o.empid
where e.lastname like N'd%';

select custid, orderid, orderdate, empid
from sales.orders
where custid in(select c.custid from sales.customers as c
                where c.country = N'usa');
select custid, companyname
from sales.customers
where custid not in (select o.custid from sales.orders as o);

-- 创建Orders2表并插入Orders中orderid为偶数的行数据;
use testdb;
if object_id('dbo.Orders2') is not null drop table dbo.orders2;
go
select * into dbo.Orders2
from testdb.sales.orders
where orderid % 2 = 0;

select n
from dbo.nums
where n between (select min(o.orderid) from sales.orders as o)
        and (select max(o.orderid) from sales.orders as o)
        and n not in (select o.orderid from dbo.orders2 as o);

-- 4.2 相关子查询
-- 查询每个客户最大订单号的相关信息;
select custid, orderid, orderdate, empid
from sales.orders as o1
where orderid = (select max(o2.orderid) from sales.orders as o2
                 where o2.custid = o1.custid);
-- 查询每个客户每个定单的数额比率(占该客户总下单数额)
select orderid, custid, val,
  cast(100. * val / (select sum(o2.val) from sales.ordervalues as o2 where o2.custid = o1.custid) as numeric(5,2)) as pct
from sales.ordervalues as o1
order by custid, orderid;

-- exists
-- 返回下过订单的西班牙客户;
select custid, companyname,c.country
from sales.customers as c
where country = N'spain' and exists (select * from sales.orders as o
                                     where o.custid = c.custid);

-- not exists
-- 注意:这里exists (select * ...)的是最佳实践,比exists (select 1 ...)有更好的可读性!
select custid, companyname
from sales.customers as c
where country = N'spain' and not exists (select * from sales.orders as o
                                         where o.custid = c.custid);
-- 4.3 高级子查询
-- 4.3.1 返回前一个或者后一个记录:集合并没有前一个和后一个的概念,因此要写出一个"前一个"概念的逻辑等式;
select orderid, orderdate, empid, custid,
  (select max(o2.orderid)
   from sales.orders as o2
   where o2.orderid < o1.orderid) as prevorderid
from sales.orders as o1;
-- 4.3.2 返回每个订单的下一个订单ID;
select orderid, orderdate, empid, custid,
  (select min(o2.orderid)
   from sales.orders as o2
   where o2.orderid > o1.orderid) as nextorderid
from sales.orders as o1;
-- 4.3.3 连续聚合
select orderyear, qty
from sales.ordertotalsbyyear;

select orderyear, qty,
  (select sum(o2.qty)
   from sales.ordertotalsbyyear as o2
   where o2.orderyear <= o1.orderyear) as runqty
from sales.ordertotalsbyyear as o1
order by orderyear;
-- 4.3.4 行为不当的子查询
-- 查询没有下过订单的用户;
select custid, companyname
from sales.customers as c
where custid not in(select o.custid from sales.orders as o);

-- 向订单表插入一个custid为null的值,再次执行上述查询,返回0行数据;
-- 解决:1 建表时对该列使用not null
--      2 显示排除null值
--      3 使用exists隐式排除
insert into sales.orders
  (custid, empid, orderdate, requireddate, shippeddate, shipperid,
   freight, shipname, shipaddress, shipcity, shipregion,
   shippostalcode, shipcountry)
  values(null, 1, '20090212', '20090212',
         '20090212', 1, 123.00, N'abc', N'abc', N'abc',
         N'abc', N'abc', N'abc');
-- 使用not in时显示排除null;
select custid, companyname
from sales.customers as c
where custid not in(select o.custid
                    from sales.orders as o
                    where o.custid is not null);
-- 使用exists隐式排除;
select custid, companyname
from sales.customers as c
where not exists(select * from sales.orders as o where o.custid = c.custid);

-- 子查询列名中的替换错误;
if object_id('sales.myshippers', 'u') is not null
  drop table sales.myshippers;

create table sales.myshippers
(
  shipper_id  int          not null,
  companyname nvarchar(40) not null,
  phone       nvarchar(24) not null,
  constraint pk_myshippers primary key(shipper_id)
);
insert into sales.myshippers(shipper_id, companyname, phone)
  values(1, N'shipper gvsua', N'(503) 555-0137');
insert into sales.myshippers(shipper_id, companyname, phone)
  values(2, N'shipper etynr', N'(425) 555-0136');
insert into sales.myshippers(shipper_id, companyname, phone)
  values(3, N'shipper zhisn', N'(415) 555-0138');

-- shipper_id在sales.orders并不存在,实际执行时,若在子查询中找不到这个列,则在外部表中寻找这个列;
select shipperid from sales.orders where custid = 43;
-- 解决方案:1 建表时根据含义统一列名;
--          2 在子查询中select的列一定要使用别名(最佳实践)！
select shipper_id, companyname
from sales.myshippers
where shipper_id in(select shipper_id from sales.orders where custid = 43); -- 本应返回2 3,这里返回 1 2 3;

-- bug corrected
select shipper_id, companyname
from sales.myshippers
where shipper_id in(select o.shipperid from sales.orders as o where o.custid = 43);

-- 5 表表达式:表表达式、CTE、视图、apply
-- 5.1 派生表
-- 5.1.1 派生表一个简单的例子:(1)不保证有一定的顺序;(2)所有的列必须有名称;(3)所有的列名必须是唯一的;
select * from (select custid, companyname
               from sales.customers
               where country = N'usa') as usacusts;
-- 5.1.2 group by先于select执行,所以根据别名order by无效;
-- 执行顺序:select(5) from(1) where(2) group by(3) having(4) order by(6)
-- select year(orderdate) as orderyear,count(distinct custid) as numcusts
-- from sales.orders
-- group by orderyear;

--5.1.3  可以使用order by year(orderdate)解决问题,如果计算表达式很长的话,更建议使用表表达式(外部查询可以引用内部查询的列名);
select orderyear, count(distinct custid) as numcusts
from (select year(orderdate) as orderyear, custid
      from sales.orders) as d -- 内联别名格式,最佳实践!
group by orderyear;

-- 上述表表达式被解释称了下述查询逻辑,使用表表达式并不会对性能产生正面或者负面的影响;
select year(orderdate) as orderyear, count(distinct custid) as numcusts
from sales.orders
group by year(orderdate);

-- 另一种命名格式
select orderyear, count(distinct custid) as numcusts
from (select year(orderdate), custid
      from sales.orders) as d(orderyear, custid) --外联别名格式;
group by orderyear;

-- 5.1.4 使用参数
declare @empid as int = 3;
/*
-- SQL Server 2008之前的变量赋值写法;
declare @empid as int;
set @empid = 3;
*/
select orderyear, count(distinct custid) as numcusts
from (select year(orderdate) as orderyear, custid
      from sales.orders
      where empid = @empid) as d
group by orderyear;

-- 5.1.5 嵌套派生表
select orderyear, numcusts
from (select orderyear, count(distinct custid) as numcusts
      from (select year(orderdate) as orderyear, custid
            from sales.orders) as d1
      group by orderyear) as d2
where numcusts > 70;

-- 上述查询不使用嵌套的查询的方式;
select year(orderdate) as orderyear, count(distinct custid) as numcusts
from sales.orders
group by year(orderdate)
having count(distinct custid) > 70;

-- 由于不能引用同一派生表的多个实例,因而不得不维护同一查询定义的多个副本,这让代码更加复杂和冗长;
select cur.orderyear,
  cur.numcusts as curnumcusts, prv.numcusts as prvnumcusts,
  cur.numcusts - prv.numcusts as growth
from (select year(orderdate) as orderyear,
        count(distinct custid) as numcusts
      from sales.orders
      group by year(orderdate)) as cur --同一查询;
  left outer join
     (select year(orderdate) as orderyear,
        count(distinct custid) as numcusts -- 同一查询;
      from sales.orders
      group by year(orderdate)) as prv
    on cur.orderyear = prv.orderyear + 1;

-- 5.2 公用表表达式(CTE)
-- 5.2.1 一个基本样例:上句SQL必须使用';';
with usacusts as(select custid, companyname
                 from sales.customers
                 where country = N'usa')
select * from usacusts;
-- 5.2.2 CTE的内联格式
with c as(select year(orderdate) as orderyear, custid
          from sales.orders)
select orderyear, count(distinct custid) as numcusts
from c
group by orderyear;
-- 5.2.3 CTE的外联格式
with c(orderyear, custid) as(select year(orderdate), custid
                             from sales.orders)
select orderyear, count(distinct custid) as numcusts
from c
group by orderyear;

-- 5.2.4 在CTE中使用参数
declare @empid as int = 3;
/*
-- SQL Server2008之前的写法:
declare @empid as int;
set @empid = 3;
*/
with c as(select year(orderdate) as orderyear, custid
          from sales.orders
          where empid = @empid)
select orderyear, count(distinct custid) as numcusts
from c
group by orderyear;

-- 5.2.5 定义多个CTE:每个CTE可以引用在它前面定义的所有CTE;
-- CTE不能嵌套,一个圆括号只能定义一个CTE,CTE这种模块化的方法能大大提高代码的可读性和可维护性;
with c1 as(select year(orderdate) as orderyear, custid
           from sales.orders),
     c2 as(select orderyear, count(distinct custid) as numcusts
           from c1
           group by orderyear)
select orderyear, numcusts
from c2
where numcusts > 70;

-- 5.2.6 CTE的多引用:CTE是先定义再查询,这么做的优点是外部查询执行from子句时,CTE是已经存在的;
-- 以下样例在外部查询的from子句访问了两次(cur、prv),这样只需要维护一个CTE副本,不需要向派生表那样维护多个副本;
-- 表表达式通常对性能没有任何影响;
with yearlycount as(select year(orderdate) as orderyear,count(distinct custid) as numcusts
                    from sales.orders
                    group by year(orderdate))
select cur.orderyear,cur.numcusts as curnumcusts, prv.numcusts as prvnumcusts,cur.numcusts - prv.numcusts as growth
from yearlycount as cur
left outer join yearlycount as prv
on cur.orderyear = prv.orderyear + 1;
-- 5.2.7 递归CTE:返回雇员id为2的所有的下属;
-- 可在option(maxrecursion n)指定递归次数,SQL Server默认递归100次,在第101次终止查询,不限制的话万一递归出问题会导致tempdb体积过大;
with empscte as(select empid, mgrid, firstname, lastname
                from hr.employees
                where empid = 2
                    union all
                select c.empid, c.mgrid, c.firstname, c.lastname
                from empscte as p
                join hr.employees as c
                on c.mgrid = p.empid)
select empid, mgrid, firstname, lastname
from empscte;
-- 5.3 视图
-- 5.3.1 派生表和CTE都是不可重用的,视图和内联表值函数(inline TVF)是两种可重用的表表达式,他们的定义储存在一个数据库对象中,一旦创建就是数据库的永久部分;
-- 可以用权限控制对视图的访问,从而禁止对底层数据库对象的直接访问;
-- 注意:在视图中应尽量避免使用select *,因为新增加的列不会自动添加到视图中!虽然使用sp_refreshview存储过程可以刷新视图的元数据;
--      最佳实践是使用哪一列就在视图中写清楚!
-- 可以使用alter view对视图进行相应的修改;
if object_id('sales.UsaCusts') is not null
  drop view sales.usacusts;
go
create view sales.usacusts
as
select
  custid, companyname, contactname, contacttitle, address,
  city, region, postalcode, country, phone, fax
from sales.customers
where country = N'usa';

select custid, companyname
from sales.usacusts;
-- 5.3.2 视图和order by:创建有序视图的想法是错误的！
-- 以下试图创建有序视图的方法会报错！
-- alter view sales.usacusts
-- as
-- select
--   custid, companyname, contactname, contacttitle, address,
--   city, region, postalcode, country, phone, fax
-- from sales.customers
-- where country = N'usa'
-- order by region;
-- go

-- 只有在使用了TOP和FOR XML时才允许在视图中使用order by子句;
-- do not rely on top:返回给外部查询的数据仍可能是无序的,仍需要在外部表中使用order by;
alter view sales.usacusts
as

select top (100) percent
  custid, companyname, contactname, contacttitle, address,
  city, region, postalcode, country, phone, fax
from sales.customers
where country = N'usa'
order by region;
go

-- 5.3.3 视图选项
-- encryption选项
alter view sales.usacusts
as
select
  custid, companyname, contactname, contacttitle, address,
  city, region, postalcode, country, phone, fax
from sales.customers
where country = N'usa';
go
-- 使用object_definition()查看视图定义(创建语句),SQL Server2005新加的;
select object_definition(object_id('sales.usacusts'));
exec sp_helptext 'sales.usacusts'; -- 更早版本;
-- 使用encryption选项隐藏视图;
alter view sales.usacusts with encryption
as
select
  custid, companyname, contactname, contacttitle, address,
  city, region, postalcode, country, phone, fax
from sales.customers
where country = N'usa';
go

-- schemabinding选项
-- 使用schemabinding后不能修改被引用对象的列;
alter view sales.usacusts with schemabinding
as
select
  custid, companyname, contactname, contacttitle, address,
  city, region, postalcode, country, phone, fax
from sales.customers
where country = N'usa';
--执行失败;
alter table sales.customers drop column address;
go

-- check选项:设置只能通过视图更新满足视图条件的数据;
select * from sales.usacusts;
-- 通过视图更新表中的数据;
insert into sales.usacusts(
  companyname, contactname, contacttitle, address,
  city, region, postalcode, country, phone, fax)
 values(
  N'customer abcde', N'contact abcde', N'title abcde', N'address abcde',
  N'london', null, N'12345', N'uk', N'012-3456789', N'012-3456789');
select custid, companyname, country
from sales.usacusts
where companyname = N'customer abcde';

alter view sales.usacusts with schemabinding
as
select
  custid, companyname, contactname, contacttitle, address,
  city, region, postalcode, country, phone, fax
from sales.customers
where country = N'usa'
with check option; -- 添加check选项
go

select custid, companyname, country
from sales.customers
where companyname = N'customer abcde';

delete from sales.customers where custid > 91;
dbcc checkident('Sales.Customers', reseed, 91); -- ?
if object_id('sales.usacusts') is not null drop view sales.usacusts;

-- 5.4 内联表值函数:是一种可重用的表表达式,能够支持输入参数,可看作是一种参数化的视图;
if object_id('dbo.fn_getcustorders') is not null
  drop function dbo.fn_getcustorders;
go
create function dbo.fn_getcustorders
  (@cid as int) returns table
as
return
  select orderid, custid, empid, orderdate, requireddate,
    shippeddate, shipperid, freight, shipname, shipaddress, shipcity,
    shipregion, shippostalcode, shipcountry
  from sales.orders
  where custid = @cid;
go

select orderid, custid from dbo.fn_getcustorders(1) as co;
-- 内联表值函数可与其他表进行join操作;
select co.orderid, co.custid, od.productid, od.qty
from dbo.fn_getcustorders(1) as co
join sales.orderdetails as od on co.orderid = od.orderid;
-- 清理数据;
if object_id('dbo.fn_getcustorders') is not null
  drop function dbo.fn_getcustorders;
go

-- 5.5 apply运算符
-- cross apply和交叉联接的效果非常相似,不同的是cross apply的右表可以是派生表(可引用左表列),也可以是内联表值函数,把左表中的列作为输入参数进行传递;
select s.shipperid, e.empid
from sales.shippers as s
cross join hr.employees as e;

select s.shipperid, e.empid
from sales.shippers as s
cross apply hr.employees as e;

-- cross apply样例:右表是表表达式的情况,返回每个客户最新的三个订单;
select c.custid, a.orderid, a.orderdate
from sales.customers as c
cross apply
    (select top(3) orderid, empid, orderdate, requireddate
     from sales.orders as o
     where o.custid = c.custid
     order by orderdate desc, orderid desc) as a;
-- outer apply样例:使用cross apply时如果使用左表的联接条件 在右表没有找到行数据,则在最终结果不显示;
--                 使用outer apply可以把保留行添上(这里是custid = 57、custid = 22),类似left join;
select c.custid, a.orderid, a.orderdate
from sales.customers as c
outer apply
    (select top(3) orderid, empid, orderdate, requireddate
     from sales.orders as o
     where o.custid = c.custid
     order by orderdate desc, orderid desc) as a;

-- 使用内联表值函数替换派生表实现(666)
if object_id('dbo.fn_toporders') is not null
  drop function dbo.fn_toporders;
go
create function dbo.fn_toporders
  (@custid as int, @n as int)
  returns table
as
return
  select top(@n) orderid, empid, orderdate, requireddate
  from sales.orders
  where custid = @custid
  order by orderdate desc, orderid desc;
go

select
  c.custid, c.companyname,
  a.orderid, a.empid, a.orderdate, a.requireddate
from sales.customers as c
  cross apply dbo.fn_toporders(c.custid, 3) as a;

-- 6 集合运算:在两个结果集或者多个结果集之间进行的运算(union、intersect、except),因此各集合不能包含order by子句,因为order by返回的是游标而不是集合;
--           每个单独的查询可以包含所有逻辑查询处理阶段(除了order by阶段),参与集合运算的两个查询生成的结果集必须包含相同的列数;
--           并且各列具有兼容的数据类型(优先级较低的数据类型必须能隐式的转换成较高级的数据类型);
--           集合运算结果中的列名由第一个查询决定;
--           集合运算认为两个null值相等;
--           选项:distinct和all(仅限union,对于intersect和except有替代方法)
-- 6.1.1 union all:返回的是一个多集(有重复)
select country, region, city from hr.employees
union all
select country, region, city from sales.customers;
-- 6.1.2 union distinct:distinct可能发生在union之后
select country, region, city from hr.employees
union
select country, region, city from sales.customers;
-- 6.2.1 intersect distinct:返回集合的交集;
-- 返回既是雇员地址,也是客户地址的不同地址;
select country, region, city from hr.employees
intersect
select country, region, city from sales.customers;
-- 6.2.2 intersect all:交集可能出现多次,每出现一次都要展示出来,SQL Server2008还没这种运算,这里使用替代方案;
select row_number() over(partition by country, region, city order by (select 0)) as rownum,
       country, region, city
from hr.employees
intersect
select row_number() over(partition by country, region, city order by (select 0)),
       country, region, city
from sales.customers;
-- 6.2.3 intersect all(结果集不反回行号)
with intersect_all as(
  select row_number() over(partition by country, region, city order by (select 0)) as rownum,
         country, region, city
  from hr.employees
  intersect
  select row_number() over(partition by country, region, city order by (select 0)),
    country, region, city
  from sales.customers)
select country, region, city
from intersect_all;
-- 6.3 except:差集运算(A - B:在A中出现在B中不出现),默认两个null是相等的,这点与not exists不同;
-- 6.3.1 except distinct集合运算
-- 样例:返回属于雇员地址但不属于客户地址;
select country, region, city from hr.employees
except
select country, region, city from sales.customers;
-- 样例:返回属于客户地址但不属于雇员地址;
select country, region, city from sales.customers
except
select country, region, city from hr.employees;
-- 6.3.2 except all(A中x次,B中y次,结果集中x - y次)
with except_all as(
  select row_number() over(partition by country, region, city order by (select 0)) as rownum,
    country, region, city
    from hr.employees
  except
  select row_number() over(partition by country, region, city order by (select 0)),
    country, region, city
  from sales.customers)
select country, region, city
from except_all;

with except_all as(
  select row_number() over(partition by country, region, city order by (select 0)) as rownum,
    country, region, city
    from sales.customers
  except
  select row_number() over(partition by country, region, city order by (select 0)),
    country, region, city
  from hr.employees)
select country, region, city
from except_all;

-- 6.4 集合运算的优先级:intersect > union = except
-- 样例:是供应商地址,但不是(既是雇员地址也是客户地址);
select country, region, city from production.suppliers
except
select country, region, city from hr.employees
intersect
select country, region, city from sales.customers;
-- 样例:是供应商地址但不是雇员地址,是客户地址;
(select country, region, city from production.suppliers
 except
 select country, region, city from hr.employees)
intersect
select country, region, city from sales.customers;

-- 6.5 避开不支持的逻辑查询
-- 使用表表达式
select country, count(*) as numlocations
from (select country, region, city from hr.employees
      union
      select country, region, city from sales.customers) as u
group by country;
-- 使用表表达式和top
select empid, orderid, orderdate
from (select top (2) empid, orderid, orderdate
      from sales.orders
      where empid = 3
      order by orderdate desc, orderid desc) as d1
    union all
select empid, orderid, orderdate
from (select top (2) empid, orderid, orderdate
      from sales.orders
      where empid = 5
      order by orderdate desc, orderid desc) as d2;

-- 7 透视(行 --> 列)、逆透视(列 --> 行)及分组集(pivoting、unpivoting、grouping set)
if object_id('dbo.orders3', 'u') is not null drop table dbo.orders;
go
create table dbo.orders3(
  orderid   int        not null,
  orderdate date       not null, -- SQL Server2008之前使用datetime;
  empid     int        not null,
  custid    varchar(5) not null,
  qty       int        not null,
  constraint pk_orders3 primary key(orderid));

insert into dbo.orders3(orderid, orderdate, empid, custid, qty)
values
  (30001, '20070802', 3, 'a', 10),
  (10001, '20071224', 2, 'a', 12),
  (10005, '20071224', 1, 'b', 20),
  (40001, '20080109', 2, 'a', 40),
  (10006, '20080118', 1, 'c', 14),
  (20001, '20080212', 2, 'b', 12),
  (40005, '20090212', 3, 'a', 10),
  (20002, '20090216', 1, 'c', 20),
  (30003, '20090418', 2, 'b', 15),
  (30004, '20070418', 3, 'c', 22),
  (30007, '20090907', 3, 'd', 30); -- SQL Server2008之后可多行插入;

select * from testdb.dbo.orders3;

select empid, custid, sum(qty) as sumqty
from dbo.orders3
group by empid, custid;

-- 7.1.1 使用标准SQL进行透视转换,为每个雇员ID(empid)生成一行记录
select empid,
  sum(case when custid = 'a' then qty end) as a,
  sum(case when custid = 'b' then qty end) as b,
  sum(case when custid = 'c' then qty end) as c,
  sum(case when custid = 'd' then qty end) as d
from dbo.orders3
group by empid;

select * from testdb.dbo.orders3;

-- 7.1.2 透视转换 pivoting:(1)分组;(2)扩展;(3)聚合;
select empid, a, b, c, d
from (select empid, custid, qty
      from dbo.orders3) as d
pivot(sum(qty) for custid in(a, b, c, d)) as p; -- 分别指定聚合函数sum、聚合元素qty、扩展元素custid,剩下的empid就作为透视转换的分组元素;
                                                -- 这里pivot并没有对orders3进行操作,而是对派生表d进行操作;
-- 注意:强烈建议不要对基础表进行操作,建议使用表表达式作为pivot运算符的输入表!
select empid, a, b, c, d
from dbo.orders3
pivot(sum(qty) for custid in(a, b, c, d)) as p; -- orderid、orderdate、empid均被认为是分组元素;

-- 将上述样例转化成标准SQL
select empid,
  sum(case when custid = 'a' then qty end) as a,
  sum(case when custid = 'b' then qty end) as b,
  sum(case when custid = 'c' then qty end) as c,
  sum(case when custid = 'd' then qty end) as d
from dbo.orders3
group by orderid, orderdate, empid;

select custid, [1], [2], [3] -- 对于非常规标识符(比如以数字开头),需要进行分隔,比如使用[];
from (select empid, custid, qty
      from dbo.orders3) as d
  pivot(sum(qty) for empid in([1], [2], [3])) as p;

-- 7.2 逆透视转换
if object_id('dbo.empcustorders', 'u') is not null drop table dbo.empcustorders;

select empid, a, b, c, d
into dbo.empcustorders
from (select empid, custid, qty
      from dbo.orders3) as d
pivot(sum(qty) for custid in(a, b, c, d)) as p; -- 每行代表一个雇员,每列分别代表4个客户A、B、C、D中的一位,行和列的交叉位置代表雇员和客户之间的订货量;

select * from dbo.empcustorders;
-- 使用标准SQL进行逆透视转换
-- (1)根据来源表的每一行生成多个副本(为需要逆透视的每个列生成一个副本)
select *
from dbo.empcustorders
cross join (values('a'),('b'),('c'),('d')) as custs(custid); -- SQL Server2008之后的语法,表值构造函数,按照values子句的格式来创建一个虚拟表;

select *
from dbo.empcustorders
cross join (select 'a' as custid
              union all select 'b'
              union all select 'c'
              union all select 'd') as custs;
-- (2)生成一个数据列(本例为qty),并过滤null值;
select *
from (select empid, custid,
        case custid
          when 'a' then a
          when 'b' then b
          when 'c' then c
          when 'd' then d
        end as qty
      from dbo.empcustorders
      cross join (values('a'),('b'),('c'),('d')) as custs(custid)) as d
where qty is not null;

-- 使用T-SQL的unpivot进行逆透视转换:(1)生成副本;(2)提取元素;(3)删除交叉位置上的null值;
-- 经过透视转换所得的表再进行逆透视转换,并不能转换得到原来的表,因为逆透视转换只是把经过透视转换后的值再旋转到另一种新的格式;
-- 经过逆透视转换后的表可以再通过透视转换回到原来的状态;
select empid, custid, qty
from dbo.empcustorders
unpivot(qty for custid in(a, b, c, d)) as u;

-- 7.3 分组集
-- 7.3.1 传统的SQL中,一个聚合查询只能定义一个分组集,例如下面四个查询,它们每个都只定义了一个分组集;
select empid, custid, sum(qty) as sumqty
from dbo.orders
group by empid, custid;

select empid, sum(qty) as sumqty
from dbo.orders
group by empid;

select custid, sum(qty) as sumqty
from dbo.orders
group by custid;

select sum(qty) as sumqty
from dbo.orders; -- 空分组集

-- 使用union all将4个查询的结果集合并在一起;
select empid, custid, sum(qty) as sumqty
from dbo.orders3 group by empid, custid
union all
select empid, null, sum(qty) as sumqty -- union操作要求有相同的列,使用null占位符;
from dbo.orders3 group by empid
union all
select null, custid, sum(qty) as sumqty
from dbo.orders3 group by custid
union all
select null, null, sum(qty) as sumqty
from dbo.orders3;

-- 存在的问题:(1)需要对每个分组集指定完整的group by查询;(2)SQL Server需对每个查询分别扫描源表,导致效率低下;
-- 为解决上述问题,SQL Server 2008引入了遵循标准SQL的新功能,能够支持再同一查询语句中定义多个分组集;
-- 这些分组集可以是group by子句的grouping sets、cube、rollup从属子句(subclause),以及grouping_id函数;

-- 7.3.2 grouping sets从属子句:(1)需要的代码明显减少;(2)SQL Server优化扫描源表的次数,无需为每个分组集单独对源表进行扫描;
select empid, custid, sum(qty) as sumqty
from dbo.orders3
group by grouping sets((empid, custid),(empid),(custid),());
-- 7.3.3 cube从属子句
-- SQL Server2008新语法,符合SQL标准;
select empid, custid, sum(qty) as sumqty
from dbo.orders3
group by cube(empid, custid); -- empid、custid、()所有的组合形式;
-- 旧语法,与上述语句等效,但建议用新的!
select empid, custid, sum(qty) as sumqty
from dbo.orders3
group by empid, custid
with cube;

-- 7.3.3 rollup从属子句:rollup(a,b,c)认为a > b > c,所以只生成四个分组,相当于grouping sets((a,b,c),(a,b),(a),())
-- 分别生成每天、每月、每年的订货量(666)
select
  year(orderdate) as orderyear,
  month(orderdate) as ordermonth,
  day(orderdate) as orderday,
  sum(qty) as sumqty
from dbo.orders3
group by rollup(year(orderdate), month(orderdate), day(orderdate));

select
  year(orderdate) as orderyear,
  month(orderdate) as ordermonth,
  day(orderdate) as orderday,
  sum(qty) as sumqty
from dbo.orders3
group by year(orderdate), month(orderdate), day(orderdate)
with rollup;

-- 7.3.4 grouping和grouping_id
select empid, custid, sum(qty) as sumqty
from dbo.orders3
group by cube(empid, custid);   -- empid和custid都定义的是not null,这些列中的null值只代表一个占位符,表示该列不属于当前的分组集;
                                -- 例如:empid和custid均不为null的行与(empid,custid)相关联;empid不为null、custid为null的行都与分组集(empid)相关联;
                                -- 可以使用ALL或其他类似的标志来代替null;
-- grpemp = 0 && grpcust = 0的行与(empid、custid)关联;grpemp = 0 && grpcust = 1的行与(empid)关联;
-- 能和with cube和with rollup选项一起使用;
select
  grouping(empid) as grpemp,
  grouping(custid) as grpcust,
  empid, custid, sum(qty) as sumqty
from dbo.orders3
group by cube(empid, custid);

--  grouping_id()使用位图,0(00)代表的是分组集(empid、custid),1(01)代表的是分组集(empid),2(10)代表的是分组集(custid),3(11)代表的是分组集();
select
  grouping_id(empid, custid) as groupingset,
  empid, custid, sum(qty) as sumqty
from dbo.orders3
group by cube(empid, custid);

-- 8 数据修改
-- DML:select insert update delete merge
-- 8.1 插入数据 insert
if object_id('dbo.orders4', 'u') is not null drop table dbo.orders;

create table dbo.orders4
(
  orderid   int         not null
    constraint pk_orders4 primary key,
  orderdate date        not null
    constraint dft_orderdate default(current_timestamp),
  empid     int         not null,
  custid    varchar(10) not null
)
-- 8.1.1 insert values
insert into dbo.orders4(orderid, orderdate, empid, custid) -- 指定列值和列名的关联关系,不依赖定义表(或对表结构进行最后一次修改以后各个列的出现顺序);
values(10001, '20090212', 3, 'a');

insert into dbo.orders4(orderid, empid, custid) -- 未orderdate指定值,则使用默认值;
values(10002, 5, 'b');

insert into dbo.orders4                         -- SQL Server2008新语法,一次插入4行语句;
  (orderid, orderdate, empid, custid)           -- 原子操作,任何一行插入出错,所有的行均不会插入表;
values
  (10003, '20090213', 4, 'b'),
  (10004, '20090214', 1, 'a'),
  (10005, '20090213', 1, 'c'),
  (10006, '20090215', 3, 'c');

-- SQL Server2008新增的增强valus(行值构造函数和表值构造函数)
select *
from (values(10003, '20090213', 4, 'b'),
            (10004, '20090214', 1, 'a'),
            (10005, '20090213', 1, 'c'),
            (10006, '20090215', 3, 'c'))
     as o(orderid, orderdate, empid, custid); -- 指定表名和列名;

-- 8.1.2 insert select语句:同样是原子操作
insert into dbo.orders4(orderid, orderdate, empid, custid)
  select orderid, orderdate, empid, custid
  from sales.orders
  where shipcountry = 'uk';
-- 旧语法的insert select:同样是原子操作
insert into dbo.orders4(orderid, orderdate, empid, custid)
  select 10007, '20090215', 2, 'b' union all
  select 10008, '20090215', 1, 'c' union all
  select 10009, '20090216', 2, 'c' union all
  select 10010, '20090216', 3, 'a';

-- 8.1.3 insert exec语句
if object_id('sales.usp_getorders', 'p') is not null
  drop proc sales.usp_getorders;
go

create proc sales.usp_getorders
  @country as nvarchar(40)
as
select orderid, orderdate, empid, custid
from sales.orders
where shipcountry = @country;
go

exec sales.usp_getorders @country = 'france';

insert into dbo.orders4(orderid, orderdate, empid, custid)
exec sales.usp_getorders @country = 'france';

-- 8.1.4 select into语句:不是标准的SQL语句,不能用这个语句向已存在的表中插入数据;
--                       select into语句会复制来源表的基本结构(包括列名、数据类型、是否允许为null、identity属性)和数据,但是不会复制约束、索引及触发器;
--                       优点是select into使用最小日志记录模式(只要不把一个名为"恢复模式(recovery model)的数据库属性设置成null(完整恢复模式)")
if object_id('dbo.orders4', 'u') is not null drop table dbo.orders4;

select orderid, orderdate, empid, custid
into dbo.orders4
from sales.orders;

-- 在select into语句中使用集合操作;
if object_id('dbo.locations', 'u') is not null drop table dbo.locations;

select country, region, city
into dbo.locations
from sales.customers
except
select country, region, city
from hr.employees;

-- 8.1.5 bulk insert语句:将文件的数据导入一个已存在的表;
bulk insert dbo.orders4 from 'd:\IOtempfile\orders.txt' -- c:\temp\orders.txt -- 导入失败?
  with(datafiletype    = 'char', -- 指定文件类型为字符格式;
       fieldterminator = ',',    -- 字段终止符为',';
       rowterminator   = '\n');  -- 行终止符为'\t';
go

-- 8.1.6 identity属性
if object_id('dbo.t1', 'u') is not null drop table dbo.t1;

create table dbo.t1(
  keycol  int         not null identity(1, 1) -- 定义identity属性;
    constraint pk_t1 primary key,
  datacol varchar(10) not null
    constraint chk_t1_datacol check(datacol like '[a-z]%'));
go

insert into dbo.t1(datacol) values('aaaaa');
insert into dbo.t1(datacol) values('ccccc');
insert into dbo.t1(datacol) values('bbbbb');

select * from dbo.t1;

select $identity from dbo.t1;

-- 使用scope_identity()返回当前作用域内会话生成的最后一个标识值;
declare @new_key as int;
insert into dbo.t1(datacol) values('aaaaa');
set @new_key = scope_identity();
select @new_key as new_key

select
  scope_identity() as [scope_identity], -- 返回当前会话生成的最后一个标识值
  @@identity as [@@identity], -- 返回当前会话生成的最后一个标识值
  ident_current('dbo.t1') as [ident_current]; -- 不考虑作用域(会话)

-- 插入失败时或者该句所在的事务发生了回滚,标识值仍会增加;
insert into dbo.t1(datacol) values('12345');
insert into dbo.t1(datacol) values('eeeee');
select * from dbo.t1;
-- 设置identity_insert选项为on可以显式指定自己需要的值;
-- 可以用dbcc checkident重设当前的标识值;
set identity_insert dbo.t1 on;
insert into dbo.t1(keycol, datacol) values(5, 'fffff');
set identity_insert dbo.t1 off;

-- 8.2 删除数据:delete和truncate

if object_id('dbo.orders5', 'u') is not null drop table dbo.orders;
if object_id('dbo.customers', 'u') is not null drop table dbo.customers;

select * into dbo.customers from testdb.sales.customers;
select * into dbo.orders5 from testdb.sales.orders;

alter table dbo.customers add
constraint pk_customers primary key(custid);

alter table dbo.orders5 add
constraint pk_orders5 primary key(orderid),
constraint fk_orders_customers foreign key(custid) references dbo.customers(custid);

-- 8.2.1 delete:完整模式记录日志;
set nocount off;
delete from dbo.orders5
where orderdate < '20070101';
-- 8.2.2 truncate:最小模式记录日志,速度快;
--                重置标识值,delete则不会;
--                目标表被外键约束引用时,无法使用;
truncate table dbo.t1; -- 不需要过滤条件;

-- 8.2.3 基于联接的delete:执行顺序 from --> where --> delete
delete from o
from dbo.orders5 as o
join dbo.customers as c on o.custid = c.custid
where c.country = N'usa';

-- 将上述SQL改成标准SQL语法;
delete from dbo.orders
where exists(select *
             from dbo.customers as c
             where orders.custid = c.custid and c.country = N'usa');

-- 8.3 更新数据
if object_id('dbo.orderdetails', 'u') is not null drop table dbo.orderdetails;
if object_id('dbo.orders6', 'u') is not null drop table dbo.orders;

select * into dbo.orders6 from testdb.sales.orders;
select * into dbo.orderdetails from testdb.sales.orderdetails;

alter table dbo.orders6
add constraint pk_orders6 primary key(orderid);

alter table dbo.orderdetails
add constraint pk_orderdetails primary key(orderid, productid),
    constraint fk_orderdetails_orders foreign key(orderid) references dbo.orders6(orderid);

select * from dbo.orders5;
-- 8.3.1 update语句
update dbo.orderdetails
set discount = discount + 0.05
where productid = 51;

update dbo.orderdetails
set discount += 0.05        --复合运算符:+= -= *= /= %=
where productid = 51;

-- "同时操作"
select * from t1;
-- update dbo.t1
-- set col1 = col1 + 10, col2 = col1 + 10; --假如某行中col1 = 100,col2 = 200,这段代码执行后col1和col2的值结果都为110;

-- update dbo.t1
-- set col1 = col2, col2 = col1; -- 交换列值

-- 8.3.2 基于联接的update:执行顺序 from --> where --> update
update od
set discount = discount + 0.05
from dbo.orderdetails as od
join dbo.orders as o on od.orderid = o.orderid
where custid = 1;
-- 标准SQL语法(建议)
update dbo.orderdetails
set discount = discount + 0.05
where exists (select * from dbo.orders as o
              where o.orderid = orderdetails.orderid
              and custid = 1);

-- 更新多个列时联接查询代码更简洁;
update t1
set col1 = t2.col1,
    col2 = t2.col2,
    col3 = t2.col3
from dbo.t1 join dbo.t2 on t2.keycol = t1.keycol
where t2.col4 = 'abc';

-- 采用标准SQL实现上述操作;
update dbo.t1
set col1 = (select col1 from dbo.t2 where t2.keycol = t1.keycol), --每个子查询都要单独访问T2表,效率也不高;
    col2 = (select col2 from dbo.t2 where t2.keycol = t1.keycol),
    col3 = (select col3 from dbo.t2 where t2.keycol = t1.keycol)
where exists(select *
             from dbo.t2
             where t2.keycol = t1.keycol and t2.col4 = 'abc');
-- 使用行构造函数实现上述操作,行构造函数在很多方面还没实现;

/*
update dbo.t1
set(col1, col2, col3) = (select col1, col2, col3 from dbo.t2
                         where t2.keycol = t1.keycol)
where exists(select * from dbo.t2
             where t2.keycol = t1.keycol and t2.col4 = 'abc');
*/

-- 8.3.3
if object_id('dbo.sequence', 'u') is not null drop table dbo.sequence;
create table dbo.sequence(val int not null);
insert into dbo.sequence values(0);
select * from dbo.sequence;
--  ?报错:Unsafe query: 'Update' statement without 'where' updates all table rows at once
declare @nextval as int;
update sequence set @nextval = val = val + 1; -- 从右向左计算;
select @nextval;

-- 8.4 合并数据 merge
use tempdb;
if object_id('dbo.customers', 'u') is not null drop table dbo.customers;
go

create table dbo.customers
(
  custid      int         not null,
  companyname varchar(25) not null,
  phone       varchar(20) not null,
  address     varchar(50) not null,
  constraint pk_customers primary key(custid)
);

insert into dbo.customers(custid, companyname, phone, address)
values
  (1, 'cust 1', '(111) 111-1111', 'address 1'),
  (2, 'cust 2', '(222) 222-2222', 'address 2'),
  (3, 'cust 3', '(333) 333-3333', 'address 3'),
  (4, 'cust 4', '(444) 444-4444', 'address 4'),
  (5, 'cust 5', '(555) 555-5555', 'address 5');

if object_id('dbo.customersstage', 'u') is not null drop table dbo.customersstage;
go

create table dbo.customersstage
(
  custid      int         not null,
  companyname varchar(25) not null,
  phone       varchar(20) not null,
  address     varchar(50) not null,
  constraint pk_customersstage primary key(custid)
);

insert into dbo.customersstage(custid, companyname, phone, address)
values
  (2, 'aaaaa', '(222) 222-2222', 'address 2'),
  (3, 'cust 3', '(333) 333-3333', 'address 3'),
  (5, 'bbbbb', 'ccccc', 'ddddd'),
  (6, 'cust 6 (new)', '(666) 666-6666', 'address 6'),
  (7, 'cust 7 (new)', '(777) 777-7777', 'address 7');

select * from dbo.customers;
select * from dbo.customersstage;

 -- 8.4.1
merge into dbo.customers as tgt                             -- 指定目标表
using dbo.customersstage as src on tgt.custid = src.custid  -- 指定来源表和合并条件,类似join
when matched then                                           -- 找到匹配时要进行的操作
  update set                                                -- 已经制定了目标表,区别于普通的update table
    tgt.companyname = src.companyname,
    tgt.phone = src.phone,
    tgt.address = src.address
when not matched then                                       -- 没找到匹配时要进行的操作
  insert (custid, companyname, phone, address)
  values (src.custid, src.companyname, src.phone, src.address); -- 必须以分号结束;

 -- 8.4.2
merge dbo.customers as tgt
using dbo.customersstage as src on tgt.custid = src.custid
when matched then
  update set
    tgt.companyname = src.companyname,
    tgt.phone = src.phone,
    tgt.address = src.address
when not matched then
  insert (custid, companyname, phone, address)
  values (src.custid, src.companyname, src.phone, src.address)
when not matched by source then delete;                     -- 当目标表中的某一行在来源表中找不到匹配行时,就删除目标表的这一行;

 -- 8.4.3 对8.4.1的改进
merge dbo.customers as tgt
using dbo.customersstage as src on tgt.custid = src.custid
when matched and                                            -- 8.4.1中即使来源表和目标表完全相同,仍要修改客户行.
       (tgt.companyname <> src.companyname                  -- 这里使用and选项,只有目标表的属性发生变化时才进行update操作;
        or tgt.phone    <> src.phone
        or tgt.address  <> src.address) then
  update set
    tgt.companyname = src.companyname,
    tgt.phone = src.phone,
    tgt.address = src.address
when not matched then
  insert (custid, companyname, phone, address)
  values (src.custid, src.companyname, src.phone, src.address);

-- 8.5 通过表表达式修改数据
use tempdb;
if object_id('dbo.orderdetails', 'u') is not null drop table dbo.orderdetails;
if object_id('dbo.orders', 'u') is not null drop table dbo.orders;

select * into dbo.orders from testdb.sales.orders;
select * into dbo.orderdetails from testdb.sales.orderdetails;

alter table dbo.orders
add constraint pk_orders primary key(orderid);

alter table dbo.orderdetails
add constraint pk_orderdetails primary key(orderid, productid),
    constraint fk_orderdetails_orders foreign key(orderid) references dbo.orders(orderid);

-- 8.5.1
update od
set discount = discount + 0.05
from dbo.orderdetails as od
join dbo.orders as o on od.orderid = o.orderid
where custid = 1;
-- 8.5.2 使用CTE修改数据
with c as(select custid, od.orderid,
                 productid, discount, discount + 0.05 as newdiscount
          from dbo.orderdetails as od
          join dbo.orders as o on od.orderid = o.orderid
          where custid = 1)
update c
  set discount = newdiscount;

-- 8.5.3 使用派生表修改数据:使用表表达式将数据修改和数据查询分离;
update d
  set discount = newdiscount
from (select custid, od.orderid,
             productid, discount, discount + 0.05 as newdiscount
      from dbo.orderdetails as od
      join dbo.orders as o on od.orderid = o.orderid
      where custid = 1 ) as d;

-- 8.5.4 有些情况下必须使用表表达式;
use tempdb;
if object_id('dbo.t1', 'u') is not null drop table dbo.t1;
create table dbo.t1(col1 int, col2 int);
go
insert into dbo.t1(col1) values(10);
insert into dbo.t1(col1) values(20);
insert into dbo.t1(col1) values(30);

select * from dbo.t1;
-- 报错:Unsafe query: 'Update' statement without 'where' updates all table rows at once
update dbo.t1
  set col2 = row_number() over(order by col1); -- 把col2列设置为包含row_number()函数表达式的结果;
-- 为解决上述报错,使用下面的代码还是报错(?):Unsafe query: 'Update' statement without 'where' updates all table rows at once
with c as(select col1, col2, row_number() over(order by col1) as rownum
          from dbo.t1)
update c set col2 = rownum;

select * from dbo.t1;

-- 8.6 带有top选项的数据更新
use tempdb;
if object_id('dbo.orderdetails', 'u') is not null drop table dbo.orderdetails;
if object_id('dbo.orders', 'u') is not null drop table dbo.orders;
select * into dbo.orders from testdb.sales.orders;
-- 报错:Unsafe query: 'Delete' statement without 'where' clears all data in the table
-- 无法控制将要删除哪50行数据,最终被删除的将是SQL Server先碰巧访问到的50行(事实上都执行不了);
delete top(50) from tempdb.dbo.orders;
-- 居然可以执行,无法控制将要删除哪50行数据,最终被删除的将是SQL Server先碰巧访问到的50行;
update top(50) tempdb.dbo.orders
set freight = freight + 10.00;

-- 8.6.1 使用CTE删除/更新具有最小订单ID的50个订单,而不是随机删除50行;
with c as(select top(50) *
          from dbo.orders
          order by orderid)
delete from c;

with c as(select top(50) *
          from dbo.orders
          order by orderid desc)
update c
  set freight = freight + 10.00;

-- 8.7 output子句
use tempdb;
if object_id('dbo.t1', 'u') is not null drop table dbo.t1;
go
create table dbo.t1(keycol  int not null identity(1, 1) constraint pk_t1 primary key,
                    datacol nvarchar(40) not null);

-- 8.7.1 带有output的insert语句;
insert into dbo.t1(datacol)
output inserted.keycol, inserted.datacol        --为了返回insert语句新产生的所有标识列;
    select lastname from testdb.hr.employees
    where country = N'usa';
-- 带有output的insert语句 -- 把output的结果集导入另一个表;
declare @newrows table(keycol int, datacol nvarchar(40));

insert into dbo.t1(datacol)
output inserted.keycol, inserted.datacol into @newrows -- 把output的结果集导入另一个表;
    select lastname
    from testdb.hr.employees
    where country = N'uk';

select * from @newrows;

-- 8.7.2 带有output的delete语句 -- 可用于对删除数据的归当;
use tempdb;
if object_id('dbo.orders', 'u') is not null drop table dbo.orders;
select * into dbo.orders from testdb.sales.orders;

delete from dbo.orders
  output
    deleted.orderid,
    deleted.orderdate,
    deleted.empid,
    deleted.custid
where orderdate < '20080101';

-- 8.7.3 带有output的update语句;
use tempdb;
if object_id('dbo.orderdetails', 'u') is not null drop table dbo.orderdetails;
select * into dbo.orderdetails from testdb.sales.orderdetails;

update dbo.orderdetails
  set discount = discount + 0.05
output
  inserted.productid,               -- inserted表示修改后
  deleted.discount as olddiscount,  -- deleted表示修改前
  inserted.discount as newdiscount
where productid = 51;

-- 8.7.4 带有output的merge语句;
use tempdb;
merge into dbo.customers as tgt
using dbo.customersstage as src on tgt.custid = src.custid
when matched then
  update set
    tgt.companyname = src.companyname,
    tgt.phone = src.phone,
    tgt.address = src.address
when not matched then
  insert (custid, companyname, phone, address)
  values (src.custid, src.companyname, src.phone, src.address)
output $action, inserted.custid,                -- 使用$action标识由哪个DML操作生成;
  deleted.companyname as oldcompanyname,
  inserted.companyname as newcompanyname,
  deleted.phone as oldphone,
  inserted.phone as newphone,
  deleted.address as oldaddress,
  inserted.address as newaddress;
-- 8.7.5 可组合的DML
use tempdb;
if object_id('dbo.productsaudit', 'u') is not null drop table dbo.productsaudit;
if object_id('dbo.products', 'u') is not null drop table dbo.products;

select * into dbo.products from testdb.production.products;

create table dbo.productsaudit(
  lsn int not null identity primary key,
  ts  datetime not null default(current_timestamp),
  productid int not null,
  colname sysname not null,
  oldval sql_variant not null,
  newval sql_variant not null);

insert into dbo.productsaudit(productid, colname, oldval, newval)
  select productid, N'unitprice', oldval, newval
  from (update dbo.products                         -- 将output子句输出的多集作为select语句的输入,然后把select语句的输出插入一个表;
          set unitprice *= 1.15
        output
          inserted.productid,
          deleted.unitprice as oldval,
          inserted.unitprice as newval
        where supplierid = 1) as d
  where oldval < 20.0 and newval >= 20.0;

select * from dbo.productsaudit;

-- 9 事务和并发
-- 9.1 事务:定义事务边界的方式有显示和隐式两种,其中显示事务以begin tran开始,以commit tran结束,以rollback tran回滚结束事务;
--     注意:如果不显示定义事务的边界,SQL Server会默认把每个单独的语句作为一个事务,也就是SQL Server默认在执行完每个语句之后就自动提交事务
--          可以通过implicit_transactions会话选项来改变SQL Server处理隐式事务的方式,
--          默认为off,设置为on时就不必用begin tran标明事务的开始,但仍需要commit tran或rollback tran语句来标明事务完成;
-- 事务必须有四个属性:原子性(Atomicity)、一致性(Consistency)、隔离性(Isolation)、持久性(Durability),即ACID
--    (1) 原子性:事务必须时原子工作单元,即要么全执行,要么全都不执行;如果在事务完成之前(在提交指令被记录到事务日志之前)系统出现
--               故障或是重新启动,SQL Server将会撤销在事务中进行的所有修改;如果在事务处理中遇到错误,SQL Server通常会自动回滚事务,
--               但也有少数例外,一些不太严重的错误不会引发事务的自动回滚,例如主键冲突、锁超时等,另外可以使用错误处理代码来捕获这些
--               错误,并采取某种操作(例如,把错误记录在日志中,再回滚事务);
--        注:通过查询@@trancount函数,可以判断当前代码是否位于一个打开的事务当中(不在则返回0,在则返回大于0的值);
--    (2) 一致性:同时发生的事务在修改和查询数据时不发生冲突,通过RDMS访问的数据要保持一致的状态;一致性的定义取决于应用程序的需要;
--    (3) 隔离性:用于控制数据访问的机制,能够确保事务只访问处于期望的一致性级别下的数据;SQL Server使用锁对各个事务之间正在修改
--              和查询的数据进行隔离;
--    (4) 持久性:在将数据修改写入到磁盘上数据库的数据分区之前,总是先把这些修改写入到磁盘上数据库的事务日志中;把提交指令记录到磁盘的
--               事务日志中以后,即使数据修改还没有应用到磁盘的数据分区,也可以认为事务是持久化的;这是如果系统重新启动(正常启动或发生
--               系统故障之后启动),SQL Server会检查每个数据库的事务日志,进行恢复(recovery)处理。恢复处理包括两个阶段:重做阶段(redo)和
--               撤销阶段(undo)。在重做阶段,对于提交指令已经写入到日志,但数据修改还没有应用到数据分区的事务,数据库引擎会重做(replaying)
--               这些事务所做的所有修改,这个过程也成为"前滚(rolling forward)";在撤销阶段,对于提交指令还没记录到日志中的事务,数据库引擎
--               会撤消(undoing)这些事务所作的修改,这个过程也称为"回滚(rolling back)";

-- 9.1.1 一个事务样例
USE testdb;
BEGIN TRAN;
  DECLARE @neworderid AS INT;
  -- 将一个新订单插入到Sales.orders表;
  INSERT INTO Sales.Orders
      (custid, empid, orderdate, requireddate, shippeddate,
       shipperid, freight, shipname, shipaddress, shipcity,
       shippostalcode, shipcountry)
    VALUES
      (85, 5, '20090212', '20090301', '20090216',
       3, 32.38, N'Ship to 85-B', N'6789 rue de l''Abbaye', N'Reims',
       N'10345', N'France');
 -- 将新的订单ID保存在变量中;
  SET @neworderid = SCOPE_IDENTITY();
  -- 返回新的订单ID;
  SELECT @neworderid AS neworderid;
  -- 将新订单的订单明细行插入到Sales.OrderDetails表;
  INSERT INTO Sales.OrderDetails
      (orderid, productid, unitprice, qty, discount)
    VALUES(@neworderid, 11, 14.00, 12, 0.000);
  INSERT INTO Sales.OrderDetails
      (orderid, productid, unitprice, qty, discount)
    VALUES(@neworderid, 42, 9.80, 10, 0.000);
  INSERT INTO Sales.OrderDetails
      (orderid, productid, unitprice, qty, discount)
    VALUES(@neworderid, 72, 34.80, 5, 0.000);
-- 提交事务;
COMMIT TRAN;

-- Cleanup
DELETE FROM Sales.OrderDetails
WHERE orderid > 11077;

DELETE FROM Sales.Orders
WHERE orderid > 11077;

DBCC CHECKIDENT ('Sales.Orders', RESEED, 11077);

-- 9.2 锁定和阻塞
-- 9.2.1 (1)锁:排他锁、共享锁、更新锁、意向锁、架构锁
--          当试图修改数据时,事务会为所依赖的数据资源请求排他锁;
--          当试图读取数据时,事务默认会为所依赖的数据资源请求共享锁;
--       (2)锁兼容:如果数据正在由一个事务进行修改,其他事务既不能修改数据,也不能读取(至少默认不能)数据,直到第一个事务完成;
--              如果数据正在由另一个事务读取,其他事务就不能修改数据(至少默认不能);
--       (3)可锁定资源的类型:SQL Server可以锁定不同类型或粒度的资源,这些资源类型包括RID、KEY(行)、PAGE(页)、对象(表)、数据库等
--                    注: 行位于页中,而页则是包含表或索引数据的物理数据块;
--                      高级资源:extent(区)、分配单元(allocation_unit)、堆(heap)、B树(B-tree)
--                    注:为了获得某一行的排他锁,事务必须现在包含那一行的页上获取意向排他锁,并在包含那一页的数据对象上也获取意向排他锁;
--       (4)SQL Server可以先获得细粒度的锁(例如,行或页),在某些情况下可以将细粒度的锁升级为更粗力度的锁(例如,表),例如,当单个语句获得至少5000个锁时,
--         就会触发锁升级;如果由于锁冲突而导致无法升级锁,则SQL Server每当获取1250个新锁时便会触发锁升级;
--       (5)SQL Server2008后可以用alter table语句为表设置一个lock_escalation选项,以控制锁升级的处理方式,即可以禁止锁升级,或者自己决定锁升级是在
--          表上进行(默认)还是在分区上进行(表在物理上可以划分成多个更小的单元,即分区)

-- 9.2.2 阻塞检测
-- 示例
use testdb;
-- connection 1
begin tran;
  update production.products
    set unitprice = unitprice + 1.00
  where productid = 2;
-- connection 2
select productid, unitprice         -- connection 1会话会获得排他锁,connection 2无法获取共享锁,发生阻塞;
from production.products
where productid = 2;

-- 在connection 3中查询动态管理视图(DMV,dynamic management view)sys.dm_tran_locks
select -- use * to explore
  request_session_id            as spid,                -- 服务器进程标识,可以通过@@spid函数查看会话的spid,
                                                        -- SSMS底部用户名右侧圆括号显示的就是当前会话的SPID;
  resource_type                 as restype,             -- 被锁定资源的类型,例如key代表行锁;
  resource_database_id          as dbid,                -- 被锁定资源位于的数据库id;
  db_name(resource_database_id) as dbname,              -- 使用db_name()把这个ID转换成相应的数据库名;
  resource_description          as res,
  resource_associated_entity_id as resid,               -- 资源说明和与资源相关联的实体ID;
  request_mode                  as mode,                -- 锁模式;
  request_status                as status               -- 已经授予锁还是会话正在请求锁;
from sys.dm_tran_locks;

select -- use * to explore
  session_id as spid,
  connect_time,                                         -- 联接建立的事件;
  last_read,                                            -- 联接最后一次发生读操作和写操作的时间;
  last_write,
  most_recent_sql_handle                                -- 一个二进制标记值,用于返回此联接上执行的最后一个SQL批处理;
                                                        -- 可以把这个标记值作为输入参数提供给表函数sys.dm_exec_sql_text,返回该标记值代表的SQL代码;
from sys.dm_exec_connections
where session_id in(52, 53);

-- 通过sessionid查询阻塞涉及的每个联接最后调用的批处理代码;
select session_id, text
from sys.dm_exec_connections
  cross apply sys.dm_exec_sql_text(most_recent_sql_handle) as st
where session_id in(52, 53);

-- 使用动态管理视图sys.dm_exec_sessions也能找到很多有用的信息;
select -- use * to explore
  session_id as spid,
  login_time,                                           -- 会话建立的时间;
  host_name,                                            -- 会话的客户端工作站名称;
  program_name,                                         -- 初始化会话客户端程序的名称;
  login_name,                                           -- 会话所使用的SQL Server登录名;
  nt_user_name,                                         -- 客户端的windows用户名;
  last_request_start_time,                              -- 最近一次会话请求的开始时间;
  last_request_end_time                                 -- 最后一次会话请求的完成时间;
from sys.dm_exec_sessions
where session_id in(52, 53);

-- 使用动态管理视图sys.dm_exec_requests排除阻塞状态;
select -- use * to explore
  session_id as spid,
  blocking_session_id,
  command,
  sql_handle,
  database_id,
  wait_type,
  wait_time,                                            -- 被阻塞的会话等待了多长时间(单位:ms);
  wait_resource
from sys.dm_exec_requests
where blocking_session_id > 0;

-- 可以使用kill <spid>命令终止导致阻塞的进程,如kill 52,但是不建议.可以通过设置lock_timeout选项设置锁定的超时期限(单位:ms);
set lock_timeout 5000;                                  -- 设置会话的超时期限为5s;
select productid, unitprice
from production.products
where productid = 2;

set lock_timeout -1;                                    -- 取消锁定超时期限;
select productid, unitprice
from production.products
where productid = 2;

-- 9.3 隔离级别:(1) 读操作使用共享锁,写操作使用排他锁;
--             (2) 虽然不能控制写操作的处理方式,但可以控制读操作的处理方式;
--             (3) 可以在会话级别上用选项来设置隔离级别,也可以在查询级别上用表提示(table hint)来设置隔离级别;
--             (4) 可设置的6种隔离级别:read uncommitted(未提交读)、read committed(已提交读,默认)、repeatable read(可重复度)、、
--                                   serializable(可序列化)、snapshot(快照)、read committed snapshot(已经提交读隔离)

-- 设置方式
-- 设置整个会话的隔离级别;
-- set transaction isolation level <isolation name>; -- 在各单词之间指定空格;
-- 使用表提示设置隔离级别;
-- select ... from <table> with (<isolationname>); -- 隔离级别设定,无空格,例如with(repeatableread)
-- 也可以也有同义词,如with(nolock)相当于指定readuncommitted,readuncommittedwith(holdlock)相当于指定repeatableread;

-- 9.3.1 read uncommitted(未提交读):读操作不会请求共享锁,会产生脏读;
-- connection 1:打开事务,更新数据,未提交事务;
begin tran;
update production.products
set unitprice = unitprice + 1.00
where productid = 2;

select productid, unitprice
from production.products
where productid = 2;
-- connection 2:设置会话的隔离级别是未提交读,会读取到修改后的数据(即使事务中的数据修改还未提交),这是如果事务中又进行了修改或者事务
--              进行了回滚(rollback tran),在connection 2中读取到的数据就是错误的,这种情况称为脏读;
set transaction isolation level read uncommitted;
select productid, unitprice
from production.products
where productid = 2;

-- 9.3.2 read committed(已提交读,默认):这个隔离级别只允许读取已经提交过的修改,读操作会获取共享锁;
-- connection 1:开始事务,并且未提交;
begin tran;
update production.products
set unitprice = unitprice + 1.00
where productid = 2;

select productid, unitprice
from production.products
where productid = 2;

-- connection 2:设置会话的隔离级别是已提交读,select操作会被阻塞;
set transaction isolation level read committed;
select productid, unitprice
from production.products
where productid = 2;


-- connection 1:会话1提交事务,会话2查询成功;
-- 注意:在read committed隔离级别,读操作一完成就立即释放资源上的共享锁,读操作不会在事务持续期间内保留共享锁;实际上,甚至在语句结束前
--      也不能一直保留共享锁(?);这意味着在一个事务处理内部对相同数据资源的两个读操作之间,没有共享锁会锁定资源,这样的话其他事务会在
--      两个读操作之间更改数据资源,从而导致读操作每次查询可能得到不同的值,这种现象称为不可重复读;
commit tran;

-- cleanup
update production.products
set unitprice = 19.00
where productid = 2;

-- 9.3.2 repeatable read(可重复读):在这种隔离级别下,事务中的读操作不但需要获得共享锁才能读取数据,而且获得的共享锁会一直保持到事务完成为止;
-- connection 1:设置隔离级别为repeatable read
set transaction isolation level repeatable read;
begin tran;
select productid, unitprice
from production.products
where productid = 2;

-- connection 2:尝试修改数据失败,如果是read uncommitted或者read committed隔离级别下运行,事务此时将不再持有共享锁,
--              下面的修改数据操作也能够成功;
update production.products
set unitprice = unitprice + 1.00
where productid = 2;

-- connection 1:提交事务,在这个会话中查询得到的结果一致;
select productid, unitprice
from production.products
where productid = 2;
commit tran;

-- 另外repeatable read能够防止另一种并发情况丢失更新,丢失更新是指当两个事务读取了同一个值,然后基于最初的值进行计算,接着再更新该值,
--  就会发生丢失更新的问题;在比repeatable read更低的隔离级别中,读完数据之后就不再持有资源上的任何锁,两个事务都能更新这个值,读取完
--  数据之后就不再持有资源上的任何锁,两个事务都能更新这个值,而最后进行更新的事务则是"赢家",覆盖由其他事务所作的更新,这将导致数据丢失;
--  在repeatable read隔离级别下在事务结束前都会保持共享锁,其它事务更新数据时获取不到排他锁,这种情况有可能导致死锁;
-- cleanup
update production.products
set unitprice = 19.00
where productid = 2;

-- 9.3.4 serializable(可序列化):(1)在repeatable read隔离级别下,读操作获取的共享锁将一直保持到事务完成为止,因此可以保证在事务中第一次
--                             读取某些行后,还可以重复读取这些行;但是,事务的查询语句只锁定第一次运行时找到的那些数据资源(例如某行、
--                             某些行),而不会锁定查询结果以外的其他行,因此在同一事务中进行第二次读取之前,如果其他事务插入了新行,而且
--                             新行也能满足读操作的查询过滤条件,那么这些新行也会出现在第二次读操作返回的结果中,这种情况称为幻读.
--                             (2)使用serializable能够避免幻读,serializable在repeatable read的基础上加了新内容,这个隔离级别
--                             会让读操作锁定满足查询条件的键的整个范围;
-- connection 1:设置serializable隔离级别
set transaction isolation level serializable;
begin tran
select productid, productname, categoryid, unitprice
from production.products
where categoryid = 1;

-- connection 2:插入失败;
insert into production.products(productname, supplierid, categoryid,unitprice, discontinued)
values('product abcde', 1, 1, 20.00, 0);

-- connection 1:提交事务,connection 2查询成功;
select productid, productname, categoryid, unitprice
from production.products
where categoryid = 1;
commit tran;

-- 清理数据
delete from production.products
where productid > 77;
dbcc checkident ('production.products', reseed, 77);

-- 将会话的隔离级别设置为默认的值;
set transaction isolation level read committed;

-- snapshot(快照):可以把已经提交的行保存在tempdb数据库中,读操作不会使用共享锁,而且可以获得和serializable和read committed的一致性;
--                     (1) snapshot:和serializable隔离级别类似;
--                     (2) read committed snapshot:和read committed隔离级别类似;
--                 注意:(1) 如果启用任何一种基于快照的隔离级别,delete和update会在做出修改前把行的当前版本复制到tempdb数据库中,insert
--                      不需要再tempdb中进行版本控制,因为这是还没有旧版本;
--                     (2) 基于快照的隔离级别对更新和删除操作的性能产生负面影响,不过会提高读操作的性能;

-- 9.3.5 snapshot(隔离级别)
-- 在数据库级别上设置相关选项;
alter database testdb set allow_snapshot_isolation on;

-- connection 1:即使会话1没有设置隔离级别(默认的read committed),运行以下事务也会把更新的数据保存到tempdb,因为在数据库级别启用了snapshot;
begin tran;
update production.products
set unitprice = unitprice + 1.00
where productid = 2;

select productid, unitprice
from production.products
where productid = 2;

-- connection 2:在会话2设置隔离级别为snapshot,如果在serializable隔离级别下会被阻塞,但是在snapshot隔离级别下,可以查询到目标行(值为19),因为
--              在tempdb中保存了原来的版本;
set transaction isolation level snapshot;
begin tran;
select productid, unitprice
from production.products
where productid = 2;

-- connection 1:提交事务;
commit tran;

-- connection 2:在会话2再次读取数据,结果仍然没变(还是19),因为snapshot保证了同一事务中的多次读操作结果不变;
select productid, unitprice
from production.products
where productid = 2;
commit tran;


-- connection 2:重新开启一个事务,能够查询到修改后的数据(值为20);
begin tran
select productid, unitprice
from production.products
where productid = 2;
commit tran;

-- 快照清理线程每隔1分钟运行一次,由于没有事务需要价格为19的那个版本,所以清理线程下一次会把行版本从tempdb中删除掉;
-- 清理数据
update production.products
set unitprice = 19.00
where productid = 2;

-- repeatable read和serializable都能够通过产生死锁状态避免更新冲突,snapshot也能避免更新冲突,但与前面两种不同,当检测到更新冲突时,
--  snapshot快照事务将因失败而终止.snapshot通过检查保存的行版本,就能检测出更新冲突,它能判断出在快照事务的一次读操作和一次写操作之间
--  是否有其他事务修改过数据;

-- connection 1:在会话1设置隔离级别为snapshot
set transaction isolation level snapshot;
begin tran;
select productid, unitprice
from production.products
where productid = 2;

-- connection 1:运行下面的更新数据语句,并提交事务;
-- 在快照事务进行读取、计算、修改操作期间没有其他事务对行进行修改,因此没有发生更新冲突;
update production.products
set unitprice = 20.00
where productid = 2;
commit tran;

-- 将数据复原;
update production.products
set unitprice = 19.00
where productid = 2;

-- connection 1:在会话1设置隔离级别为snapshot,再次运行事务;
set transaction isolation level snapshot;
begin tran;
select productid, unitprice
from production.products
where productid = 2;

-- connection 2:在会话2运行以下代码,更改数据;
update production.products
set unitprice = 25.00
where productid = 2;

-- connection 1:在会话1继续事务,SQL Server检测到在读取和写入之间有另一个事务修改了数据,因此SQL Server让事务更新数据失败;
update production.products
set unitprice = 20.00
where productid = 2;

-- 还原数据;
update production.products
set unitprice = 19.00
where productid = 2;

-- 9.3.6 read committed snapshot(隔离级别):基于行版本控制,但与snapshot隔离级别有所不同;
--                                        在这种隔离级别下,读取操作读取的数据行不是事务启动前最后提交的版本,而是语句启动前最后提交的版本;
--                                    另外:在这种隔离级别下不进行更新冲突检测,这样read committed snapshot的逻辑行为就与read committed
--                                         隔离级别非常类似,只不过读操作不用获得共享锁;

-- 把默认的read committed隔离级别的含意变成了read committed snapshot,这意味着当打开这个数据库选项时,除非显示的修改会话的隔离级别,
-- 否则read committed snapshot将是默认的隔离级别;
alter database testdb set read_committed_snapshot on;
-- connection 1:在read committed snapshot隔离级别下运行下面的事务代码;
use testdb;
begin tran;
update production.products
set unitprice = unitprice + 1.00
where productid = 2;

select productid, unitprice
from production.products
where productid = 2;

-- connection 2:在会话2读取数据,得到是语句启动前最后提交的行版本(值是19)
begin tran;
select productid, unitprice
from production.products
where productid = 2;

-- connection 1:会话1提交事务;
commit tran;

-- connection 2:在会话2运行以下代码,并提交事务,得到的结果是20,如果这段代码是在snapshot隔离级别下运行的,得到的价格会是19;
--              因为在read committed snapshot隔离级别下得到的是语句启动前最后提交的版本,而不是事务启动前的版本,即这种情况称为不可重复读;
select productid, unitprice
from production.products
where productid = 2;
commit tran;

-- 关闭所有的会话后,重新设置隔离级别为默认的read committed;
set transaction isolation level read committed;

-- 关闭基于快照的隔离级别;
alter database testdb set allow_snapshot_isolation off;
alter database testdb set read_committed_snapshot off;

-- 9.4 死锁:除非指定了其他方式,SQL Server会选择终止做过的操作最少的事务,这样可以让回滚开销降低到最少;
--          也可以通过deadlock_priority设置优先级(-10 - 10 间任意整数)

-- 死锁样例;
-- connection 1:在会话1开启事务,并更新表products数据;
use testdb;
begin tran;
update production.products
set unitprice = unitprice + 1.00
where productid = 2;

-- connection 2:在会话2开启事务,并更新表orderdetails数据;
begin tran;
update sales.orderdetails
set unitprice = unitprice + 1.00
where productid = 2;

-- connection 1:在会话1运行以下事务,以下代码尝试查询orderdetails表中的数据,会被阻塞;
select orderid, productid, unitprice
from sales.orderdetails
where productid = 2;
commit tran;

-- connection 2:在会话2运行以下事务,以下代码尝试查询表products中的数据,也会被阻塞;
-- SQL Server会在几秒种内检测到死锁,并终止一个死锁的事务;
select productid, unitprice
from production.products
where productid = 2;
commit tran;

-- 注:(1)事务处理的时间越长,持有锁的时间就越长,死锁的可能性就越大,因此应该尽可能保持事务简短,把逻辑上可以不属于同一工作的那元的操作移到事务以外;
--    (2)上例的死锁有真实的逻辑冲突(都对产品2操作),如果对产品id为2和5的分别进行处理,则不会死锁(前提是在productid列有索引来支持查询,否则SQL Server
--        就必须扫描(并锁定)表中所有行,这样就会导致死锁)

-- 还原数据;
update production.products
set unitprice = 19.00
where productid = 2;

update sales.orderdetails
set unitprice = 19.00
where productid = 2 and orderid >= 10500;

update sales.orderdetails
set unitprice = 15.20
where productid = 2 and orderid < 10500;

-- 10 可编程对象(变量、批处理、流程控制元素、游标、临时表、动态SQL、例程(如用户定义函数、存储过程、触发器)、以及错误处理)
-- 10.1 变量
declare @i as int;      -- SQL Server2008之前的语法;
set @i = 10;

declare @i as int = 10;     -- SQL Server2008之后可用;

-- 10.1.1 将子查询的结果存在变量中;
use testdb;
declare @empname as nvarchar(61);
set @empname = (select firstname + N' ' + lastname --set要求使用标量子查询来从表中提取数据;
                from hr.employees
                where empid = 3);
select @empname as empname;
-- 10.1.2 set语句只能对一个变量操作,给多个变量赋值必须使用多个set;
declare @firstname as nvarchar(20), @lastname as nvarchar(40);
set @firstname = (select firstname from hr.employees
                  where empid = 3);
set @lastname = (select lastname from hr.employees
                  where empid = 3);
select @firstname as firstname, @lastname as lastname;

-- 10.1.3 使用select进行赋值;
declare @firstname as nvarchar(20), @lastname as nvarchar(40);
select @firstname = firstname,@lastname  = lastname
from hr.employees
where empid = 3;
select @firstname as firstname, @lastname as lastname;

-- 使用select进行赋值(查询结果只有一行),如果select返回多个值,每访问一行,就会用当前行的值覆盖掉变量中的原有值;
declare @empname as nvarchar(61);
select @empname = firstname + N' ' + lastname
from hr.employees
where mgrid = 2;
select @empname as empname;

-- 报错:子查询返回的值不止一个。当子查询跟随在 =、!=、<、<=、>、>= 之后，或子查询用作表达式时，这种情况是不允许的
-- set比select更安全;
declare @empname as nvarchar(61);
set @empname = (select firstname + N' ' + lastname
                from hr.employees
                where mgrid = 2);
select @empname as empname;

-- 10.2 批处理:分析(语法检查) --> 解析(检查引用的对象和列是否存在、是否具有访问权限) --> 优化(形成执行单元);
--             数据库管理软件提供了GO命令作为T-SQL语句结束的信号;
-- 10.2.1 批处理是语句分析的单元
-- valid batch
print 'first batch';
use tsqlfundamentals2008;
go
-- invalid batch
print 'second batch';
select custid from sales.customers;
select orderid fom testdb.sales.orders; -- 错误语句
go
-- valid batch
print 'third batch';
select empid from hr.employees;
go
-- 10.2.2 批处理和变量
declare @i as int;
set @i = 10;
print @i;
go

print @i;       -- fails
go
-- 10.2.3 不能在同一批处理中编译的语句:create defult、create function、create proceduce、create rule、create schema、create trigger、create view
if object_id('sales.myview', 'v') is not null drop view sales.myview;
-- go              --添加go命令将if和create view分隔到不同的批处理中;
create view sales.myview
as

select year(orderdate) as orderyear, count(*) as numorders
from sales.orders
group by year(orderdate);
go

-- 10.2.4 批处理是语句解析的单元:检查数据对象和列是否存在;
--        注意:解析是在批处理级上进行的,这意味着如果在批处理中对对象的架构定义进行了修改,并在该批处理中对该对象进行处理,那么SQL Server可能不知道对象架构的改变;
use tempdb;
if object_id('dbo.t1', 'u') is not null drop table dbo.t1;
create table dbo.t1(col1 int);
go
-- 报错:列名 'col2' 无效;
alter table dbo.t1 add col2 int; -- 增加了一列,但是同一批处理的其他语句还是按照批处理之前的表结构进行查询;
select col1, col2 from dbo.t1;
go
-- 修改上述代码
alter table dbo.t1 add col2 int;
go
select col1, col2 from dbo.t1;
go

-- 10.2.5 GO n选项
-- create t1 with identity column
if object_id('dbo.t1', 'u') is not null drop table dbo.t1;
create table dbo.t1(col1 int identity);
go
-- 阻止DML语句在生成的结果中默认显示受影响的行数;
set nocount on;
go
-- 执行批处理100次;
insert into dbo.t1 default values;
go 100

-- 10.3 流程控制函数
-- 10.3.1 if else流程控制函数:注意T-SQL是三值逻辑(false、unknown、else)
if year(current_timestamp) <> year(dateadd(day, 1, current_timestamp)) -- 今天是不是当年的最后一天;
  print 'today is the last day of the year.'
else
  print 'today is not the last day of the year.'
go

-- 10.3.2 if else if
if year(current_timestamp) <> year(dateadd(day, 1, current_timestamp))  -- 今天是不是当年的最后一天;
  print 'today is the last day of the year.'
else
  if month(current_timestamp) <> month(dateadd(day, 1, current_timestamp)) -- 今天是不是一个月的最后一天;
    print 'today is the last day of the month but not the last day of the year.'
  else
    print 'today is not the last day of the month.'; -- 几天不是一个月的最后一天;
go

-- 10.3.3 if else要运行多条语句: begin end;
if day(current_timestamp) = 1
begin
  print 'today is the first day of the month.';
  print 'starting a full database backup.';
  backup database testdb to disk = 'c:\temp\tsqlfundamentals2008_full.bak' with init; -- 对数据库进行完整备份;
  print 'finished full database backup.';
end
else
begin
  print 'today is not the first day of the month.'
  print 'starting a differential database backup.';
  backup database testdb to disk = 'c:\temp\tsqlfundamentals2008_diff.bak' with init; -- 对数据库进行差异备份(只保存上一次完整备份以来做过的更新);
  print 'finished differential database backup.';
end
go

-- 10.3.4 while
declare @i as int;
set @i = 1;
while @i <= 10
begin
  print @i;
  set @i = @i + 1;
end;
go
-- break
declare @i as int;
set @i = 1
while @i <= 10
begin
  if @i = 6 break;
  print @i;
  set @i = @i + 1;
end;
go
-- continue
declare @i as int;
set @i = 0
while @i < 10
begin
  set @i = @i + 1;
  if @i = 6 continue;
  print @i;
end;
go

-- 10.3.5 同时使用if和while
-- 创建dbo.nums,再为这个表填充1000行数据;
set nocount on;
use tempdb;
if object_id('dbo.nums', 'u') is not null drop table dbo.nums;
create table dbo.nums(n int not null primary key);
go

declare @i as int;
set @i = 1;
while @i <= 1000
begin
  insert into dbo.nums(n) values(@i);
  set @i = @i + 1;
end
go
select * from dbo.nums;

-- 10.4 游标:也是一种对象,order by生成的就是一种游标;
--          注意(尽量少用):使用了游标(鱼竿)就违背了关系模型,关系模型按照集合(渔网)来考虑问题;
--                        游标代码通常比基于集合的代码慢许多;
--                        使用游标要多写许多代码(声明游标、打开游标、循环遍历游标记录、关闭游标、释放游标)
--          应用场景:为某个表或视图中的每一行应用特定的操作;基于集合的方案代码更复杂(比如第四章中的连续聚合);
--                  比如为SQL Server实例中的每个数据库执行某种管理性任务时,用游标来循环遍历数据库名或表名,每次遍历为每个对象执行相关的任务;

-- 样例:计算sales.custorders视图中的每个客户每个月的连续总订货量;
set nocount on;
use testdb;
declare @result table(
  custid     int,
  ordermonth datetime,
  qty        int,
  runqty     int,
  primary key(custid, ordermonth));

declare
  @custid     as int,
  @prvcustid  as int,
  @ordermonth datetime,
  @qty        as int,
  @runqty     as int;

declare c cursor fast_forward /* read only, forward only */ for -- 声明游标;
  select custid, ordermonth, qty
  from sales.custorders
  order by custid, ordermonth;

open c                                                          -- 打开游标;

fetch next from c into @custid, @ordermonth, @qty;              -- 从第一个游标记录中把列值提取到指定的变量;

select @prvcustid = @custid, @runqty = 0;

while @@fetch_status = 0                                        -- 当还没有超出游标的最后一行时(@@fetch_status函数的返回值是0),循环遍历游标记录;
begin
  if @custid <> @prvcustid
    select @prvcustid = @custid, @runqty = 0;

  set @runqty = @runqty + @qty;

  insert into @result values(@custid, @ordermonth, @qty, @runqty);

  fetch next from c into @custid, @ordermonth, @qty;            -- 从当前游标记录中把列值提取出来到指定的变量,再为当前执行相应的处理;
end

close c;                                                        -- 关闭游标;

deallocate c;                                                   -- 释放游标;

select
  custid,
  convert(varchar(7), ordermonth, 121) as ordermonth,
  qty,
  runqty
from @result
order by custid, ordermonth;
go

-- 10.5 临时表:局部临时表、全局临时表、表变量;
-- 10.5.1 局部临时表,对创建它的会话再创建级和调用堆栈级是可见的,例如:Proc1 --> Proc2(在调用Proc3之前又创建了#T1) --> Proc3 --> Proc4;
--                                                                此时#T1对Proc2 Proc3 Proc4可见,对Proc1不可见;
--        使用场景:需要保存中间数据,方便后续查询;需要多次访问某个开销昂贵的处理结果;
use testdb;
if object_id('tempdb.dbo.#myordertotalsbyyear') is not null
  drop table dbo.#myordertotalsbyyear;
go

select year(o.orderdate) as orderyear,sum(od.qty) as qty
into dbo.#myordertotalsbyyear
from sales.orders as o
join sales.orderdetails as od on od.orderid = o.orderid
group by year(orderdate);

select cur.orderyear, cur.qty as curyearqty, prv.qty as prvyearqty
from dbo.#myordertotalsbyyear as cur
left outer join dbo.#myordertotalsbyyear as prv on cur.orderyear = prv.orderyear + 1;
go

-- 10.5.2 全局临时表:对其他所有会话都可见;如果创建临时表的会话断开数据库联接,全局临时表也没有被引用,SQL Server会自动删除相应的全局临时表;
--                  访问全局临时表不需要任何特殊权限,所有人都可以获取完整的DDL和DML,当然也意味着每个人也可以删除这张表;
--        注意:如果需要在SQL Server每次启动时都创建一个全局临时表,且不让SQL自动删除,可以从一个标识为启动过程的存储过程中创建全局临时表;
create table dbo.##globals(
  id  sysname     not null primary key, -- SQL Server在内部用这个类型来代表标识符;
  val sql_variant not null);            -- 一种通用的类型,差不多可以保存任何基础类型的值;
-- run from any session
insert into dbo.##globals(id, val) values(N'i', cast(10 as int));
-- run from any session
select val from dbo.##globals where id = N'i';
-- run from any session
drop table dbo.##globals;
go
-- 10.5.3 表变量:只对创建它的会话可见,且只对当前批处理可见;
declare @myordertotalsbyyear table(
  orderyear int not null primary key,
  qty       int not null);

insert into @myordertotalsbyyear(orderyear, qty)
  select year(o.orderdate) as orderyear,sum(od.qty) as qty
  from sales.orders as o
  join sales.orderdetails as od on od.orderid = o.orderid
  group by year(orderdate);

select cur.orderyear, cur.qty as curyearqty, prv.qty as prvyearqty
from @myordertotalsbyyear as cur
  left outer join @myordertotalsbyyear as prv
    on cur.orderyear = prv.orderyear + 1;
go

-- 10.5.4 表类型(?)
if type_id('dbo.ordertotalsbyyear') is not null
  drop type dbo.ordertotalsbyyear;
create type dbo.ordertotalsbyyear as table(
  orderyear int not null primary key,
  qty       int not null);
go

declare @myordertotalsbyyear as dbo.ordertotalsbyyear;
insert into @myordertotalsbyyear(orderyear, qty)
  select year(o.orderdate) as orderyear,sum(od.qty) as qty
  from testdb.sales.orders as o
  join testdb.sales.orderdetails as od on od.orderid = o.orderid
  group by year(orderdate);
select orderyear, qty from @myordertotalsbyyear;
go

-- 10.6 动态SQL: 使用字符串动态构造T-SQL代码的一个批处理,接着再执行这个批处理;使用exec和sp_executesql执行;
--      使用场景:(1)自动化管理任务,例如,对数据库实例的每个数据库查询其元数据,为其执行backup database语句;
--              (2)改善特定任务的性能,例如,构造参数化的特定查询,可以重用以前缓存过的执行计划;
--              (3)再对实际数据进行查询的基础上,构造代码元素,例如,当事先不知道再pivot运算符的in子句中应该出现哪些元素时,动态构造pivot查询;

-- 10.6.1 exec命令
declare @sql as varchar(100);
set @sql = 'print ''this message was printed by a dynamic sql batch.'';'; -- 对于字符串中的字符串需要两个单引号来代表一个单引号;
exec(@sql);
go

-- sp_spaceused命令
-- 通过游标对information_schema.tables视图进行查询,获取表的名称,
-- 然后对于每个表,代码将构造和执行一个批处理代码,对当前表调用sp_spaceused存储过程以获取其磁盘空间实用信息;
use testdb;
declare
  @sql as nvarchar(300),
  @schemaname as sysname,
  @tablename  as sysname;

declare c cursor fast_forward for
  select table_schema, table_name
  from information_schema.tables
  where table_type = 'base table';

open c

fetch next from c into @schemaname, @tablename;

while @@fetch_status = 0
begin
  set @sql =
    N'exec sp_spaceused N'''
    + quotename(@schemaname) + N'.'
    + quotename(@tablename) + N''';';
  print @sql;
/*
    拼接形成的SQL:
    exec sp_spaceused N'[dbo].[Employees]';
    exec sp_spaceused N'[HR].[Employees]';
    exec sp_spaceused N'[Production].[Suppliers]';
    exec sp_spaceused N'[Production].[Categories]';
    exec sp_spaceused N'[Production].[Products]';
    exec sp_spaceused N'[Sales].[Customers]';
    ...
*/
  exec(@sql);

  fetch next from c into @schemaname, @tablename;
end

close c;

deallocate c;
go

-- 10.6.2 sp_executesql
declare @sql as nvarchar(100);

set @sql = N'select orderid, custid, empid, orderdate
from sales.orders
where orderid = @orderid;';

exec sp_executesql
  @stmt = @sql,                     -- 指定包含想要运行的批处理代码的unicode字符串;
  @params = N'@orderid as int',     -- 包含@stmt中所有输入/输出参数的声明的unicode字符串;
  @orderid = 10248;                 -- 为输入/输出参数指定取值,各参数之间用逗号隔开;
go

-- 使用sp_executesql查询数据库所有表的行数;
declare @counts table(
  schemaname sysname not null,
  tablename sysname not null,
  numrows int not null,
  primary key(schemaname, tablename));

declare
  @sql as nvarchar(350),
  @schemaname as sysname,
  @tablename  as sysname,
  @numrows    as int;

declare c cursor fast_forward for
  select table_schema, table_name       -- 获取数据库中表和视图的名称列表;
  from information_schema.tables;

open c

fetch next from c into @schemaname, @tablename;

while @@fetch_status = 0
begin
  set @sql =
    N'set @n = (select count(*) from '
    + quotename(@schemaname) + N'.'
    + quotename(@tablename) + N');';          -- 构造动态SQL批处理查询当前对象中的行数;

  exec sp_executesql
    @stmt = @sql,
    @params = N'@n as int output',
    @n = @numrows output;

  insert into @counts(schemaname, tablename, numrows)
    values(@schemaname, @tablename, @numrows);

  fetch next from c into @schemaname, @tablename;
end

close c;

deallocate c;

select schemaname, tablename, numrows
from @counts;
go

-- 10.6.3 在pivot中使用动态SQL
select *
from (select shipperid, year(orderdate) as orderyear, freight
      from sales.orders) as d
pivot(sum(freight) for orderyear in([2006],[2007],[2008])) as p;

-- 假如事先不知道pivot中in子句中应该指定哪些值,可以使用动态SQL;
declare
  @sql       as nvarchar(1000),
  @orderyear as int,
  @first     as int;

declare c cursor fast_forward for
  select distinct(year(orderdate)) as orderyear
  from sales.orders
  order by orderyear;

set @first = 1;

set @sql = N'select *
from (select shipperid, year(orderdate) as orderyear, freight
      from sales.orders) as d
  pivot(sum(freight) for orderyear in(';

open c

fetch next from c into @orderyear;

while @@fetch_status = 0
begin
  if @first = 0
    set @sql = @sql + N','
  else
    set @first = 0;

  set @sql = @sql + quotename(@orderyear);

  fetch next from c into @orderyear;
end

close c;

deallocate c;

set @sql = @sql + N')) as p;';

exec sp_executesql @stmt = @sql;
go


-- 10.7 例程: 用户定义函数、存储过程、触发器
--      说明: 涉及数据处理的任务时T-SQL是更好的选择;涉及交互逻辑、字符串处理、计算密集型的操作ORM是更好的选择;
-- 10.7.1 用户定义函数(UDF):标量UDF和表值UDF;
--        注意:UDF不能对数据库的任何架构和数据进行修改,即使副作用很小(系统会设置某种信息)的函数也不行,例如rand() -- 返回一个随机值
--                                                                                                   newid() -- 返回一个全局唯一标识符;
use testdb;
if object_id('dbo.fn_age') is not null drop function dbo.fn_age;
go

create function dbo.fn_age(@birthdate as datetime,@eventdate as datetime)   -- 定义函数;
returns int
as
begin
  return
    datediff(year, @birthdate, @eventdate)                                  -- 根据生日计算年龄;
    - case when 100 * month(@eventdate) + day(@eventdate)
              < 100 * month(@birthdate) + day(@birthdate)
           then 1 else 0
      end
end
go

select
  empid, firstname, lastname, birthdate,
  dbo.fn_age(birthdate, current_timestamp) as age
from hr.employees;

-- 10.7.2 存储过程
--        优点:(1)封装逻辑处理;(2)更好的控制安全性,可以授予某个存储过程的权限;
--             (3)在存储过程中可以整合所有的错误处理;(4)可以提高执行性能(重用以前缓存过的执行计划内容、中间处理过程不需要往返网络通信流量);
use testdb;
if object_id('sales.usp_getcustomerorders', 'p') is not null
  drop proc sales.usp_getcustomerorders;
go

create proc sales.usp_getcustomerorders         -- 创建存储过程;
  @custid   as int,
  @fromdate as datetime = '19000101',
  @todate   as datetime = '99991231',
  @numrows  as int output
as
set nocount on;

    select orderid, custid, empid, orderdate
from sales.orders
where custid = @custid
  and orderdate >= @fromdate
  and orderdate < @todate;

set @numrows = @@rowcount;
go

declare @rc as int;

exec sales.usp_getcustomerorders
  @custid   = 1, -- also try with 100
  @fromdate = '20070101',
  @todate   = '20080101',
  @numrows  = @rc output;

select @rc as numrows;
go

-- 10.7.3 触发器:是一种特殊的存储过程,不能被显示执行,必须依附于一个时间的过程,即只要事件发生就会调用触发器,运行它的代码;
--               SQL Server支持把触发器和两种类型的事件相关联:数据操作事件(如insert)和数据定义事件(create table)分别对应DML触发器和DDL触发器;
--               在SQL Server中,触发器是按照语句触发的,而不是按照被修改的行触发的;

-- DML触发器:(1) after触发器:在与之关联的事件完成后才触发,只有在持久化表上定义这种触发器;
--           (2) instead of触发器:为了代替与之关联的事件操作,可以在持久化的表或视图上定义这种类型的触发器;
-- 在触发器的代码中,可以访问insert of和delete的两个表,表中含有导致触发器触发的修改操作而影响的记录行;
--                 inserted表包含执行insert和update语句时受影响行的新数据的镜像;
--                 delete表包含执行delete和update语句时受影响的旧数据的镜像;
-- 对于instead of触发器,inserted和deleted表包含导致触发器触发的修改操作打算要影响的行;

-- DML触发器
use tempdb;
if object_id('dbo.t1_audit', 'u') is not null drop table dbo.t1_audit;
if object_id('dbo.t1', 'u') is not null drop table dbo.t1;

create table dbo.t1(
  keycol  int         not null primary key,
  datacol varchar(10) not null);


create table dbo.t1_audit(
  audit_lsn  int         not null identity primary key,
  dt         datetime    not null default(current_timestamp),   -- 记录插入操作发生的日期和事件;
  login_name sysname     not null default(suser_sname()),       -- 记录执行插入操作的登录用户的用户名;
  keycol     int         not null,
  datacol    varchar(10) not null);
go

create trigger trg_t1_insert_audit on dbo.t1 after insert
as
set nocount on;

insert into dbo.t1_audit(keycol, datacol)
  select keycol, datacol from inserted;
go

insert into dbo.t1(keycol, datacol) values(10, 'a');
insert into dbo.t1(keycol, datacol) values(30, 'x');
insert into dbo.t1(keycol, datacol) values(20, 'g');

select audit_lsn, dt, login_name, keycol, datacol
from dbo.t1_audit;
go

-- DDL触发器
-- SQL Server支持在两个作用域内创建DDL触发器(数据库作用域和服务器作用域):
--    (1) 对于具有数据库作用域的事件(如create table),可以创建数据库作用域内的触发器;
--    (2) 对于具有服务器作用域的事件(如create datebase),可以创建服务器作用域内的触发器;
-- 注:SQL Server只支持after类型的DDL触发器,而不支持before、instead of类型的DDL触发器;
-- 可以通过查询eventdata函数(该函数将事件信息作为XML值返回),可以获取关于导致触发器触发的事件信息,再用XQuery表达式从XML值中提取各种事件属性,如提交事件、事件类型、登录名称等;

-- use master;
-- if db_id('testdb') is not null drop database testdb;        -- 创建testdb;
-- create database testdb;
-- go
-- use testdb;
-- go

if object_id('dbo.auditddlevents', 'u') is not null
  drop table dbo.auditddlevents;

create table dbo.auditddlevents(                               -- 创建表用于保存审核信息;
  audit_lsn        int      not null identity,
  posttime         datetime not null,
  eventtype        sysname  not null,
  loginname        sysname  not null,
  schemaname       sysname  not null,
  objectname       sysname  not null,
  targetobjectname sysname  null,
  eventdata        xml      not null,                          -- XML数据类型,保存触发器从事件信息中提取到的单个属性,在evnetdata列中也可以保存完整的事件信息;
  constraint pk_auditddlevents primary key(audit_lsn));
go

create trigger trg_audit_ddl_events
  on database for ddl_database_level_events
as
set nocount on;

declare @eventdata as xml;
set @eventdata = eventdata();                                  -- 使用eventdata()函数获取事件信息并保存到@eventdata;

insert into dbo.auditddlevents(                                -- 把这些属性和完整事件信息的XML值作为新行插入到审核表中;
  posttime, eventtype, loginname, schemaname,
  objectname, targetobjectname, eventdata)
  values(
    @eventdata.value('(/event_instance/posttime)[1]',         'varchar(23)'),   -- 使用XQuery表达式,通过.value方法获取事件信息的各属性;
    @eventdata.value('(/event_instance/eventtype)[1]',        'sysname'),
    @eventdata.value('(/event_instance/loginname)[1]',        'sysname'),
    @eventdata.value('(/event_instance/schemaname)[1]',       'sysname'),
    @eventdata.value('(/event_instance/objectname)[1]',       'sysname'),
    @eventdata.value('(/event_instance/targetobjectname)[1]', 'sysname'),
    @eventdata);
go

-- test trigger trg_audit_ddl_events
create table dbo.t1(col1 int not null primary key);
alter table dbo.t1 add col2 int null;
alter table dbo.t1 alter column col2 int not null;
create nonclustered index idx1 on dbo.t1(col2);
go

select * from dbo.auditddlevents;
go


-- cleanup
-- use master;
-- if db_id('testdb') is not null drop database testdb;
-- go

-- 10.8 错误处理
-- 10.8.1 简单样例
begin try
  print 10/2;
  print 'no error';
end try
begin catch
  print 'error';
end catch
go

begin try
  print 10/0;
  print 'no error';
end try
begin catch
  print 'error';
end catch
go

-- 10.8.2 一个更详细的样例;
use tempdb;
if object_id('dbo.employees') is not null drop table dbo.employees;
create table dbo.employees(
  empid   int         not null,
  empname varchar(25) not null,
  mgrid   int         null,
  constraint pk_employees primary key(empid),
  constraint chk_employees_empid check(empid > 0),
  constraint fk_employees_employees
    foreign key(mgrid) references dbo.employees(empid));
go


begin try
  insert into dbo.employees(empid, empname, mgrid)
    values(1, 'emp1', null);
  -- also try with empid = 0, 'a', null
end try

begin catch
  if error_number() = 2627                          -- error_number()函数展示错误代码;
  begin
    print 'handling pk violation...';
  end
  else if error_number() = 547
  begin
    print 'handling check/fk constraint violation...';
  end
  else if error_number() = 515
  begin
    print 'handling null violation...';
  end
  else if error_number() = 245
  begin
    print 'handling conversion error...';
  end
  else
  begin
    print 'handling unknown error...';
  end


  print 'error number  : ' + cast(error_number() as varchar(10));
  print 'error message : ' + error_message();
  print 'error severity: ' + cast(error_severity() as varchar(10));
  print 'error state   : ' + cast(error_state() as varchar(10));
  print 'error line    : ' + cast(error_line() as varchar(10));
  print 'error proc    : ' + coalesce(error_procedure(), 'not within proc');
end catch
go

-- 创建存储过程封装上述错误处理代码;
if object_id('dbo.usp_err_messages', 'p') is not null
  drop proc dbo.usp_err_messages;
go

create proc dbo.usp_err_messages
as
set nocount on;

if error_number() = 2627
begin
  print 'handling pk violation...';
end
else if error_number() = 547
begin
  print 'handling check/fk constraint violation...';
end
else if error_number() = 515
begin
  print 'handling null violation...';
end
else if error_number() = 245
begin
  print 'handling conversion error...';
end
else
begin
  print 'handling unknown error...';
end

print 'error number  : ' + cast(error_number() as varchar(10));
print 'error message : ' + error_message();
print 'error severity: ' + cast(error_severity() as varchar(10));
print 'error state   : ' + cast(error_state() as varchar(10));
print 'error line    : ' + cast(error_line() as varchar(10));
print 'error proc    : ' + coalesce(error_procedure(), 'not within proc');
go

-- 只需要调用存储过程就可以显示错误信息,这样就可以将错误处理程序和实际运行程序分离,在另一个地方对错误处理代码进行维护;
begin try
  insert into dbo.employees(empid, empname, mgrid)
    values(1, 'emp1', null);
end try

begin catch
  exec dbo.usp_err_messages;
end catch


-- 使用程序集;
USE testdb;
IF OBJECT_ID('dbo.RegexIsMatch', 'FS') IS NOT NULL
 DROP FUNCTION dbo.RegexIsMatch;
GO

CREATE FUNCTION dbo.RegexIsMatch
 (@inpstr AS NVARCHAR(MAX), @regexstr AS NVARCHAR(MAX))
RETURNS BIT
EXTERNAL NAME testdb.[testdb.digits].RegexIsMatch;
GO

-- juset a test

SELECT dbo.RegexIsMatch(
 N'dejan@solidq.com',
 N'^([\w-]+\.)*?[\w-]+@[\w-]+\.([\w-]+\.)*?[\w]+$');

-- 查看数据库开启的端口号
SELECT *
FROM sys.dm_tcp_listener_states;


