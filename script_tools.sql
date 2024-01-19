-- 1.对比两张表是否相同
-- 2.拉链表的建表逻辑
insert overwrite table dw_product_2
select
    goods_id,                -- 商品编号
    goods_status,            -- 商品状态
    createtime,              -- 商品创建时间
    modifytime,              -- 商品修改时间
    modifytime as dw_start_date,    -- 生效日期
    '9999-12-31' as dw_end_date     -- 失效日期
from ods_product_2
where dt = '2019-12-20';

update t_product_2 set goods_status = '待售', modifytime = '2019-12-21' where goods_id = '001';
insert into t_product_2(goods_id, goods_status, createtime, modifytime)
values ('005', '待审核', '2019-12-21', '2019-12-21'),
        ('006', '待审核', '2019-12-21', '2019-12-21');

-- 3.存在重复行的表left join结果验证