-- drop table if exits public.atguigu_greenplum_order_info;
create table public.atguigu_greenplum_order_info (
    order_id bigint default null
    ,user_id varchar(100) default null
    ,order_date varchar(100) default null
    ,amount integer default null
);

-- drop table if exits public.atguigu_greenplum_score_info;
create table public.atguigu_greenplum_score_info (
    stu_id bigint default null
    ,course varchar(100) default null
    ,score integer default null
);