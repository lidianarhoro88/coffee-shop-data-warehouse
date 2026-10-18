"""
Generates raw "source system" files for our practice data warehouse.
Pretends to be exports from two separate, real-world systems:
  - POS system   -> stores, products, sales transactions
  - Loyalty app   -> customers, points redemptions

On purpose, the data has the kind of mess real source systems have:
  - some duplicate customer rows (updated info, old row left behind)
  - inconsistent casing / extra spaces in text fields
  - a few nulls where they shouldn't be
  - a couple of bad dates
This is what the Bronze -> Silver cleaning step in the next stage is for.
"""
import csv
import random
from datetime import datetime, timedelta
from pathlib import Path
from faker import Faker

fake = Faker()
Faker.seed(42)
random.seed(42)

BASE = Path(__file__).resolve().parent.parent / "datasets"
POS = BASE / "source_pos"
LOY = BASE / "source_loyalty"

# ---------- POS: stores ----------
stores = []
cities = ["Istanbul", "Ankara", "Izmir", "Bursa", "Antalya"]
for i, city in enumerate(cities, start=1):
    stores.append({"store_id": f"ST{i:03d}", "store_name": f"{city} Central", "city": city})

with open(POS / "stores.csv", "w", newline="", encoding="utf-8") as f:
    w = csv.DictWriter(f, fieldnames=["store_id", "store_name", "city"])
    w.writeheader()
    w.writerows(stores)

# ---------- POS: products ----------
product_catalog = [
    ("Espresso", "Hot Drinks", 35.0), ("Latte", "Hot Drinks", 55.0),
    ("Cappuccino", "Hot Drinks", 55.0), ("Americano", "Hot Drinks", 45.0),
    ("Iced Latte", "Cold Drinks", 60.0), ("Cold Brew", "Cold Drinks", 65.0),
    ("Croissant", "Pastry", 40.0), ("Muffin", "Pastry", 38.0),
    ("Cheesecake Slice", "Dessert", 70.0), ("Cookie", "Pastry", 25.0),
]
products = []
for i, (name, cat, price) in enumerate(product_catalog, start=1):
    products.append({"product_id": f"PR{i:03d}", "product_name": name,
                      "category": cat, "unit_price": price})

with open(POS / "products.csv", "w", newline="", encoding="utf-8") as f:
    w = csv.DictWriter(f, fieldnames=["product_id", "product_name", "category", "unit_price"])
    w.writeheader()
    w.writerows(products)

# ---------- POS: sales transactions ----------
start_date = datetime(2026, 1, 1)
sales = []
sale_id = 1
for _ in range(3000):
    store = random.choice(stores)
    product = random.choice(products)
    sale_date = start_date + timedelta(days=random.randint(0, 270),
                                        hours=random.randint(7, 20),
                                        minutes=random.randint(0, 59))
    qty = random.choice([1, 1, 1, 2, 2, 3])
    # inject a few bad rows on purpose
    bad_date = random.random() < 0.01
    sales.append({
        "sale_id": f"SL{sale_id:06d}",
        "store_id": store["store_id"],
        "product_id": product["product_id"],
        "customer_loyalty_id": f"CU{random.randint(1, 500):04d}" if random.random() > 0.15 else "",
        "quantity": qty if random.random() > 0.005 else -1,  # a stray bad value
        "sale_date": "" if bad_date else sale_date.strftime("%Y-%m-%d %H:%M:%S"),
    })
    sale_id += 1

with open(POS / "sales.csv", "w", newline="", encoding="utf-8") as f:
    w = csv.DictWriter(f, fieldnames=["sale_id", "store_id", "product_id",
                                       "customer_loyalty_id", "quantity", "sale_date"])
    w.writeheader()
    w.writerows(sales)

# ---------- Loyalty: customers (with intentional messiness) ----------
customers = []
for i in range(1, 501):
    name = fake.name()
    # randomly mess up casing/spacing on some rows, like a real messy export
    display_name = name.upper() if random.random() < 0.1 else (f"  {name}  " if random.random() < 0.1 else name)
    join_date = fake.date_between(start_date="-3y", end_date="-1M")
    customers.append({
        "customer_loyalty_id": f"CU{i:04d}",
        "full_name": display_name,
        "email": fake.email() if random.random() > 0.05 else None,  # a few missing emails
        "city": random.choice(cities),
        "join_date": join_date.strftime("%Y-%m-%d"),
        "tier": random.choice(["Bronze", "Silver", "Gold", None]),
    })

# inject duplicate rows for ~20 customers (stale snapshot left behind), a realistic CRM/loyalty issue
for dup_id in random.sample(range(1, 501), 20):
    base = next(c for c in customers if c["customer_loyalty_id"] == f"CU{dup_id:04d}")
    stale = dict(base)
    stale["tier"] = "Bronze"  # stale lower tier before their last upgrade
    customers.append(stale)

with open(LOY / "customers.csv", "w", newline="", encoding="utf-8") as f:
    w = csv.DictWriter(f, fieldnames=["customer_loyalty_id", "full_name", "email",
                                       "city", "join_date", "tier"])
    w.writeheader()
    w.writerows(customers)

# ---------- Loyalty: point redemptions ----------
redemptions = []
for i in range(1, 801):
    cust = random.choice(customers)
    redeem_date = fake.date_between(start_date="-1y", end_date="today")
    redemptions.append({
        "redemption_id": f"RD{i:05d}",
        "customer_loyalty_id": cust["customer_loyalty_id"],
        "points_used": random.choice([50, 100, 150, 200]),
        "redeem_date": redeem_date.strftime("%Y-%m-%d"),
    })

with open(LOY / "redemptions.csv", "w", newline="", encoding="utf-8") as f:
    w = csv.DictWriter(f, fieldnames=["redemption_id", "customer_loyalty_id",
                                       "points_used", "redeem_date"])
    w.writeheader()
    w.writerows(redemptions)

print("Done. Files written:")
for p in [POS / "stores.csv", POS / "products.csv", POS / "sales.csv",
          LOY / "customers.csv", LOY / "redemptions.csv"]:
    print(f"  {p}  ({sum(1 for _ in open(p)) - 1} rows)")
