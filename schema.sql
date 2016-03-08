

DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS products;



CREATE TABLE employees (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100),
  email VARCHAR(100) unique
);

CREATE TABLE customers (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100),
  account_number VARCHAR(100) unique
);

CREATE TABLE products (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) unique
);

CREATE TABLE transactions (
  id SERIAL PRIMARY KEY,
  sale_date VARCHAR(100),
  sale_amount VARCHAR(100),
  units_sold INT,
  invoice_number INT,
  invoice_frequency VARCHAR(50),
  product_id INT REFERENCES products (id),
  employee_id INT REFERENCES employees (id),
  customer_id INT REFERENCES customers (id)
);
