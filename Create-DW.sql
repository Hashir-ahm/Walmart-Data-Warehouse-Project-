-- drop existing schema
drop table if exists factsales;
drop table if exists dimtime;
drop table if exists dimstore;
drop table if exists dimproduct;
drop table if exists dimcustomer;

-- create dimension tables
create table dimcustomer (
    customer_key int auto_increment primary key,
    customer_id int not null,
    gender char(1),
    age_group varchar(10),
    occupation int,
    city_category char(1),
    stay_in_current_city_years int,
    marital_status int,
    created_date timestamp default current_timestamp,
    index idx_customer_id (customer_id)
);

create table dimproduct (
    product_key int auto_increment primary key,
    product_id varchar(20) not null,
    product_category varchar(50),
    price decimal(10,2),
    created_date timestamp default current_timestamp,
    index idx_product_id (product_id)
);

create table dimstore (
    store_key int auto_increment primary key,
    store_id int not null,
    store_name varchar(100),
    supplier_id int,
    supplier_name varchar(100),
    created_date timestamp default current_timestamp,
    index idx_store_id (store_id)
);

create table dimtime (
    time_key int auto_increment primary key,
    full_date date not null,
    day int,
    month int,
    year int,
    quarter int,
    day_of_week int,
    is_weekend boolean,
    created_date timestamp default current_timestamp,
    index idx_full_date (full_date)
);

-- create fact table
create table factsales (
    sales_key int auto_increment primary key,
    customer_key int,
    product_key int,
    store_key int,
    time_key int,
    order_id int not null,
    quantity int,
    total_amount decimal(10,2),
    created_date timestamp default current_timestamp,
    foreign key (customer_key) references dimcustomer(customer_key),
    foreign key (product_key) references dimproduct(product_key),
    foreign key (store_key) references dimstore(store_key),
    foreign key (time_key) references dimtime(time_key),
    index idx_order_id (order_id)
);