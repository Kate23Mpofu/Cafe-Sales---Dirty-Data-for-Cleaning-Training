# ☕ Cafe Sales - Dirty Data Cleaning & Analysis Project

> Cleaning messy transaction records and uncovering sales insights using MySQL.

---

## 📌 Overview

This project covers a full data cleaning and exploratory analysis pipeline on a deliberately dirty café sales dataset sourced from Kaggle, using **MySQL**.

**Dataset:** [Cafe Sales - Dirty Data for Cleaning Training](https://www.kaggle.com/datasets/ahmedmohamed2003/cafe-sales-dirty-data-for-cleaning-training) by Ahmed Mohamed on Kaggle  
**Rows:** 10,000 synthetic sales transactions  
**Tool:** MySQL Workbench

---

## 🧩 Dataset Columns

| Column | Description |
|---|---|
| `transaction_id` | Unique ID per sale |
| `item` | Menu item sold |
| `quantity` | Units sold |
| `price_per_unit` | Price of one unit |
| `total_spent` | Quantity × Price |
| `payment_method` | Cash, Card, etc. |
| `location` | In-store or Takeaway |
| `transaction_date` | Date of sale |

---

## 🦠 Data Quality Issues Found

- **Non-standard column names** - original headers had spaces (e.g., `Transaction ID`, `Price Per Unit`)
- **Missing values** - `NULL` and blank (`''`) cells across multiple columns
- **Invalid placeholders** - `'ERROR'` and `'UNKNOWN'` strings in fields that should be numeric or categorical
- **Derived column drift** - `total_spent` not always matching `quantity × price_per_unit`

---

## 🛠️ Cleaning Steps

1. **Renamed all columns** to `snake_case` for consistency
2. **Created a staging table** as a copy of the raw data - to keep the original untouched throughout the process
3. **Removed duplicates** using a CTE with `ROW_NUMBER()`, writing only unique rows into a new `cafe_sales_clean` table
4. **Dropped unrecoverable rows** - rows missing `item`, `payment_method`, AND `location` simultaneously had no meaningful data to keep
5. **Recalculated `total_spent`** as `quantity × price_per_unit` wherever the column was missing or invalid
6. **Standardised remaining missing values** - unrecoverable text fields set to `'UNKNOWN'`; missing dates set to `NULL` to allow proper date casting
7. **Validated numeric columns** - checked for any zero or negative `quantity` values

---

## 📊 Before vs After

| Metric | Before | After |
|---|---|---|
| Total rows | 9,006 | 8,984 |
| Rows removed | - | 22 |
| Unrecoverable rows | Present | Deleted |
| Invalid placeholders | Present | Standardised or set to `NULL` |
| `total_spent` gaps | Present | Recalculated where possible |
| Column names | Spaced headers | `snake_case` |

---

## 🔍 Exploratory Analysis

All analysis queries filter out `'UNKNOWN'` values where relevant to avoid skewing results. The following questions were explored:

**Sales overview**
- Total revenue and total number of transactions
- Top items by quantity sold and by revenue
- Most common payment method
- Transaction split by location (In-store vs Takeaway)

**Deeper breakdowns**
- Highest revenue item per location
- Average order value by payment method
- Most popular item per location
- Busiest month and day of the week for sales

---

## 📁 Project Structure

```
Cafe-Sales---Dirty-Data-for-Cleaning-Training/

├── Power BI/

│   ├── Main Dashboard.png              # Screenshot of the main dashboard page

│   ├── Breakdown.png                   # Screenshot of the breakdown page

│   └── cafe_sales_visualization.pbit  # Power BI template file

│

├── Reports/

│   ├── Cafe_Sales_Analysis_Technical_Report.pdf  # Full technical report (cleaning, SQL, model)

│   └── Cafe_Sales_Client_Report.pdf             # Client-facing summary (findings & recommendations)

│

├── data/

│   └── dirty_cafe_sales.csv           # Original raw dataset (from Kaggle)

│

├── sql/

│   ├── cafe_sales_cleaning.sql        # Data cleaning and standardisation script

│   └── cafe_sales_analysis.sql        # Exploratory analysis queries

│

└── README.md

```

---

## 🚀 Getting Started

**1. Clone the repository**
```bash
git clone https://github.com/Kate23Mpofu/Cafe-Sales---Dirty-Data-for-Cleaning-Training.git
cd Cafe-Sales---Dirty-Data-for-Cleaning-Training
```

**2. Download the dataset**  
Get `dirty_cafe_sales.csv` from [Kaggle](https://www.kaggle.com/datasets/ahmedmohamed2003/cafe-sales-dirty-data-for-cleaning-training) and import it into MySQL using the Table Data Import Wizard in MySQL Workbench.

**3. Run the scripts**  
Run `cafe_sales_cleaning.sql` first, then `cafe_sales_analysis.sql`.

---

## 💡 Skills Practiced

- Renaming columns with `ALTER TABLE`
- Safe cleaning with a staging table
- Deduplication using CTEs and `ROW_NUMBER()` window functions
- Handling `NULL`, blank, and invalid placeholder values
- Recalculating derived columns with `UPDATE`
- Exploratory analysis with `GROUP BY`, `ROUND()`, `EXTRACT()`, and `DAYNAME()`
- Intermediate querying with CTEs and window functions

---

## 🗺️ Next Steps

- [ ] Visualise findings in Excel
- [ ] Explore month-over-month revenue trends
- [ ] Calculate each item's contribution to total revenue (%)
- [ ] Analyse day-of-week sales patterns

---

## 🙏 Acknowledgements

- Dataset by [Ahmed Mohamed](https://www.kaggle.com/ahmedmohamed2003) on Kaggle
- Built as part of a data cleaning & preprocessing portfolio project

---

*Feel free to fork this repo, open issues, or suggest improvements!*
