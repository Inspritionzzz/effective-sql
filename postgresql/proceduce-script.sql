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

