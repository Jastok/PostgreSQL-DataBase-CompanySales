CREATE DATABASE sales;

-- information about clients
CREATE TABLE clients
(client_id SERIAL PRIMARY KEY,
c_name VARCHAR(30) NOT NULL,
town VARCHAR(25) NOT NULL,
director VARCHAR(25) NOT NULL);

-- information about logistic companies
CREATE TABLE log_companies
(log_id SERIAL PRIMARY KEY,
log_name VARCHAR(30) NOT NULL);

-- information about products
CREATE TABLE products
(p_id SERIAL PRIMARY KEY,
p_name VARCHAR(130) NOT NULL,
category VARCHAR(50) NOT NULL,
maker VARCHAR(20) NOT NULL);

-- basic information about orders
CREATE TABLE orders
(order_id SERIAL PRIMARY KEY,
client_id SMALLINT NOT NULL,
log_id SMALLINT NOT NULL,
date DATE NOT NULL,
log_costs INT NOT NULL,
doc VARCHAR(15) NOT NULL,
FOREIGN KEY (client_id) REFERENCES clients (client_id),
FOREIGN KEY (log_id) REFERENCES log_companies (log_id));

-- information about products in orders
CREATE TABLE orders_products
(order_id INT NOT NULL,
p_id INT NOT NULL,
p_costs NUMERIC(6,2) NOT NULL,
price NUMERIC(6,2) NOT NULL,
count INT NOT NULL,
refund_count INT DEFAULT 0,
FOREIGN KEY (order_id) REFERENCES orders (order_id),
FOREIGN KEY (p_id) REFERENCES products (p_id));