-- drop table if exits public.atguigu_greenplum_order_info;
create table public.atguigu_greenplum_order_info (
    order_id bigint default null
    ,user_id varchar(100) default null
    ,order_date varchar(100) default null
    ,amount integer default null
);

-- drop table if exits public.atguigu_greenplum_score_info;
-- truncate public.test_pg_grammar_stu_info1
create table public.test_pg_grammar_stu_info1 (
    stu_id bigint default null
    ,name varchar(100) default null
    ,age integer default null
);
insert into public.test_pg_grammar_stu_info1 values('1', 'jason', '18');
insert into public.test_pg_grammar_stu_info1 values('2', 'tom', '19');
insert into public.test_pg_grammar_stu_info1 values('3', 'jack', '20');


-- drop table if exits public.atguigu_greenplum_score_info;
-- truncate public.test_pg_grammar_stu_info2
create table public.test_pg_grammar_stu_info2 (
    stu_id bigint default null
    ,name varchar(100) default null
    ,score integer default null
);
insert into public.test_pg_grammar_stu_info2 values('1', 'jason', '90');
insert into public.test_pg_grammar_stu_info2 values('2', 'tom', '93');
insert into public.test_pg_grammar_stu_info2 values('4', 'james', '95');

select *
from public.test_pg_grammar_stu_info1 as a, public.test_pg_grammar_stu_info2 as b;

select *
from public.test_pg_grammar_stu_info2;