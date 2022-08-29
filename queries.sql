DROP FUNCTION IF EXISTS f_table_info(oid) ;
CREATE OR REPLACE FUNCTION f_table_info(oid) 
RETURNS TABLE(oid oid, relname text, relkind char, filepath text, prety_size text) AS $$
    SELECT
        $1 as oid,
        $1::regclass, 
        pg_class.relkind,
        pg_relation_filepath($1) as filepath, 
        pg_size_pretty(pg_relation_size($1)) as prety_size
    FROM pg_class where oid = $1
    ;
$$ LANGUAGE SQL;

-- lista tabela e toast
select 
  oid::regclass, 
  pg_relation_filepath(oid) as path_table, 
  pg_size_pretty(pg_relation_size(oid)) as size_table,
  reltoastrelid::regclass, 
  pg_relation_filepath(reltoastrelid) as path_toast, 
  pg_size_pretty(pg_relation_size(reltoastrelid)) as size_toast
from pg_class 
where relname = 'cliente';

-[ RECORD 1 ]-+------------------------
oid           | cliente
path_table    | base/16384/16618
size_table    | 8192 bytes
reltoastrelid | pg_toast.pg_toast_16386
path_toast    | base/16384/16619
size_toast    | 21 MB

-- v2

select
t.*,
t2.*  
from pg_class as c 
join f_table_info(c.oid) as t on t.oid = c.oid 
left join f_table_info(c.reltoastrelid) as t2 on t2.oid = c.reltoastrelid 
where c.relname = 'cliente';
-[ RECORD 1 ]-----------------------
oid        | 16386
relname    | cliente
relkind    | r
filepath   | base/16384/16618
prety_size | 8192 bytes
oid        | 16390
relname    | pg_toast.pg_toast_16386
relkind    | t
filepath   | base/16384/16619
prety_size | 21 MB


-----

DROP FUNCTION IF EXISTS check_cliente();
CREATE OR REPLACE FUNCTION check_cliente()
RETURNS bool
LANGUAGE plpgsql AS
$$
DECLARE
    v_row record;
    found_error bool = false;
BEGIN
    FOR v_row IN SELECT * FROM cliente order by 1 asc
    LOOP
       BEGIN
           -- usar o toast causa o erro...
            perform length(v_row.bio);
       EXCEPTION WHEN internal_error OR data_corrupted OR index_corrupted THEN
           RAISE NOTICE 'failed to work with the toast of id: % - %', v_row.id, v_row.ctid;
           found_error = true;
       END;
    END LOOP;

    return found_error;
END
$$;

select * from check_cliente();