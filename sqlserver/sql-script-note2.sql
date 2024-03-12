------------------------------------------------------------------------------------------------------------------------
-----                                    1  逻辑查询处理                                                            -----
------------------------------------------------------------------------------------------------------------------------
-- SQL Server中由查询优化器生成实际执行计划,包括以何种顺序访问表,使用什么访问方法和索引、应用哪种联接算法...
-- 1.1 逻辑查询处理的各个阶段
(5)select (5-2) distinct (5-3) top(<top_specification>) (5-1) <select_list>
(1)from  (1-J) <left_table> <join_type> join <right_table> on <on_predicate>
       | (1-A) <left_table> <apply_type> apply <right_table_expression> as <alias>
       | (1-P) <left_table> pivot (<pivot_specification>) as <alias>
       | (1-U) <left_table> unpivot (<pivot_specification>) as <alias>
(2)where <where_predicate>
(3)group by <group_by_specification>
(4)having <having_predicate>
(6)order by <order_by_list>;

-- 1.2 一个查询实例
set nocount on;
use tempdb;

if object_id('dbo.orders') is not null drop table dbo.orders;
if object_id('dbo.customers') is not null drop table dbo.customers;
go

create table dbo.customers
(
  customerid  char(5)     not null primary key,
  city        varchar(10) not null
);

create table dbo.orders
(
  orderid    int     not null primary key,
  customerid char(5)     null references customers(customerid)
);
go


insert into dbo.customers(customerid, city) values('fissa', 'madrid');
insert into dbo.customers(customerid, city) values('frndo', 'madrid');
insert into dbo.customers(customerid, city) values('krlos', 'madrid');
insert into dbo.customers(customerid, city) values('mrphs', 'zion');

insert into dbo.orders(orderid, customerid) values(1, 'frndo');
insert into dbo.orders(orderid, customerid) values(2, 'frndo');
insert into dbo.orders(orderid, customerid) values(3, 'krlos');
insert into dbo.orders(orderid, customerid) values(4, 'krlos');
insert into dbo.orders(orderid, customerid) values(5, 'krlos');
insert into dbo.orders(orderid, customerid) values(6, 'mrphs');
insert into dbo.orders(orderid, customerid) values(7, null);

select * from dbo.customers;
select * from dbo.orders;

select c.customerid, count(o.orderid) as numorders
from dbo.customers as c
left outer join dbo.orders as o on c.customerid = o.customerid
where c.city = 'madrid'                 -- 注意： on筛选器应用在添加外部行之前,where筛选器在添加外部行之后;
group by c.customerid
having count(o.orderid) < 3             -- 注意： 使用外连接时注意counter(*)和count(o.orderid)的区别;
order by numorders;


-- 注意： select中的语句同时发生
-- update dbo.T1 set c1 = c2, c2 = c1;
-- update dbo.T1 set c1 = c1 + (select max(c1) from dbo.T1);

