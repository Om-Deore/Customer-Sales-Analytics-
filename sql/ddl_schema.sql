CREATE DATABASE sales_analytics;
USE sales_analytics;

-- Dimension: Customer
CREATE TABLE dim_customer (
  customer_id   VARCHAR(20) PRIMARY KEY,
  customer_name VARCHAR(100) NOT NULL,
  segment       VARCHAR(20) NOT NULL,
  region        VARCHAR(20) NOT NULL,
  INDEX idx_region (region),
  INDEX idx_segment (segment)
);

-- Dimension: Product
CREATE TABLE dim_product (
  product_id   VARCHAR(30) PRIMARY KEY,
  product_name VARCHAR(200) NOT NULL,
  category     VARCHAR(50) NOT NULL,
  sub_category VARCHAR(50) NOT NULL,
  INDEX idx_category (category)
);

-- Dimension: Date
CREATE TABLE dim_date (
  date_id    DATE PRIMARY KEY,
  day        INT,
  month      INT,
  month_name VARCHAR(15),
  quarter    INT,
  year       INT,
  INDEX idx_year_month (year, month)
);

-- Dimension: Location
CREATE TABLE dim_location (
  location_id INT PRIMARY KEY AUTO_INCREMENT,
  city        VARCHAR(100),
  state       VARCHAR(50),
  region      VARCHAR(20),
  postal_code VARCHAR(10),
  INDEX idx_region (region)
);

-- Fact Table
CREATE TABLE fact_orders (
  order_id    VARCHAR(30) NOT NULL,
  order_date  DATE NOT NULL,
  ship_date   DATE,
  ship_mode   VARCHAR(30),
  customer_id VARCHAR(20),
  product_id  VARCHAR(30),
  location_id INT,
  sales       DECIMAL(10,4) NOT NULL,
  quantity    INT NOT NULL,
  discount    DECIMAL(5,4),
  profit      DECIMAL(10,4) NOT NULL,
  PRIMARY KEY (order_id, product_id),
  FOREIGN KEY (customer_id) REFERENCES dim_customer(customer_id),
  FOREIGN KEY (product_id)  REFERENCES dim_product(product_id),
  FOREIGN KEY (order_date)  REFERENCES dim_date(date_id),
  FOREIGN KEY (location_id) REFERENCES dim_location(location_id),
  INDEX idx_order_date (order_date),
  INDEX idx_customer   (customer_id),
  INDEX idx_product    (product_id)
);