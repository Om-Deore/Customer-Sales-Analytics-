-- Total Sales, Profits & Orders by Year
SELECT
  d.year,
  COUNT(DISTINCT f.order_id) AS total_orders,
  ROUND(SUM(f.sales), 2) AS total_sales,
  ROUND(SUM(f.profit), 2) AS total_profit,
  ROUND(AVG(f.sales), 2) AS avg_order_value,
  ROUND(SUM(f.profit)/NULLIF(SUM(f.sales),0)*100, 2) AS profit_margin_pct
FROM fact_orders f
JOIN dim_date d ON f.order_date = d.date_id
GROUP BY d.year
ORDER BY d.year;

-- Sales and Profit by Category and Sub Category
SELECT
  p.category, p.sub_category,
  COUNT(*) AS order_lines,
  ROUND(SUM(f.sales), 2) AS total_sales,
  ROUND(SUM(f.profit), 2) AS total_profit,
  ROUND(SUM(f.profit)/NULLIF(SUM(f.sales),0)*100, 2) AS margin_pct
FROM fact_orders f
JOIN dim_product p ON f.product_id = p.product_id
GROUP BY p.category, p.sub_category
ORDER BY p.category, total_sales DESC;

-- Monthly Sales Trend with Month-over-Month Growth (LAG)
WITH monthly AS (
  SELECT
    d.year, d.month, d.month_name,
    ROUND(SUM(f.sales), 2) AS monthly_sales,
    ROUND(SUM(f.profit), 2) AS monthly_profit
  FROM fact_orders f
  JOIN dim_date d ON f.order_date = d.date_id
  GROUP BY d.year, d.month, d.month_name
)
SELECT
  year, month, month_name,
  monthly_sales,
  monthly_profit,
  LAG(monthly_sales) OVER (ORDER BY year, month) AS prev_month_sales,
  ROUND(
    (monthly_sales - LAG(monthly_sales) OVER (ORDER BY year, month))
    / NULLIF(LAG(monthly_sales) OVER (ORDER BY year, month), 0) * 100, 2
  ) AS mom_growth_pct
FROM monthly
ORDER BY year, month;

-- Top 10 Customers by Revenue (ROW_NUMBER)
WITH ranked AS (
  SELECT
    c.customer_name, c.segment, c.region,
    ROUND(SUM(f.sales), 2)   AS total_sales,
    ROUND(SUM(f.profit), 2)  AS total_profit,
    COUNT(DISTINCT f.order_id) AS total_orders,
    ROW_NUMBER() OVER (ORDER BY SUM(f.sales) DESC) AS rn
  FROM fact_orders f
  JOIN dim_customer c ON f.customer_id = c.customer_id
  GROUP BY c.customer_name, c.segment, c.region
)
SELECT rn AS rank_, customer_name, segment, region,
       total_sales, total_profit, total_orders
FROM ranked
WHERE rn <= 10;

-- Running Total Sales by Region
WITH monthly_region AS (
  SELECT
    d.year, d.month,
    l.region,
    ROUND(SUM(f.sales), 2) AS monthly_sales
  FROM fact_orders f
  JOIN dim_date d     ON f.order_date  = d.date_id
  JOIN dim_location l ON f.location_id = l.location_id
  GROUP BY d.year, d.month, l.region
)
SELECT
  year, month, region, monthly_sales,
  ROUND(SUM(monthly_sales) OVER (
    PARTITION BY region ORDER BY year, month
  ), 2) AS running_total
FROM monthly_region
ORDER BY region, year, month;

-- Regional Profit Margin Analysis (HAVING)
SELECT
  l.region,
  ROUND(SUM(f.sales), 2)   AS total_sales,
  ROUND(SUM(f.profit), 2)  AS total_profit,
  ROUND(SUM(f.profit)/NULLIF(SUM(f.sales),0)*100, 2) AS profit_margin_pct
FROM fact_orders f
JOIN dim_location l ON f.location_id = l.location_id
GROUP BY l.region
HAVING total_sales > 0
ORDER BY profit_margin_pct DESC;

-- Discount Impact Analysis (CASE WHEN + HAVING)
SELECT
  CASE
    WHEN discount = 0 THEN '0% - No Discount'
    WHEN discount <= 0.10 THEN '1-10% Discount'
    WHEN discount <= 0.20 THEN '11-20% Discount'
    WHEN discount <= 0.30 THEN '21-30% Discount'
    ELSE '30%+ Heavy Discount'
  END AS discount_band,
  COUNT(*) AS order_lines,
  ROUND(SUM(sales), 2) AS total_sales,
  ROUND(SUM(profit), 2) AS total_profit,
  ROUND(AVG(profit/NULLIF(sales,0))*100, 2) AS avg_margin_pct
FROM fact_orders
GROUP BY discount_band
HAVING COUNT(*) > 50
ORDER BY AVG(discount);