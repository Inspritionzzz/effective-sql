/*
第一部分：数据类型
*/
-- 一、基本数据类型
--- 案例操作
--1. 建表
create table stu
(
    id    int,
    name  text,
    age   smallint,
    eight double precision
);

--2. 插入数据
insert into stu
values (1, 'zhangsan', 18, 70.00),
       (2, 'lisi', 19, 72.00),
       (3, 'wangwu', 20, 90.00),
       (4, 'zhaoliu', 30, 80.50);

--3. 全表查询
select *
from stu;


-- 复杂数据类型
--- 1. 枚举类型
--- 创建枚举类型
create type weeks as
    enum ('Mon','Tue','Wed','Thu','Fri','Sat','Sun');

--- 建表
create table user_weeks
(
    user_name text,
    week      weeks
);

--- 插入数据
insert into user_weeks (user_name, week)
values ('zhangsan', 'Mon'),
       ('lisi', 'Fri'),
       ('wangwu', 'Sat'),
       ('zhanoliu', 'Sun');

--- 查询数据
select *
from user_weeks;


--- 2. 几何数据类型
--- 建表
create table geometric_shapes
(
    id          serial primary key,
    point_col   point,
    lseg_col    lseg,
    polygon_col polygon
);

--- 插入数据
insert into geometric_shapes (point_col, lseg_col, polygon_col)
values (point(1, 2), lseg '[(0,0),(2,2)]', polygon '((0,0),(1,1),(2,2),(3,3),(4,4))');

--- 查询数据
select *
from geometric_shapes;

--- 根据点查询数据
select *
from geometric_shapes
where point_col <-> point(1, 2) < 0.0001;

--- 根据线段查询数据
select *
from geometric_shapes
where lseg_col = '[(0,0),(2,2)]';

--- 根据多边形查询
select *
from geometric_shapes
where polygon_col ~= '((0,0),(1,1),(2,2),(3,3),(4,4))';

-- 3. 网络地址类型
--- 建表
create table network_addresses
(
    id          serial primary key,
    ip_address  inet,
    network     cidr,
    mac_address macaddr
);
--- 插入数据
insert into network_addresses (ip_address, network, mac_address)
values ('192.168.1.1/24', '192.168.1.0/24', '08:00:2b:01:02:03');


--- 查询数据
select *
from network_addresses;

--- 查询特定的ip地址
select *
from network_addresses
where ip_address = '192.168.1.1/24';
select *
from network_addresses
where host(ip_address) = '192.168.1.1';

--- 查询特定的网络
select *
from network_addresses
where network = '192.168.1.0/24';

--- 查询特定的MAC地址
select *
from network_addresses
where mac_address = '08:00:2b:01:02:03';


-- 4. JSON类型
--- 建表
create table json_demo
(
    id   serial primary key,
    data json
);
--- 插入数据
insert into json_demo (data)
values ('{
  "name": "zhangsan",
  "age": 18
}');


--- 查询
select *
from json_demo;
select data ->> 'name' as name
from json_demo
where id = 1;



-- 5. 数组类型
--- 建表
create table array_demo
(
    id  serial primary key,
    num int[]
);
--- 插入数据
insert into array_demo (num)
values ('{1,2,3,4,5}');
--- 查询
select *
from array_demo;
select num[1] as num
from array_demo;
select unnest(num) as num
from array_demo;


-- 6. 复合数据类型
--- 创建复合类型
create type addr as (
    street text,
    city text,
    post_code bigint
    );

--- 建表
create table emp
(
    id      serial primary key,
    name    text,
    address addr
);

--- 插入数据
insert into emp (name, address)
values ('zhangsan', ROW ('huilongguan','beijing',100001)),
       ('lisi', ROW ('tiantongyuan','beijing',100002));

--- 查询数据
select *
from emp;
select name, (address).post_code
from emp;


/*
第二部分：GreenPlum的DDL操作
*/
-- 一、库相关的操作
/*
TODO 建库语法
CREATE DATABASE name
[ [WITH] [OWNER [=] dbowner] -- 指定当前库的所有者
[TEMPLATE [=] template] -- 指定一个数据库模板
[ENCODING [=] encoding] -- 指定当前数据库的编码
[TABLESPAC [=] tablespace] -- 指定当前数据库数据的存储位置
[CONNECTIONE LIMIT [=] connlimit ] ] -- 限制当前数据库最大的客户端连接数
*/

-- 1. 创建数据库
create database mydb1
    with owner gpadmin
    encoding 'utf-8'
    tablespace pg_default
    connection limit 10;


-- 2. 切换数据库
\c db_name;

-- 3. 给当前数据库创建schema
-- 当前数据库的一个分组管理工具
create schema my_sc1;

-- 4. 显示所有的库
\l;
select *
from pg_database;

-- 5. 删除数据库
drop database mydb1;



-- 二、表相关的操作
/*
TODO 建表语法
CREATE [EXTERNAL] TABLE table_name(  -- [EXTERNAL] 创建外部表的关键字
 column1 datatype [NOT NULL] [DEFAULT] [CHECK] [UNIQUE], -- 针对当前一个字段的一些约束
 column2 datatype,
 column3 datatype,
 .....
 columnN datatype,
 [PRIMARY KEY()]  -- 指定当前主键
)[ WITH ()] -- 针对当前表定义数据的追加方式，定义压缩格式 或者压缩级别
 [LOCATION()] -- 如果创建的是外部表，那必须指定location的位置
 [FORMAT] -- 定义当前表的数据的存储格式
 [COMMENT] -- 针对当前表的注释信息
 [PARTITION BY] -- 指定分区字段 同时它也是创建分区表的关键字
 [DISTRIBUTE BY ()] -- 指定分布数据的键值
*/
-- 1. 内部表
--- 建表
create table employees
(
    employees_id serial primary key,
    name         varchar(100),
    department   varchar(100),
    hire_date    date
);

--- 插入数据
insert into employees (name, department, hire_date)
VALUES ('zhangsan', 'IT', '2023-01-01'),
       ('lisi', 'IT', '2023-01-02');


--- 查询数据
select *
from employees;

-- 2. 外部表
--- 准备一个外部文件 employee_data.csv

-- 建表
create external table ext_employees(
    employee_id varchar(100),
    name varchar(100),
    department varchar(100),
    hire_date varchar(100)
    )
    location ('gpfdist://hadoop102:8081/employee_data.csv')
    format 'CSV';

-- 查询数据
select *
from ext_employees;


-- 3. 修改表
--- 3.1 修改表名
alter table stu
    rename to stu1;

--- 3.2 修改列
---- 添加列
alter table stu1
    add column addr varchar(200);

--- 更新列
alter table stu1
    rename addr to addr1;
alter table stu1
    alter column age type int;
alter table stu1
    alter column age type smallint;
alter table stu1
    alter column age type smallint;


--- 3.3 删除表
drop table stu1;

--- 3.4 清除表
-- TODO 注意事项：清除表的时候只能清除内部表，外部表是不能清除的
truncate table employees;
truncate table ext_employees;


/*
第三部分： DML（Data Manipulation Language）数据操作
*/
-- 一、数据导入
--1. copy的方式导入数据
/*
TODO 导入数据语法
COPY table_name FROM file_path DELIMITER ‘字段之间的分隔符’;
*/
--- 建表
create table employees1
(
    name       varchar(100),
    department varchar(100),
    age        int
);

--- 导入数据
copy employees1 from '/home/gpadmin/software/datas/employees1.txt' delimiter ',';

--- 查询结果
select *
from employees1;


-- 2. 通过查询语句向表中插入数据（Insert）
--- 建表
CREATE TABLE employees2
(
    name       VARCHAR(100),
    department VARCHAR(50),
    age        INTEGER
);

--- 导入数据
insert into employees2
values ('zhangsan', 'IT', 18),
       ('lisi', 'HR', 20);

--- 查询数据
select *
from employees2;
--- 根据查询结果插入数据 (追加的模式导入数据)
insert into employees2
select *
from employees1;

-- 3. 查询语句中创建表并加载数据（As Select）
create table employees3 as
select *
from employees1;


-- 二、数据更新和删除
-- 1. 数据更新
/*
语法：
UPDATE table_name
SET column1 = value1, column2 = value2...., columnN = valueN
WHERE [condition];
*/
update employees3
set name='haihai'
where department = 'HR';

-- 2. 删除数据
delete
from employees3
where name = 'haihai';


-- 三、数据导出
copy employees3 to '/home/gpadmin/software/datas/test.txt';


/*
第四部分：GreenPlum的查询
*/
-- 一、准备数据
-- 1. 建表
create external table dept (
    deptno int, --部门编号
    dname text, --部门名称
    loc int --部门位置id
    ) location ('gpfdist://hadoop102:8081/dept.txt')
    format 'text' (delimiter ',');

create external table emp (
    empno int, -- 员工编号
    ename text, -- 员工姓名
    job text, -- 员工岗位（大数据工程师、前端工程师、java工程师）
    sal double precision, -- 员工薪资
    deptno int -- 部门编号
    ) location ('gpfdist://hadoop102:8081/emp.txt')
    format 'text' (delimiter ',');


-- 2. 查询dept
select *
from dept;
select *
from emp;


-- 二、基本查询
-- 1. 列的别名
select ename as en, job j
from emp;

-- 2. Limit语句
select *
from emp
limit 2;
select *
from emp
limit 2 offset 3;


-- 三、分组查询 group by
--- TODO 注意：分组查询操作中 获取的结果只能是 分组标识字段以及聚合结果
---1. 计算emp表每个部门的平均工资
select deptno,
       avg(sal)
from emp
group by deptno;

--- 2. 计算emp每个部门中每个岗位的最高薪水。
select deptno,
       job,
       max(sal) as max_sal
from emp
group by deptno, job;

--- 3. 计算emp每个部门中最高薪水的以及那个人
select ename,
       deptno,
       max(sal) as max_sal
from emp
group by deptno; -- t1

select t2.ename,
       t1.deptno,
       t1.max_sal
from emp t2
         join (select deptno,
                      max(sal) as max_sal
               from emp
               group by deptno) t1
              on t2.deptno = t1.deptno
where t2.sal = t1.max_sal;

--- 4. Having语句
--- 计算emp每个部门中最高薪水的以及那个人，并薪资大于等于3000
select t2.ename,
       t1.deptno,
       t1.max_sal
from emp t2
         join (select deptno,
                      max(sal) as max_sal
               from emp
               group by deptno
               having max(sal) >= 3000) t1
              on t2.deptno = t1.deptno
where t2.sal = t1.max_sal;


-- 四、Join查询 （多表之间的关联查询）
/*
内连接
   -- 语法表达：A a join B b on a.关联字段=b.关联字段
   -- 数据结果集：A 表和 B表的交集数据
外连接
   -- 左外连接
      -- 语法表达：A a left join B b on a.关联字段=b.关联字段
      -- 数据结果集：A 表全部数据和 B表中能够匹配到的数据
   -- 右外连接
      -- 语法表达：A a right join B b on a.关联字段=b.关联字段
      -- 数据结果集：A表中能够匹配到的数据 和 B表全部数据

全连接 -- 语法表达： A a full join B b on a.关联字段=b.关联字段
      -- 数据结果集：A 表和 B表所有的数据

*/

--1. 获取emp和dept的交集数据 (内连接)
select e.empno,
       e.ename,
       e.job,
       e.deptno,
       d.deptno,
       d.dname
from emp e
         join dept d
              on e.deptno = d.deptno;


-- 2. 获取emp的全部数据和dept中能够匹配到的数据
select e.empno,
       e.ename,
       e.job,
       e.deptno,
       d.deptno,
       d.dname
from emp e
         left join dept d
                   on e.deptno = d.deptno;

-- 3. 获取dept的全部数据和emp中能够匹配到的数据
select e.empno,
       e.ename,
       e.job,
       e.deptno,
       d.deptno,
       d.dname
from emp e
         right join dept d
                    on e.deptno = d.deptno;

-- 4. 获取emp的独有的数据
select e.empno,
       e.ename,
       e.job,
       e.deptno,
       d.deptno,
       d.dname
from emp e
         left join dept d
                   on e.deptno = d.deptno
where d.deptno is null;

-- 5. 获取dept独有的数据
select e.empno,
       e.ename,
       e.job,
       e.deptno,
       d.deptno,
       d.dname
from emp e
         right join dept d
                    on e.deptno = d.deptno
where e.deptno is null;

-- 6. 获取emp和dept的全部数据
select e.empno,
       e.ename,
       e.job,
       e.deptno,
       d.deptno,
       d.dname
from emp e
         full join dept d
                   on e.deptno = d.deptno;

-- 7. 获取emp和dept各自独有的数据
select e.empno,
       e.ename,
       e.job,
       e.deptno,
       d.deptno,
       d.dname
from emp e
         full join dept d
                   on e.deptno = d.deptno
where e.deptno is null
   or d.deptno is null;

-- 8. 多表关联查询
--- 建表
create external table location (
    loc int, --部门位置id
    loc_name text --部门位置
    ) location ('gpfdist://hadoop102:8081/location.txt')
    format 'text' (delimiter ',');

--- 查询emp和dept以及location表，获取综合信息
select e.empno,
       e.ename,
       e.job,
       e.deptno,
       d.deptno,
       d.dname,
       d.loc,
       l.loc,
       l.loc_name
from emp e
         join dept d on e.deptno = d.deptno
         join location l on d.loc = l.loc;


-- 9. 笛卡尔积
select empno,
       dname
from emp,
     dept;

-- 10 联合（union & union all）
-- 获取emp和dept的全部数据
--- 实现方式一:
select e.empno,
       e.ename,
       e.job,
       e.deptno,
       d.deptno,
       d.dname
from emp e
         full join dept d
                   on e.deptno = d.deptno;
--- 实现方式二:
select e.empno,
       e.ename,
       e.job,
       e.deptno,
       d.deptno,
       d.dname
from emp e
         left join dept d
                   on e.deptno = d.deptno
union all
select e.empno,
       e.ename,
       e.job,
       e.deptno,
       d.deptno,
       d.dname
from emp e
         right join dept d
                    on e.deptno = d.deptno;



-- 五、排序  order by
/*
GreenPlum中的排序的一些细节
  -- 内存排序 （应对数据量较小的时候 直接在内存中进行排序）
  -- 磁盘排序 （应对数据量较大的时候 直接在磁盘中进行排序）
  -- 索引排序 （按照索引字段进行排序）
  -- 分布式排序：先在各个sg的机器上进行部分排序，最后再讲每个机器的排序结果合并到一起
*/
select *
from emp
order by empno desc;

select *
from emp
order by deptno desc, sal asc;



-- 1. 单行函数
--- 1.1 算术运算函数
select 1 + 2;

--- 1.2 数学函数
--- ceil 向上取值
select ceil(2.5);
select ceil(-2.5);

--- floor 向下取整
select floor(2.5);

--- round 四舍五入
select round(2.3);
select round(2.6);

--- round(a,b)  保留b位小数的四舍五入
select round(2.45, 1);

--- random 0到1之间的随机数值
select random();

--- 1.3 字符串函数
--- substr或substring：截取字符串
select substring('helloworld', 2);
select substring('helloworld', 2, 3);

--- replace ：替换
select replace('Atguigu', 'A', 'a');

--- repeat：重复字符串
select repeat('hello', 2);

--- split_part ：字符串切割
select split_part('a-b-c-d', '-', 3);

--- concat ：拼接字符串
select concat('a', '-', 'b', '-', 'c');

--- concat_ws：以指定分隔符拼接字符串
select concat_ws('-', 'a', 'b', 'c');


--- 1.4 日期函数
--- current_date：当前日期
select current_date;

--- current_timestamp：当前的日期加时间，并且精确的毫秒
select current_timestamp;

--- date_part(text,timestamp)：根据输入的text获取对应的年月日时分秒
select date_part('year', current_timestamp);

--- age：两个日期相差的天数（结束日期减去开始日期的天数）
select age(timestamp '2023-12-08', timestamp '2023-12-05');
select age(timestamp '2024-03-16', timestamp '2023-02-15');

--- to_char：转换日期格式
select to_char(now(), 'yyyy-mm-dd');

--- 日期加减
select timestamp '2023-12-08' - interval '2 days';

--- 1.5 流程控制函数
-- case when a then b [when c then d]* [else e] end
---- 建表
create table emp_sex
(
    name    varchar(100), --姓名
    dept_id varchar(100), --部门id
    sex     varchar(10)   --性别
);

---- 导入数据
copy emp_sex from '/home/gpadmin/software/datas/emp_sex.txt' delimiter ',';
select *
from emp_sex;

---- 完成需求：求出不同部门男女各多少人。结果如下：
/*
dept_Id     男       女
A     		2       1
B     		1       2
*/
select dept_id,
       sex,
       count(*)
from emp_sex
group by dept_id, sex;

--- 主要思路 按照部门分组后进行有条件的聚合统计
select dept_id,
       sum(case sex when '男' then 1 else 0 end) as man,
       sum(case sex when '女' then 1 else 0 end) as wonmen
from emp_sex
group by dept_id;


-- 2. 行列转换函数
--- 2.1 行转列函数
select string_agg(job, '-')
from emp;

--- 2.2 列转行函数 语法：regexp_split_to_table(column,parten)
select regexp_split_to_table('a-b-c-d', '-');

---- 列转行函数-案例操作：
--- 建表
create table movie_info
(
    movie    varchar(100), --电影名称
    category varchar(100)  --电影分类
);
--- 导入数据
insert into movie_info
values ('《疑犯追踪》', '悬疑,动作,科幻,剧情'),
       ('《Lie to me》', '悬疑,警匪,动作,心理,剧情'),
       ('《战狼2》', '战争,动作,灾难');

select *
from movie_info;

--- 完成需求 根据上述电影信息表，统计各分类的电影数量，期望结果如下：
/*
剧情	  2
动作	  3
心理	  1
悬疑	  2
战争	  1
灾难	  1
科幻	  1
警匪	  1
*/
select regexp_split_to_table(category, ',') as categoryname,
       count(*)                             as cnt
from movie_info
group by categoryname;

--- 按照以上结果 获取分类电影数量排名前两位的分类
select regexp_split_to_table(category, ',') as categoryname,
       count(*)                             as cnt
from movie_info
group by categoryname
order by cnt desc
limit 2;

select movie, regexp_split_to_table(category, ',') as categoryname
from movie_info;


-- 3. 窗口函数案例实现
--- 3.1 建表
create table order_info
(
    order_id     varchar(100), --订单id
    user_id      varchar(100), -- 用户id
    user_name    varchar(100), -- 用户姓名
    order_date   varchar(100), -- 下单日期
    order_amount int           -- 订单金额
);

--- 3.2 插入数据
insert into order_info
values ('1', '1001', 'songsong', '2022-01-01', '10'),
       ('2', '1002', 'cangcang', '2022-01-02', '15'),
       ('3', '1001', 'songsong', '2022-02-03', '23'),
       ('4', '1002', 'cangcang', '2022-01-04', '29'),
       ('5', '1001', 'songsong', '2022-01-05', '46'),
       ('6', '1001', 'songsong', '2022-04-06', '42'),
       ('7', '1002', 'cangcang', '2022-01-07', '50'),
       ('8', '1001', 'songsong', '2022-01-08', '50'),
       ('9', '1003', 'huihui', '2022-04-08', '62'),
       ('10', '1003', 'huihui', '2022-04-09', '62'),
       ('11', '1004', 'linlin', '2022-05-10', '12'),
       ('12', '1003', 'huihui', '2022-04-11', '75'),
       ('13', '1004', 'linlin', '2022-06-12', '80'),
       ('14', '1003', 'huihui', '2022-04-13', '94');


--- 3.3 完成需求
--- 需求一：统计每个用户截至每次下单的累积下单总额
select order_id,
       user_id,
       user_name,
       order_date,
       order_amount,
       sum(order_amount) over (partition by user_id order by order_date
           rows between unbounded preceding and current row ) as sum_amount
from order_info;


--- 需求二：统计每个用户每次下单距离上次下单相隔的天数（首次下单按0天算）
---- 步骤一 获取上一次下单日期
select order_id,
       user_id,
       user_name,
       order_date,
       lag(order_date, 1, null) over (partition by user_id order by order_date) as pre_date
from order_info;
--> t1

---- 步骤二 将t1中的 pre_date 和 order_date 进行减法计算 获取相隔天数
select t1.order_id,
       t1.user_id,
       t1.user_name,
       t1.order_date,
       t1.pre_date,
       case
           when age(cast(t1.order_date as timestamp), cast(t1.pre_date as timestamp)) is null then '0'
           else age(cast(t1.order_date as timestamp), cast(t1.pre_date as timestamp))
       end  as diff_date
from (select order_id,
             user_id,
             user_name,
             order_date,
             lag(order_date, 1, null) over (partition by user_id order by order_date) as pre_date
      from order_info) t1;


--- 需求三： 查询每个用户所有下单记录以及每个下单记录所在月份的首/末次下单日期
select order_id,
       user_id,
       user_name,
       order_date,
       order_amount,
       first_value(order_date) over (partition by user_id,substring(order_date,1,7) order by order_date) as first_date,
       last_value(order_date) over (partition by user_id,substring(order_date,1,7) order by order_date
             rows between unbounded preceding and unbounded following) as last_date
    from order_info;

--- 需求四：为每个用户的所有下单记录按照订单金额进行排名
select order_id,
       user_id,
       user_name,
       order_date,
       order_amount,
       rank() over(partition by user_id order by order_amount desc) as rk,
       dense_rank() over(partition by user_id order by order_amount desc) as dr,
       row_number() over(partition by user_id order by order_amount desc) as rn
    from order_info;

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
