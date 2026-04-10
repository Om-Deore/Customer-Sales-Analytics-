# 📊 Customer Sales Analytics

> An end-to-end data analytics project built with **MySQL**, **Python**, and **Power BI** — from raw CSV to interactive executive dashboard.

---

## 🗂️ Table of Contents

- [Project Overview](#project-overview)
- [Tech Stack](#tech-stack)
- [Dataset](#dataset)
- [Database Schema](#database-schema)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [SQL Queries](#sql-queries)
- [Power BI Dashboard](#power-bi-dashboard)
- [Key Business Insights](#key-business-insights)
- [Skills Demonstrated](#skills-demonstrated)
- [Contact](#contact)

---

## Project Overview

This project simulates a real-world enterprise BI pipeline — starting from a raw sales dataset, modelling it into a relational star schema, writing production-level SQL queries, and delivering an interactive Power BI dashboard for business decision-making.

**What was built:**
- A 5-table **Star Schema** in MySQL (1 fact table + 4 dimension tables)
- **7 SQL queries** covering KPI aggregation, window functions, CTEs, and discount analysis
- A **Python ETL pipeline** that cleans and loads the dataset into MySQL
- A **5-page Power BI dashboard** with DAX measures, slicers, and drill-through

---

## Tech Stack

| Tool | Purpose |
|------|---------|
| MySQL 8.0 (Workbench) | Database design, DDL, SQL queries |
| Python 3 (pandas, SQLAlchemy) | ETL — extract, transform, load |
| Power BI Desktop | Interactive dashboard & DAX measures |
| Git / GitHub | Version control & portfolio hosting |

---

## Dataset

**Source:** Superstore Sales Dataset (widely used analytics benchmark)

| Property | Value |
|----------|-------|
| Rows | 9,994 order line items |
| Columns | 21 |
| Date Range | 2014 – 2017 |
| Segments | Consumer, Corporate, Home Office |
| Categories | Technology, Furniture, Office Supplies |
| Regions | West, East, Central, South |

---

## Database Schema

A **Star Schema** was used — one central fact table surrounded by 4 dimension tables. This design is optimised for analytics queries and maps directly to Power BI relationships.

```
                    ┌─────────────────┐
                    │   dim_customer  │
                    │  customer_id PK │
                    └────────┬────────┘
                             │
┌──────────────┐    ┌────────▼────────┐    ┌─────────────────┐
│  dim_product │    │   fact_orders   │    │  dim_location   │
│ product_id PK├────►  order_id (PK)  ◄────┤ location_id PK  │
└──────────────┘    │  customer_id FK │    └─────────────────┘
                    │  product_id  FK │
                    │  location_id FK │    ┌─────────────────┐
                    │  order_date  FK ◄────┤    dim_date     │
                    │  sales          │    │   date_id PK    │
                    │  profit         │    └─────────────────┘
                    │  quantity       │
                    │  discount       │
                    └─────────────────┘
```

---

## Project Structure

```
Customer-Sales-Analytics/
│
├── sql/
│   ├── ddl_schema.sql          # CREATE TABLE statements for all 5 tables
│   └── queries.sql             # All 7 production SQL queries
│
├── python/
│   └── etl_load.py             # ETL script — loads CSV into MySQL
│
├── screenshots/
│   ├── page1_executive_summary.png
│   ├── page2_regional_analysis.png
│   ├── page3_product_analysis.png
│   ├── page4_customer_intelligence.png
│   └── page5_trend_analysis.png
│
├── dashboard_preview.pdf       # Power BI dashboard exported as PDF
├── README.md
└── Superstore.csv              # Raw dataset (or link to Kaggle source)
```

---

## Getting Started

### Prerequisites
- MySQL 8.0 + MySQL Workbench
- Python 3.8+ with pip
- Power BI Desktop (free from Microsoft)

### Step 1 — Clone the repo
```bash
git clone https://github.com/Om-Deore/Customer-Sales-Analytics.git
cd Customer-Sales-Analytics
```

### Step 2 — Create the database
Open MySQL Workbench, connect to your local server, and run:
```sql
CREATE DATABASE sales_analytics;
USE sales_analytics;
```
Then run the full DDL:
```bash
# In MySQL Workbench: open and run sql/ddl_schema.sql
```

### Step 3 — Install Python dependencies
```bash
pip install pandas sqlalchemy pymysql mysql-connector-python
```

### Step 4 — Run the ETL
Open `python/etl_load.py` and update two lines:
```python
CSV_PATH = r"path/to/Superstore.csv"   # your local file path
DB_PASS  = "YOUR_MYSQL_PASSWORD"       # your MySQL root password
```
Then run:
```bash
python python/etl_load.py
```

Expected output:
```
Loading dim_customer...
Loading dim_product...
Loading dim_date...
Loading dim_location...
Loading fact_orders...
ETL complete! All 5 tables loaded.
fact_orders rows loaded: 9994
```

### Step 5 — Run SQL queries
Open MySQL Workbench and run `sql/queries.sql`.

### Step 6 — Open the Power BI Dashboard
- Open Power BI Desktop → Get Data → MySQL Database
- Server: `localhost` | Database: `sales_analytics`
- Load all 5 tables and verify relationships in Model view

---

## SQL Queries

| # | Query | SQL Concepts |
|---|-------|-------------|
| Q1 | Annual KPI Summary (Sales, Profit, Orders by Year) | GROUP BY, ROUND, NULLIF, COUNT DISTINCT |
| Q2 | Sales & Profit by Category and Sub-Category | Multi-level GROUP BY, JOIN |
| Q3 | Monthly Trend with Month-over-Month Growth | CTE, LAG() Window Function |
| Q4 | Top 10 Customers by Revenue | CTE, ROW_NUMBER() Window Function |
| Q5 | Running Total Sales by Region | SUM() OVER, PARTITION BY |
| Q6 | Regional Profit Margin Analysis | HAVING, multi-table JOIN |
| Q7 | Discount Impact on Profitability | CASE WHEN, HAVING, AVG |

---

## Power BI Dashboard

The dashboard has 5 pages, all connected by synced slicers (Date, Region, Category):

| Page | Visuals |
|------|---------|
| Executive Summary | 4 KPI cards, bar chart by region, monthly line chart |
| Regional Analysis | Filled map by state, regional profit margin table |
| Product Analysis | Donut chart by category, sub-category breakdown matrix |
| Customer Intelligence | Top 10 customers table, segment analysis, scatter plot |
| Trend Analysis | YoY comparison, quarterly seasonality chart |

**DAX Measures created:**
```
Total Sales, Total Profit, Profit Margin %, Total Orders,
Avg Order Value, Sales PY, Sales YoY %, Profit Color
```

---

## Key Business Insights

**1. Heavy Discounting Destroys Profit**
Orders with 30%+ discounts have negative average profit margins. Recommendation: cap discounts at 20%, require approval for anything above.

**2. Technology Drives Profit, Furniture Drags It**
Technology category has ~16% profit margin. Furniture frequently runs negative margins due to excessive discounting.

**3. West Region Outperforms, Central Underperforms**
West leads in both sales volume and margin. Central has high revenue but below-average profitability — warrants a pricing audit.

**4. Strong Q4 Seasonality**
November–December show 35–45% above-average sales. Q1 is consistently the weakest quarter — opportunity for targeted promotions.

---

## Skills Demonstrated

`SQL` `MySQL` `Window Functions` `CTEs` `Star Schema` `OLAP Design`
`Python` `pandas` `ETL Pipeline` `SQLAlchemy` `Data Cleaning`
`Power BI` `DAX` `Data Modeling` `KPI Design` `Business Intelligence`

---

## Contact

**Om Deore** — Data Analyst

- 🌐 Portfolio: [om-deore.github.io/Portfolio](https://om-deore.github.io/Portfolio)
- 💼 LinkedIn: [linkedin.com/in/om-deore1906](https://linkedin.com/in/om-deore1906)
- 📧 Email: omdeore321@gmail.com
- 🐙 GitHub: [github.com/Om-Deore](https://github.com/Om-Deore)
