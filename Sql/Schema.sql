create table products (
    product_id int primary key,     
    name varchar(1000) not null,           
    url_key varchar(1000) unique not null,
    price bigint not null,               
    description text not null             
);
create table product_images (
    image_id serial primary key,
    product_id int references products(product_id) on delete cascade,
    base_url text not null,
    large_url text not null,
    medium_url text not null,
    small_url text not null,
    thumbnail_url text not null,
    is_gallery boolean default true,
    label text
);