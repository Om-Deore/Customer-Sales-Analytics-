import pandas as pd
from sqlalchemy import create_engine

# ── 1. CONFIG ─────────────────────────────────────────
CSV_PATH = r"E:\Customer Sales Analytics\Customer-Sales-Analytics-\Superstore.csv"
DB_USER  = "root"
DB_PASS  = "Omd%403590"                
DB_HOST  = "localhost"
DB_PORT  = 3306
DB_NAME  = "sales_analytics"

engine = create_engine(
    f"mysql+pymysql://{DB_USER}:{DB_PASS}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
)

# ── 2. EXTRACT ────────────────────────────────────────
df = pd.read_csv(CSV_PATH, encoding="latin-1")
df.columns = [c.lower().replace(" ","_").replace("-","_")
              for c in df.columns]

# ── 3. TRANSFORM ──────────────────────────────────────
df["order_date"] = pd.to_datetime(df["order_date"])
df["ship_date"]  = pd.to_datetime(df["ship_date"])
df["postal_code"] = df["postal_code"].fillna(0).astype(int).astype(str)
df["postal_code"] = df["postal_code"].replace("0", None)

# ── 4. BUILD DIMENSION TABLES ─────────────────────────
# Fix customer dimension
dim_customer = df[["customer_id","customer_name","segment","region"]] \
                .drop_duplicates(subset=["customer_id"])

# Fix product dimension
dim_product = df[["product_id","product_name","category","sub_category"]] \
               .drop_duplicates(subset=["product_id"])

dim_location = (df[["city","state","region","postal_code"]]
                .drop_duplicates()
                .reset_index(drop=True))
dim_location["location_id"] = dim_location.index + 1

# Build date dimension
all_dates = pd.concat([df["order_date"], df["ship_date"]]).dropna().unique()
dim_date = pd.DataFrame({"date_id": pd.to_datetime(all_dates)})
dim_date["day"]        = dim_date["date_id"].dt.day
dim_date["month"]      = dim_date["date_id"].dt.month
dim_date["month_name"] = dim_date["date_id"].dt.strftime("%B")
dim_date["quarter"]    = dim_date["date_id"].dt.quarter
dim_date["year"]       = dim_date["date_id"].dt.year
dim_date = dim_date.drop_duplicates("date_id").sort_values("date_id")

# Merge location_id into main df
df = df.merge(
    dim_location[["city","state","region","postal_code","location_id"]],
    on=["city","state","region","postal_code"], how="left"
)

# Build fact table
fact_orders = df[[
    "order_id","order_date","ship_date","ship_mode",
    "customer_id","product_id","location_id",
    "sales","quantity","discount","profit"
]].drop_duplicates(subset=["order_id", "product_id"])

# ── 5. LOAD INTO MYSQL ────────────────────────────────
print("Loading dim_customer...")
dim_customer.to_sql("dim_customer", engine,
                    if_exists="append", index=False)

print("Loading dim_product...")
dim_product.to_sql("dim_product", engine,
                   if_exists="append", index=False)

print("Loading dim_date...")
dim_date.to_sql("dim_date", engine,
                if_exists="append", index=False)

print("Loading dim_location...")
dim_location[["location_id","city","state","region","postal_code"]].to_sql(
    "dim_location", engine, if_exists="append", index=False
)

print("Loading fact_orders...")
fact_orders.to_sql("fact_orders", engine,
                   if_exists="append", index=False)

print("✓ ETL complete! All 5 tables loaded.")
print(f"  fact_orders rows: {len(fact_orders)}")
