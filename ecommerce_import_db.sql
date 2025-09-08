CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    age INTEGER,
    gender VARCHAR(10),
    state VARCHAR(50),
    street_address TEXT,
    postal_code VARCHAR(20),
    city VARCHAR(50),
    country VARCHAR(50),
    latitude DECIMAL(9,6),
    longitude DECIMAL(9,6),
    traffic_source VARCHAR(50),
    created_at TIMESTAMP
);

ALTER TABLE users DROP CONSTRAINT users_email_key;


SELECT * FROM users;

CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    cost NUMERIC(10,2),
    category VARCHAR(100),
    name VARCHAR(300),
    brand VARCHAR(100),
    retail_price NUMERIC(10,2),
    department VARCHAR(100),
    sku VARCHAR(50) UNIQUE,
    distribution_center_id INTEGER
);

ALTER TABLE products
ALTER COLUMN name TYPE TEXT;



SELECT * FROM products;

CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    user_id INTEGER,
    status VARCHAR(50),
    gender VARCHAR(10),
    created_at TIMESTAMP,
    returned_at TIMESTAMP,
    shipped_at TIMESTAMP,
    delivered_at TIMESTAMP,
    num_of_item INTEGER
);

SELECT * FROM orders

CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER,
    user_id INTEGER,
    product_id INTEGER,
    inventory_item_id INTEGER,
    status VARCHAR(50),
    created_at TIMESTAMP,
    shipped_at TIMESTAMP,
    delivered_at TIMESTAMP,
    returned_at TIMESTAMP,
    sale_price NUMERIC(10,2)
);

CREATE TABLE inventory_items (
    id SERIAL PRIMARY KEY,
    product_id INTEGER,
    created_at TIMESTAMP,
    sold_at TIMESTAMP,
    cost NUMERIC(10,2),
    product_category VARCHAR(100),
    product_name VARCHAR(300),
    product_brand VARCHAR(100),
    product_retail_price NUMERIC(10,2),
    product_department VARCHAR(100),
    product_sku VARCHAR(50),
    product_distribution_center_id INTEGER
);

ALTER TABLE inventory_items
ALTER COLUMN product_name TYPE VARCHAR(300);


CREATE TABLE events (
    id SERIAL PRIMARY KEY,
    user_id INTEGER,
    sequence_number INTEGER,
    session_id VARCHAR(100),
    created_at TIMESTAMP,
    ip_address INET,
    city VARCHAR(100),
    state VARCHAR(100),
    postal_code VARCHAR(20),
    browser VARCHAR(100),
    traffic_source VARCHAR(100),
    uri TEXT,
    event_type VARCHAR(100)
);

CREATE TABLE distribution_centers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    latitude DECIMAL(9,6),
    longitude DECIMAL(9,6)
);

COPY users(
    id, first_name, last_name, email, age, gender, state,
    street_address, postal_code, city, country, latitude, longitude,
    traffic_source, created_at
)
FROM 'C:\Users\Sankalp\OneDrive\Documents\clean_users_utf8.csv'
DELIMITER ','
CSV HEADER;

COPY products(
    id, cost, category, name, brand,
    retail_price, department, sku, distribution_center_id
)
FROM 'C:/Users/Sankalp/OneDrive/Documents/products_utf8_cleaned_final.csv'
DELIMITER ','
CSV HEADER;

COPY orders(
    order_id, user_id, status, gender,
    created_at, returned_at, shipped_at, delivered_at,
    num_of_item
)
FROM 'C:/Users/Sankalp/OneDrive/Documents/orders.csv'
DELIMITER ','
CSV HEADER;

COPY order_items(
    id, order_id, user_id, product_id, inventory_item_id,
    status, created_at, shipped_at, delivered_at, returned_at, sale_price
)
FROM 'C:/Users/Sankalp/OneDrive/Documents/order_items.csv'
DELIMITER ','
CSV HEADER;

COPY inventory_items(
    id, product_id, created_at, sold_at, cost,
    product_category, product_name, product_brand,
    product_retail_price, product_department,
    product_sku, product_distribution_center_id
)
FROM 'C:/Users/Sankalp/OneDrive/Documents/inventory_items.csv'
DELIMITER ','
CSV HEADER;

COPY events(
    id, user_id, sequence_number, session_id, created_at,
    ip_address, city, state, postal_code,
    browser, traffic_source, uri, event_type
)
FROM '"C:/Users/Sankalp/OneDrive/Documents/events.csv"'
DELIMITER ','
CSV HEADER;

COPY distribution_centers(
    id, name, latitude, longitude
)
FROM 'C:/Users/Sankalp/OneDrive/Documents/distribution_centers.csv'
DELIMITER ','
CSV HEADER;



SELECT * FROM users
SELECT * FROM products
SELECT * FROM orders
SELECT * FROM order_items
SELECT * FROM inventory_items
SELECT * FROM events
SELECT * FROM distribution_centers