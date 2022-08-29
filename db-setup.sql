CREATE TABLE cliente (
    id serial primary key,
    nome text,
    dt_nasc timestamptz,
    bio text
);

CREATE OR REPLACE FUNCTION f_add_cliente_fake(int) 
RETURNS TABLE(id int) AS $$
    TRUNCATE cliente;
    
    WITH fake_string AS (
        -- from https://stackoverflow.com/a/36167979
        SELECT 
            string_agg (
                substr('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', ceil(random() * 62)::integer, 1), '') as r_string
        FROM generate_series(1, 2*1024*1024)
    ),
    insert_data AS (
        SELECT
            x AS id,
            'cliente #' || x AS nome,
            now() - (to_char(9000*random(), '0000000') || ' weeks')::interval AS dt_nasc,
            (select r_string from fake_string) as bio
        FROM generate_series(1,$1) AS x
    )
    INSERT INTO cliente (id, nome, dt_nasc, bio)
    SELECT * FROM insert_data
    RETURNING id;
$$ LANGUAGE SQL;

create view vw_nasc_2000 as select id, nome, dt_nasc from cliente where dt_nasc < '2001-01-01 00:01:01';