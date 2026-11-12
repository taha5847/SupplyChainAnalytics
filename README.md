# DataCo Supply Chain Analytics: Sales, Profit & Delivery Performance

An end-to-end analytics project: **Python → SQL Server → Power BI**. It cleans a public supply chain dataset, answers business questions with SQL, and presents the results in a 5-page interactive Power BI dashboard.

> **Live dashboard:** [add your Publish to web link here]
> **Dataset:** [DataCo Supply Chain Dataset (Kaggle)](https://www.kaggle.com/datasets/saicharankomati/dataco-supply-chain-dataset)

![Executive Overview](images/page1_executive_overview.png)

---

## 1. Business problem

DataCo sells sports and outdoor products worldwide through four shipping modes. Management wants to know:

1. Is the business **profitable**, and where does it make or lose money?
2. Are orders **delivered on time**, and which shipping modes or regions have problems?
3. Which **products, categories, customer segments and markets** drive sales?

## 2. Key findings

All figures use **Net Sales** (Gross Sales minus discount) unless stated otherwise.

| Metric | Value |
|---|---|
| Net Sales | $33.05M (Gross Sales $36.78M, discounts $3.73M) |
| Profit | $3.97M (margin 12.0% of Net Sales) |
| Orders / order lines / customers | 65,752 / 180,519 / 20,652 |
| Late delivery rate | 54.8% of order lines |
| Loss-making order lines | 18.7% (total loss $3.88M) |

- **Faster shipping modes are the most late.** First Class is late 95.3% of the time (promised 1 day, takes 2.0 on average). Second Class is late 76.6% (promised 2 days, takes 4.0). Standard Class is late 38.1%.
- **Late rates are similar in every region (about 49% to 58%).** This points to a process problem, not a regional one.
- **Losses are spread across order lines, not whole products.** Only 3 of 118 products have negative total profit, but 18.7% of order lines lose money. Fan Shop, Apparel and Golf account for about 80% of the losses.
- **The average discount rate is about the same on loss-making lines (10.2%) and profitable lines (10.2%),** so discounting alone does not explain the losses.
- **The business is concentrated.** Fan Shop is 46.5% of Net Sales, Consumer customers 51.9%, and Europe plus LATAM 57.5%.

### Recommendations

1. **Fix First and Second Class shipping.** Renegotiate carrier terms or reset the promised delivery days. If both modes matched Standard Class's late rate, late lines would fall by about 30% (from 54.8% to about 38.5%). This is an estimate based on historical rates.
2. **Review loss-making products** in Fan Shop, Apparel and Golf: price, cost and returns.
3. **Investigate the late-2017 sales drop** and the cancelled and suspected-fraud orders (4.3% of Net Sales).

---

## 3. Workflow

```
Raw CSV  →  Python (pandas)  →  Cleaned CSV  →  SQL Server  →  Power BI
(49 cols)   clean + segment     (43 cols)      analysis        dashboard
```

### Step 1: Python (`notebooks/supplychain.ipynb`)
- Loaded the raw file with `latin1` encoding and worked on a copy.
- Checked for duplicate rows (none) and missing values.
- Dropped 9 redundant or mostly empty columns: `Benefit per order`, `Sales per customer`, `Product Category Id`, `Order Customer Id`, `Order Item Cardprod Id`, `Order Item Product Price`, `Order Zipcode`, `Customer Zipcode`, `Product Status`.
- Converted `order date` and `shipping date` to datetime.
- Created three segmentation columns:

| Column | Rule |
|---|---|
| `Profit Segment` | Profit (> 0), Loss (< 0), Break Even (= 0) based on `Order Profit Per Order` |
| `Shipping Segment` | Fast (≤ 2 actual days), Normal (3 to 5), Slow (> 5) |
| `Sales Segment` | Quartiles of `Sales`: Low, Medium, High, Very High |

- Exported `cleaned_supply_chain_data.csv` (180,519 rows, 43 columns).

### Step 2: SQL Server (`sql/Supply_Chain.sql`)
Loaded the cleaned CSV into SQL Server and answered business questions on:
- Sales and profit by country, region, category, product and customer segment
- Monthly and yearly sales trends
- Late-delivery rate by shipping mode
- Scheduled vs actual shipping days, and delay distribution
- Loss-making products and order lines

Notes on method: one row is one order **line**, so orders are counted with `COUNT(DISTINCT Order_Id)`. `AVG` on integer day columns is cast to `float` to avoid truncation.

### Step 3: Power BI (`powerbi/SupplyChainDashboard.pbix`)
- Data model with a Date table and DAX measures
- Custom theme (`DataCo_Supply_Chain.json`), page background images and logo
- Four synced slicers across pages: Year, Shipping Mode, Customer Segment, Market
- Page navigator and a "Clear all slicers" button on each page

---

## 4. Dashboard pages

| Page | Purpose | Main visuals |
|---|---|---|
| **Executive Overview** | Business health in 10 seconds | 6 KPI cards, Sales and Profit trend, Sales by Market, Sales by Category, Delivery Status by Shipping Mode, "Where Profit Leaks" |
| **Delivery & Logistics Performance** | Where and how deliveries fail | Late %, On-Time %, Avg Actual vs Scheduled Days, Late % by Shipping Mode and Region, Delivery Status trend, Shipping Segment treemap |
| **Sales & Profitability** | What makes and loses money | YoY Sales %, Sales vs Profit by product, Profit by Customer Segment, Top and Bottom 10 products, Product table |
| **Customers & Geography** | Who buys and where | Customers, Avg Orders and Sales per Customer, Top Market, Sales map, Top 10 Countries, Sales by Transaction Type, Region detail table |
| **Data & Notes** | Source, definitions, assumptions, insights and recommendations | Documentation |

![Delivery & Logistics](images/page2_delivery_logistics.png)
![Sales & Profitability](images/page3_sales_profitability.png)
![Customers & Geography](images/page4_customers_geography.png)

### Key measures

| Measure | Definition |
|---|---|
| Net Sales | Sum of `Order Item Total` (Sales minus discount) |
| Profit | Sum of `Order Profit Per Order` |
| Profit Margin % | Profit ÷ Net Sales |
| Total Orders | Distinct count of `Order Id` |
| Late Delivery % | Share of order lines with `Late_delivery_risk = 1` |
| On Time % | 1 − Late Delivery % |
| Avg Actual Days / Avg Schedule Days | Average of actual and scheduled shipping days |
| Avg Delay Days | Actual days − scheduled days |
| Loss Making Items % | Share of order lines with a negative profit |
| Loss Amount | Total profit of loss-making lines |
| YoY Sales % | Net Sales growth vs the same period last year |

---

## 5. Limitations

- **Public dataset.** The results demonstrate the analysis, not the performance of a real company.
- **2018 contains only January,** so it can't be compared with full years.
- **Sales fall in November and December 2017 while orders rise.** The data does not explain this, so that period should be read with caution.
- **Metrics are at order-line level.** The late rate is also 54.8% when counted by whole order.
- **Cancelled and suspected-fraud orders are included in totals** (2,855 orders, $1.41M Net Sales, 4.3%).
- **Country names are used as they appear in the source data,** and some are in Spanish (for example "Estados Unidos"). The map visual may not place every country correctly. Translating them to English is a planned improvement.
- **Small samples by country.** 52 of 164 countries have fewer than 50 order lines.
- **Association, not cause.** The data has no carrier, warehouse or weather information, so it cannot explain *why* deliveries are late.
- **Gross vs Net.** The SQL scripts and the Python exploration use `Sales` (gross); the dashboard uses Net Sales.

## 6. Repository structure

```
├── data/
│   ├── cleaned_supply_chain_data.csv      # output of the Python step
│   └── README.md                          # link to the raw dataset (see note below)
├── notebooks/
│   └── supplychain.ipynb                  # cleaning, validation, segmentation
├── sql/
│   └── Supply_Chain.sql                   # business-question queries
├── powerbi/
│   ├── SupplyChainDashboard.pbix
│   └── DataCo_Supply_Chain.json           # theme file
├── images/                                # dashboard screenshots, logo
└── README.md
```

> **File size note:** the raw CSV is about 76 MB and the cleaned CSV about 70 MB. GitHub warns above 50 MB and blocks files over 100 MB. Either link to the Kaggle page for the raw file, or use [Git LFS](https://git-lfs.com).

## 7. How to reproduce

1. Download the raw dataset from the Kaggle link above and save it as `DataCoSupplyChainDataset.csv`.
2. Open `notebooks/supplychain.ipynb` and run all cells. This creates `cleaned_supply_chain_data.csv`.
3. Import the cleaned CSV into SQL Server as `dbo.cleaned_supply_chain_data` and run `sql/Supply_Chain.sql`.
4. Open `powerbi/SupplyChainDashboard.pbix` in Power BI Desktop. If the data source path breaks, go to **Transform data → Data source settings** and point it to your copy of the cleaned CSV.
5. Optional: import the theme with **View → Themes → Browse for themes**.

**Requirements:** Python 3.9+ (pandas, numpy, matplotlib, seaborn), SQL Server, Power BI Desktop.

## 8. Skills demonstrated

- Data cleaning and validation with Python (pandas)
- Feature engineering and segmentation
- T-SQL: aggregation, window functions, CTEs, `HAVING`, `CASE`
- Data modeling and DAX measures in Power BI
- Dashboard design: layout, theme, KPI selection, interactivity
- Turning data into business insights and recommendations

## 9. Author

**[Your name]**
[LinkedIn link] · [Email] · [Portfolio link]

## 10. Acknowledgements

Dataset: DataCo Smart Supply Chain, available on [Kaggle](https://www.kaggle.com/datasets/saicharankomati/dataco-supply-chain-dataset). Check the dataset page for its license before redistributing the data.
