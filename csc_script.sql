CREATE OR REPLACE FUNCTION dmddata.dm_func_index_jgyw(lastjyrq varchar(8),curjyrq varchar(8),OUT errcode INT,OUT errmsg text)
AS $func$
DECLARE RECCNT INT;
        curjyrq_int INT;
        lastjyrq_int INT;
        dealfuncname varchar(50);
BEGIN
    --curjyrq :='20240220';
    curjyrq_int  := cast(curjyrq as int);
    lastjyrq_int := cast(lastjyrq as int);
    dealfuncname := 'dm_func_index_jgyw';--这个参数主要是结果表中进行标识是哪个存储过程产生的数据
    ------准备当日数据的结果表,将数据先放入临时表中
    DROP TABLE IF EXISTS TEMP_DM_ALLBIZ_IDX;
    CREATE TABLE TEMP_DM_ALLBIZ_IDX AS
    SELECT * FROM DM_ALLBIZ_IDX
           WHERE 1<>1;
    DROP TABLE IF EXISTS TEMP_DM_DB_NOONEID_INFO;
    CREATE TABLE TEMP_DM_DB_NOONEID_INFO AS
    SELECT * FROM DM_DB_NOONEID_INFO
           WHERE 1<>1;
    ------托管部的托管产品情况
    DROP TABLE IF EXISTS temp_tgb_tgywtj;
    CREATE TABLE temp_tgb_tgywtj as
    SELECT a.l_fundid,                      --账套号码
           a.vc_code     CPDM,              --产品代码,
           a.vc_fullname CPMC,              --产品名称,
           a.vc_glr      GLRMC,             --管理人名称
           cast('' as varchar(20))   GLR_G, --管理人G码,
           cast(0  as decimal(30,2)) ZCJZ   --资产净值
           from dwodata.fce_tgcbs_tfundinfo a
           join dwodata.fce_tgcbs_tsysinfo i on a.l_fundid = i.l_id
           where CAST(to_char(a.start_dt, 'yyyymmdd') AS INTEGER) <= curjyrq_int
	    AND   CAST(to_char(a.end_dt, 'yyyymmdd') AS INTEGER) > curjyrq_int
	    AND   a.del_ind <> 'D'
           AND   (cast(to_char(i.d_destory, 'yyyymmdd') as integer)  >= curjyrq_int or cast(to_char(i.d_destory, 'yyyymmdd') as integer)='19000101')
           AND   cast(to_char(a.d_create, 'yyyymmdd') as integer)    <= curjyrq_int
           AND   i.rec_dt_int= curjyrq_int;
    SELECT COUNT(1) FROM temp_tgb_tgywtj INTO RECCNT;
    IF RECCNT=0 THEN
       errcode :=-1;
       errmsg  :='托管部估值系统中未取到'||curjyrq||'的托管规模数据';
       return;
    END IF;
    --估值系统未直接对接CCRM，但是托管人管理平台对接了，所以用名称匹配即可
    UPDATE temp_tgb_tgywtj a
       SET GLR_G = b.G_CODE
       FROM dwodata.cocs_tgpt_zxjt_ppfa_busi_company_all b
       WHERE a.GLRMC = b.name
       and b.rec_dt_int=curjyrq_int;
    UPDATE temp_tgb_tgywtj a
       SET ZCJZ = b.en_zcjz
       FROM  dwodata.fce_tgcbs_tjjmrhjsj b
       WHERE a.l_fundid = b.l_ztbh
       AND   cast(to_char(b.d_rq, 'yyyymmdd') as integer)= curjyrq_int
       AND   b.l_jjjb = 0;
    --这里需要记录日志，对于没有G码的主体信息需要记录
    INSERT INTO DM_DB_NOONEID_INFO
    SELECT curjyrq,'托管部','托管人服务平台',glrmc,'托管业务缺失管理人G码信息'
           FROM temp_tgb_tgywtj
           WHERE glr_g='';
    --删除不完整数据(缺失G码)
    DELETE FROM temp_tgb_tgywtj
           WHERE glr_g='';
    -----托管部的外包产品情况
    DROP TABLE temp_tgb_wbywtj;
    CREATE TABLE temp_tgb_wbywtj AS
    SELECT a.l_fundid,                      --账套号码
           a.vc_code     CPDM,              --产品代码,
           a.vc_fullname CPMC,              --产品名称,
           vc_mc         GLRMC,             --管理人名称
           a.vc_glr      VC_CODE,           --管理人编码
           cast('' as varchar(20))   GLR_G, --管理人G码,
           cast(0  as decimal(30,2)) ZCJZ
           FROM dwodata.foe_hsfa_tfundinfo a
           JOIN dwodata.mta_wbhsfa_tsysinfo i on a.l_fundid = i.l_id
           JOIN dwodata.mta_wbhsfa_tglrxx b on a.vc_glr = b.vc_bh
           WHERE (cast(to_char(i.d_destory, 'yyyymmdd') as integer)  >= curjyrq_int or cast(to_char(i.d_destory, 'yyyymmdd') as integer)='19000101')
           AND   cast(to_char(a.d_create, 'yyyymmdd') as integer)    <= curjyrq_int
           AND   a.rec_dt_int = curjyrq_int
           AND   i.rec_dt_int = curjyrq_int
           AND   b.rec_dt_int = curjyrq_int;
    UPDATE temp_tgb_wbywtj a
           SET GLR_G = b.G_CODE
           FROM dwodata.cocs_tgpt_zxjt_ppfa_busi_company_all b
           WHERE a.GLRMC=b.name
           AND b.rec_dt_int=curjyrq_int;
    UPDATE temp_tgb_wbywtj a
           SET ZCJZ = b.en_zcjz
           FROM  dwodata.foe_hsfa_tjjmrhjsj b
           WHERE a.l_fundid = b.l_ztbh
           AND   cast(to_char(b.d_rq, 'yyyymmdd') as integer)= curjyrq_int
           AND   b.l_jjjb = 0 ;
    --这里需要记录日志，对于没有G码的主体信息需要记录
    INSERT INTO DM_DB_NOONEID_INFO
    SELECT curjyrq,'托管部','托管人服务平台',glrmc,'外包缺失管理人G码信息'
           FROM temp_tgb_tgywtj
           WHERE glr_g='';
    --删除不完整数据(缺失G码)
    DELETE FROM temp_tgb_tgywtj
           WHERE glr_g='';
    --注意:统计托管或者外包产品数量的时候需要考虑到侧袋处理的情形,但是托管规模不会(外包都剔除了侧袋数据，有点怪怪的)
    INSERT INTO TEMP_DM_ALLBIZ_IDX
    SELECT glr_G                ecif_id,   --管理人G码
           glrmc                ecif_name, --管理人名称
           ''                   pcode_id,  --
           ''                   pcode_name,
           b.dm_dp_id           dm_id,
           ''                   org_id,
           b.dp_name            DP_NAME,
           'DM_TGWBPT'          BIZ_MANSYS_ID,
           '托管外包管理平台'   BIZ_MANSYS_NAME,
           ''                   ORDERDATE, --数据日期
           'GM001'              DIGEST_ID,
           '托管业务规模'       DIGEST_NAME,
           ''                   market,
           ''                   marketname,
           ''                   stkcode,
           ''                   stkname,
           COUNT(1)             TG_CNT,    --按照管理人维度，统计在咱们公司托管的产品数量
           SUM(ZCJZ)            TG_ZCJZ    --托管产品的资产规模
           FROM  temp_tgb_tgywtj  a, (SELECT DISTINCT dm_dp_id,dp_name FROM DM_DPINFO) b
           WHERE b.dm_dp_id='DM_TGB'
           AND   a.cpmc not like '%侧袋%'
           AND   a.cpmc not like '%基金S%'
           AND   substr(a.cpdm,-2,1) <> 'S'
           GROUP BY glr_g,glrmc,b.dm_dp_id,b.dp_name;


select * from temp_tgb_tgywtj where substr(cpdm,-2,1) = 'S'

SELECT * FROM DM_ALLBIZ_IDX

INSERT INTO DM_ALLBIZ_IDX
SELECT glr_G                ecif_id,   --管理人G码
       glrmc                ecif_name, --管理人名称
       ''                   pcode_id,  --
       ''                   pcode_name,
       b.dm_dp_id           dm_id,
       ''                   org_id,
       b.dp_name            orgname,
       'DM_TGWBPT'          BIZ_MANSYS_ID,
       '托管外包管理平台'   BIZ_MANSYS_NAME,
       cast(${stat_date} as varchar(8))         ORDERDATE, --数据日期
       'GM002'              DIGEST_ID,
       '外包业务规模'       DIGEST_NAME,
       ''                   market,
       ''                   marketname,
       ''                   stkcode,
       ''                   stkname,
       COUNT(0)             TG_CNT,    --按照管理人维度，统计在咱们公司托管的产品数量
       SUM(ZCJZ)            TG_ZCJZ    --托管产品的资产规模
       FROM  temp_tgb_wbywtj  a, (SELECT DISTINCT dm_dp_id,dp_name FROM DM_DPINFO) b
       WHERE b.dm_dp_id='DM_TGB'
       GROUP BY glr_g,glrmc,b.dm_dp_id,b.dp_name;




    errcode :=0;
    errmsg  :='你好';
    exception
    WHEN OTHERS THEN
        errcode :=-1;
        errmsg  :=SQLERRM;
END;
$func$ LANGUAGE plpgsql;

select * from temp_tgb_tgywtj
select * from DM_DB_NOONEID_INFO

select * from dwodata.fce_tgcbs_tfundinfo

select dmddata.dm_func_index_jgyw('20240219','20240220');

select * from dwodata.fce_tgcbs_tfundinfo

select * from dwodata.mta_wbhsfa_tglrxx   where rec_dt_int='20240220'                  limit 100;

select sum(case when en_zcjz>0 then  en_zcjz else 0 end) zcjz
 from tjjmrhjsj@fa t1 join tfundinfo@fa t2 on t1.l_ztbh=t2.l_fundid
where t1.l_jjjb = 0
  and t1.d_rq = date'2023-12-31'
  and t2.vc_fullname not like '%侧袋%'
  and t2.vc_fullname not like '%基金S%'
  and substr（t2.vc_code,-2,1) <> 'S'
  and t2.d_create < date'2024-1-1'

select * from dwodata.fce_tgcbs_tfundinfo where vc_fullname  like '%侧袋%'
select * from dwodata.foe_hsfa_tfundinfo  where vc_fullname  like '%侧袋%'

select * from dwodata.cocs_tgpt_zxjt_ppfa_busi_company_all where credit_code='' limit 100


DELETE FROM temp_tgb_tgywtj WHERE glr_g='';--数据质量问题,如果存在需要有记录
DELETE FROM temp_tgb_wbywtj WHERE glr_g='';--数据质量问题,如果存在需要有记录

--PB系统客户明细（为客户提供了主经纪商服务）--表权限缺失
/*
SELECT COUNT(T1.CUST_ID)
           ,SUM(CASE WHEN T1.PB_OPEN_DATE >= ${CURR_YEAR_START_TX_DATE_YYYYMMDD} THEN 1
                     ELSE 0
                 END)
           ,SUM(COALESCE(T2.ASSET_TOTAL,0))
       FROM (SELECT A1.CUST_ID
                   ,MIN(A2.PB_OPEN_DATE) AS PB_OPEN_DATE
               FROM DWPDATA.ACT_FUNDS_ACCT A1
         INNER JOIN DWPDATA.ACT_PB_FUNDS_ACCT A2
                 ON A1.FUNDS_ACCT_ID = A2.FUNDS_ACCT_ID
                AND A2.FUNDS_ACCT_PROP_CD <> '6'  --剔除期货
				AND A2.START_DT <= ${TX_DATE}
                AND A2.END_DT > ${TX_DATE}
              WHERE A1.FUNDS_ACCT_TYPE_CD = 'B'   --主资金账号
                AND A1.ORG_ID <>'0000'
                AND A1.START_DT <= ${TX_DATE}
                AND A1.END_DT > ${TX_DATE}
                AND A1.DATA_SRC_TABLE_NAME = 'UCA_KBSSACCT_CUACCT'
           GROUP BY A1.CUST_ID
            ) T1
		LEFT JOIN DWCDATA.CM_DPS_CUST_ASSET_SUM_HIS T2
         ON T1.CUST_ID = T2.CUST_ID
        AND T2.REC_DT = ${TX_DATE_YYYYMMDD}
*/
--交易所席位数据（上海）,需要CRM里面的席位数据入仓,但是这个表需要数据治理
--还有就是交易所的交易量爬虫数据
--对运营管理部导入的（CRM系统数据，从站点导入）席位归属关系表进行处理
UPDATE MANUAL_IMPORT_SEAT_BELONG
       SET BELONG=CASE WHEN BELONG LIKE '研究%' THEN '研究发展部'
                       WHEN BELONG LIKE '机构%' THEN '机构业务部'
                       WHEN BELONG LIKE '托管%' THEN '托管部'
                       WHEN BELONG LIKE '固收%' THEN '固定收益部'
                       WHEN BELONG LIKE '国际%' THEN '国际业务部'
                       WHEN BELONG LIKE '衍生%' THEN '衍生品交易部'
                       WHEN BELONG LIKE '%资产管理%' THEN '资产管理部'
                       WHEN BELONG LIKE '经纪%' THEN '经管委'
                       WHEN BELONG LIKE '交易部' THEN '交易部'
                       WHEN belong LIKE '证金%' THEN '证券金融部'
                  END;
DELETE FROM MANUAL_IMPORT_SEAT_BELONG
       WHERE belong=''
       OR belong IS NULL; --需要进行数据治理(非常重要)

DROP TABLE TEMP_SEAT_INFO;
CREATE TABLE TEMP_SEAT_INFO AS
SELECT cast('SZ' AS VARCHAR(2)) market,       --席位市场
       unit_cd SEATID,                        --席位号码
       ashare_match_amt JYL_A,                --A股交易量，口径待确认
       org_name CUSTNAME,                     --租赁机构
       CAST('' AS VARCHAR(20))  CUST_G,       --机构的G码
       CAST('' AS VARCHAR(50))  SEAT_BELONG,  --席位所属机构
       CAST('' AS VARCHAR(20))  dm_dp_id      --席位所属机构的ID(数据管理部定义)
       FROM manual_import_szse_lease_unit_match_amt_stat_new
       where stat_perd='202312';
INSERT INTO TEMP_SEAT_INFO
SELECT 'SH' MARKET,                       --席位市场
       LEASE_CD,                          --席位号码
       ashare_match_amt JYL_A,            --A股交易量
       belg_org         CUSTNAME,         --租赁机构
       CAST('' AS VARCHAR(20))  CUST_G,       --机构的G码
       CAST('' AS VARCHAR(50))  SEAT_BELONG,   --席位所属机构
       CAST('' AS VARCHAR(20))  dm_dp_id      --席位所属机构的ID(数据管理部定义)
       FROM manual_import_shse_lease_unit_match_amt_stat
       where REPLACE (date,'-','')='202312';
UPDATE TEMP_SEAT_INFO a
       SET CUST_G = b.cst_code
       FROM dwodata.ccm_zxjtcrm_jg_cst_basic_info b
       WHERE CUSTNAME = b.name
       AND cast(to_char(b.start_dt, 'yyyymmdd') as integer) <= ${stat_date}
       AND cast(to_char(b.end_dt, 'yyyymmdd') as integer) > ${stat_date}
       AND b.del_ind <> 'D';
--有限责任公司和有限公司的处理
UPDATE TEMP_SEAT_INFO a
       SET CUST_G = b.cst_code
       FROM dwodata.ccm_zxjtcrm_jg_cst_basic_info b
       WHERE (replace(CUSTNAME,'有限责任公司','有限公司') = b.name or replace(CUSTNAME,'有限公司','有限责任公司') = b.name
              or replace(CUSTNAME,'公司','有限责任公司')  = b.name or replace(CUSTNAME,'公司','有限公司') = b.name
              )
       AND cast(to_char(b.start_dt, 'yyyymmdd') as integer) <= ${stat_date}
       AND cast(to_char(b.end_dt, 'yyyymmdd') as integer) > ${stat_date}
       AND b.del_ind <> 'D'
       AND a.CUST_G=''; --对空的再次进行处理
---不知道为什么，上投摩根基金管理公司 死活无法自动更新，先手工处理一下吧
UPDATE TEMP_SEAT_INFO
       SET CUST_G='G00000000045'
       WHERE CUSTNAME LIKE  '上投摩根基金%'
       AND CUST_G='';
-----此处需要检车CUST_G为空的记录，异常
UPDATE TEMP_SEAT_INFO a
       SET seat_belong = b.belong
       FROM MANUAL_IMPORT_SEAT_BELONG b
       WHERE a.market = b.market
       AND   a.seatid = b.seatid;
UPDATE TEMP_SEAT_INFO ---为了保持数据完整性，对于没有归属关系的统一归入研究所
       SET seat_belong='研究发展部'
       WHERE seat_belong='';
UPDATE TEMP_SEAT_INFO a
       SET dm_dp_id = b.dm_dp_id
       FROM (SELECT DISTINCT dm_dp_id,dp_name FROM DM_DPINFO) b
       WHERE a.seat_belong = b.DP_NAME;
INSERT INTO DM_ALLBIZ_IDX
SELECT cust_g     ecif_id,     --客户唯一码
       custname   ecif_name,   --客户名称
       ''         pcode_id,    --产品户唯一码
       ''         pcode_name,  --产品户名称
       dm_dp_id,               --归属部门标识
       ''         org_id,
       seat_belong,            --归属部门名称
       'DM_CRM',               --数据来源系统
       'CRM系统',              --数据来源系统名称
        ${stat_date}           ORDERDATE,
        CAST('GM003' AS VARCHAR(5)) DIGEST_ID,
	 CAST('出租席位交易量' AS VARCHAR(50)) DIGEST_NAME,
	   ''                      MARKET,
	   ''                      MARKETNAME,
	   ''                      STKCODE,
	   ''                      STKNAME,
        COUNT(0)                  ORDCOUNT,
        SUM(CAST(jyl_a AS DECIMAL(30,2))) ORDAMOUNT
        FROM  TEMP_SEAT_INFO
        GROUP BY cust_g,custname,dm_dp_id,seat_belong;

--需要收集总交易量信息，统计出租出去却没有使用的席位
--'GM004','零交易量席位';--(预留，现在数据不规范，只按照A股交易量统计了，这个只是占位用的，后面是要用全部的交易量来计算)
INSERT INTO DM_ALLBIZ_IDX
SELECT cust_g     ecif_id,     --客户唯一码
       custname   ecif_name,   --客户名称
       ''         pcode_id,    --产品户唯一码
       ''         pcode_name,  --产品户名称
       dm_dp_id,               --归属部门标识
       ''         org_id,      --业务归属营业部，只对经纪有效
       seat_belong,            --归属部门名称
       'DM_CRM',               --数据来源系统
       'CRM系统',              --数据来源系统名称
        ${stat_date}           ORDERDATE,
        CAST('GM004' AS VARCHAR(5)) DIGEST_ID,
	 CAST('零交易席位数量' AS VARCHAR(50)) DIGEST_NAME,
	   ''                      MARKET,
	   ''                      MARKETNAME,
	   ''                      STKCODE,
	   ''                      STKNAME,
        COUNT(0)                  ORDCOUNT,
        0                         ORDAMOUNT
        FROM  TEMP_SEAT_INFO
        WHERE CAST(jyl_a AS DECIMAL(30,2))=0
        GROUP BY cust_g,custname,dm_dp_id,seat_belong;
--交易单元流量费（数仓表），归入管理会计实现，这个属于支出，单独做出来意义不大
--dmddata.EDW_M_CUST_CRM_ORDER_TRAFFIC_FEE_SUM_MONTH
--恒生、迅投、专业订单系统的算法交易菜单能够标识该客户是否用了我司的算法交易
--通过菜单来判断是否使用了公司的算法交易
/*缺少入仓数据，未实现算法交易
--恒生PB(PB1、PB2)
SELECT * FROM VC_CAPITAL_ACCOUNT
--专业订单系统
select * from COS_STRG_LIMITS
--迅投PB系统
SELECT DISTINCT	( a.NAME ) as '资金账号',
       CASE	a.types WHEN 1 THEN	'期货'
	                WHEN 2 THEN	'股票'
					WHEN 3 THEN	'信用'
					WHEN 4 THEN	'贵金属'
					WHEN 6 THEN	'股票期权'
					WHEN 7 THEN	'沪港通'
					WHEN 10 THEN	'股转'
					WHEN 11 THEN	'深港通'
	   END AS '账号类型' FROM	account_account a
	   JOIN account_subaccount s ON a.id = s.parent_account_id
	   AND s.STATUS = 1	JOIN account_algotypeinfo al ON a.id = al.account_id
	   AND (	al.content LIKE "%\"POV\", [ 1, \"\" ]%" 	OR al.content LIKE "%\"STEP\", [ 0, \"\" ]%" 	OR al.content LIKE "%\"STRICTTWAP\", [ 1, \"\" ]%" 	OR al.content LIKE "%\"TWAP\", [ 1, \"\" ]%" 	OR al.content LIKE "%\"VWAP\", [ 1, \"\" ]%" 	OR al.content LIKE "%\"VWAPPLUS\", [ 1, \"\" ]%" 	OR al.content LIKE "%[ \"POV\", [ 1, \"\" ], \"STEP\", [ 0, \"\" ], \"STRICTTWAP\", [ 1, \"\" ], \"TWAP\", [ 1, \"\" ], \"VWAP\", [ 1, \"\" ], \"VWAPPLUS\", [ 1, \"\" ] ]%" 	) ORDER BY	a.types,	a.NAME;
*/
---拜访记录
--SELECT * FROM public.undel_service_visit_rec_view LIMIT 10


select * from dwedata.fcrm_dict_tree_label limit 100;

select * from dwodata.fcrm_zxjtfcrm_dict_tree_label                    limit 100;


select * from public.all_cb_undel_view


select * from dwodata.fcrm_public_undel_cb_other_ways_view             limit 100;

