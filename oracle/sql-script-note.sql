SELECT count(*)
FROM caihua.ISSWEIGHT
WHERE TDATE = date'2024-07-23';

SELECT count(*)
FROM caihua.ISSWEIGHT
WHERE TRUNC(TDATE) = TRUNC(SYSDATE) - 1;

DELETE FROM caihua.ISSWEIGHT WHERE TRUNC(TDATE) = TRUNC(SYSDATE) - 1;
