do $$
declare
    name text;
begin
    name := 'just a test';
    raise notice 'test %', name;
end $$;


CREATE FUNCTION public.sales_tax(subtotal real) RETURNS real AS $$
BEGIN
    RETURN subtotal * 0.06;
END;
$$ LANGUAGE plpgsql;

select public.sales_tax(100);


create or replace function loop_test(num int, out errcode int)
as $$
begin
    declare count int := num;
	begin
		loop
            exit when count > 100;
            insert into public.one_col_distinct(col1) values(count);
            count = count + 1;
		end loop;
	end;
end;
$$ LANGUAGE plpgsql;

truncate public.one_col_distinct;
select * from public.one_col_distinct;
select loop_test(1);

CREATE TABLE "public"."one_col_distinct" (
  "col1" varchar(255) COLLATE "pg_catalog"."default" DEFAULT NULL
);





