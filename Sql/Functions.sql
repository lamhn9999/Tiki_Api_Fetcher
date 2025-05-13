create or replace function insert_product_image(
    p_product_id int,
    p_base_url text,
    p_large_url text,
    p_medium_url text,
    p_small_url text,
    p_thumbnail_url text,
    p_is_gallery boolean default true,
    p_label text default null
)
returns void 
language plpgsql
as $$
    begin
        insert into product_images(
            product_id,
            base_url,
            large_url,
            medium_url,
            small_url,
            thumbnail_url,
            is_gallery,
            label
        )        
        values (
            p_product_id,
            p_base_url,
            p_large_url,
            p_medium_url,
            p_small_url,
            p_thumbnail_url,
            p_is_gallery,
            p_label
        );
    end;
$$;
CREATE OR REPLACE FUNCTION insert_product(
    p_product_id INT,
    p_name VARCHAR(1000),
    p_url_key VARCHAR(1000),
    p_price BIGINT,
    p_description TEXT
)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO products (
        product_id,
        name,
        url_key,
        price,
        description
    ) 
    VALUES (
        p_product_id,
        p_name,
        p_url_key,
        p_price,
        p_description
    );
END;
$$;