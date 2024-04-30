



convert(varchar(12), OPDATE, 112) = convert(varchar(12), DATEADD(day, -1, getdate()), 112);

delete from dmddata.uif_wande_asharemanagementholdreward
where cast(to_char(OPDATE, 'yyyymmdd') as integer) = cast(to_char(current_date - interval '1 day', 'yyyymmdd') as integer);

-- DM数据交换任务_统一资讯平台_万得_asharemanagementholdreward
--
-- DM数据交换任务_统一资讯平台_万得_asharemanagement
--
-- DM数据交换任务_统一资讯平台_万得_asharebalancesheet
--
-- DM数据交换任务_统一资讯平台_万得_asharemanagementexpense
--
-- DM数据交换任务_统一资讯平台_万得_asharestaff