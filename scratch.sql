CREATE TABLE "dmddata"."dq_chk_ccm_zxjtcrm_jg_cst_basic_info_result" (
  "cst_code" varchar(255) COLLATE "pg_catalog"."default" DEFAULT NULL NOT NULL,
  "cst_name" varchar(255) COLLATE "pg_catalog"."default" DEFAULT NULL,
  "cert_no" varchar(255) COLLATE "pg_catalog"."default" DEFAULT NULL,
  "cert_type" varchar(255) COLLATE "pg_catalog"."default" DEFAULT NULL,  -- 字典值参考：证件类型代码表：CERT_TYPE_CD
  "registration_state" varchar(255) COLLATE "pg_catalog"."default" DEFAULT NULL,
  "deal_way" varchar(255) COLLATE "pg_catalog"."default" DEFAULT NULL,   -- 处理方式
  "prob_rmk" varchar(255) COLLATE "pg_catalog"."default" DEFAULT NULL,   -- 问题备注
  "recdate" date DEFAULT NULL
);
comment on table dmddata.dq_chk_ccm_zxjtcrm_jg_cst_basic_info_result is 'CCRM外部实体表脏数据处理结果表';



ALTER TABLE dmddata.dq_chk_ccm_zxjtcrm_jg_cst_basic_info_result  ALTER COLUMN recdate  TYPE integer USING (recdate::integer);