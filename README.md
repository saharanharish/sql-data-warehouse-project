# SQL Data Warehouse & Analytics Project

A SQL Server data warehouse project that integrates CRM and ERP data,
applies data-quality transformations, and organizes the data into a
Bronze--Silver--Gold architecture for analytics and reporting.

## Project Overview

The goal of this project is to build a modern data warehouse that
consolidates sales and customer data from CSV files supplied by two
source systems: **CRM** and **ERP**. The project demonstrates data
ingestion, transformation, data modelling, and preparation of data for
analytical queries.

### Objectives

-   Build a data warehouse using Microsoft SQL Server.
-   Ingest six source CSV files into a Bronze layer.
-   Clean and standardize data in the Silver layer.
-   Combine CRM and ERP data into business-friendly Gold views.
-   Model sales data using a fact-and-dimension approach.
-   Prepare the warehouse for SQL analysis and Power BI reporting.
-   Document the architecture, data flow, and data model.

## Architecture

This project follows the **Medallion Architecture**:

![Data Architecture](docs/data_architecture.png)

  -----------------------------------------------------------------------
  Layer                   Purpose                 Implementation
  ----------------------- ----------------------- -----------------------
  **Bronze**              Preserve source data    CSV data loaded into
                          with minimal            SQL Server tables.
                          transformation.         

  **Silver**              Clean, standardize, and SQL transformations,
                          integrate source data.  data-type handling,
                                                  deduplication, and code
                                                  normalization.

  **Gold**                Provide                 Customer and product
                          business-friendly data  dimensions and a sales
                          for analytics.          fact view designed
                                                  around a star-schema
                                                  approach.
  -----------------------------------------------------------------------

## Data Sources

The project uses six CSV files from the CRM and ERP source systems.

  Source system   Source file           Bronze table
  --------------- --------------------- ----------------------------
  CRM             `cust_info.csv`       `bronze.crm_cust_info`
  CRM             `prd_info.csv`        `bronze.crm_prd_info`
  CRM             `sales_details.csv`   `bronze.crm_sales_details`
  ERP             `cust_az12.csv`       `bronze.erp_cust_az12`
  ERP             `loc_a101.csv`        `bronze.erp_loc_a101`
  ERP             `px_cat_g1v2.csv`     `bronze.erp_px_cat_g1v2`

The original CSV files are located in the `datasets/` directory.

## Technology Stack

-   **Database:** Microsoft SQL Server Express
-   **SQL development:** SQL Server Management Studio (SSMS)
-   **Data processing:** T-SQL, stored procedures, views, and SQL
    transformations
-   **Architecture and modelling:** Draw.io
-   **Documentation and project planning:** Markdown and Notion
-   **Version control:** Git and GitHub
-   **Reporting readiness:** Power BI

## Repository Structure

``` text
data-warehouse-project/
│
├── datasets/
│   ├── source_crm/
│   └── source_erp/
│
├── docs/
│   ├── data_architecture.drawio
│   ├── data_architecture.png
│   ├── data_flow.drawio
│   ├── data_models.drawio
│   ├── etl.drawio
│   ├── data_catalog.md
│   ├── naming-conventions.md
│   └── requirements.md
│
├── scripts/
│   ├── bronze/
│   ├── silver/
│   └── gold/
│
├── tests/
├── README.md
├── LICENSE
└── .gitignore
```

*The directory listing above describes the intended repository layout.
Keep only files and folders that are actually present in your GitHub
repository.*

## ETL Workflow

### 1. Bronze Layer --- Data Ingestion

The Bronze layer stores data loaded from the six CRM and ERP CSV files.

Key tasks: - Create source-aligned SQL Server tables. - Load CSV files
using SQL Server bulk-loading operations. - Keep the raw layer available
for downstream transformations. - Use the `bronze.load_bronze` stored
procedure to run the Bronze loading process.

### 2. Silver Layer --- Cleansing and Standardization

The Silver layer applies transformations before data is used for
analytics.

Examples of transformations: - Trim leading and trailing spaces. -
Standardize customer marital-status and gender values. - Remove customer
records with missing customer IDs. - Retain the latest customer record
using `ROW_NUMBER()`. - Derive product category and product keys from
source product keys. - Standardize product-line and country values. -
Convert valid sales dates to SQL `DATE` values and represent invalid
dates as `NULL`. - Clean customer identifiers and handle invalid future
birth dates. - Load the ERP product-category data.

The `silver.load_silver` stored procedure reloads the six Silver tables
from Bronze and prints loading-duration information.

### 3. Gold Layer --- Analytics Model

The Gold layer exposes business-friendly views intended for analytical
queries and reporting.

  -----------------------------------------------------------------------
  Gold object                         Purpose
  ----------------------------------- -----------------------------------
  `gold.dim_customers`                Customer attributes enriched with
                                      available ERP birth-date, gender,
                                      and country information.

  `gold.dim_products`                 Product attributes enriched with
                                      category and subcategory
                                      information.

  `gold.fact_sales`                   Sales transactions with order
                                      dates, shipping dates, quantities,
                                      prices, sales amounts, and
                                      customer/product keys.
  -----------------------------------------------------------------------

The intended model follows a **star-schema pattern**: the sales fact is
connected to customer and product dimensions.

Gold joins and key relationships should be validated against the actual
data before relying on the views for business reporting.

## Current Data Load Snapshot

The following row counts were observed during development. They are a
snapshot, not a guarantee that future reloads will produce identical
counts.

### Bronze layer

  Table                          Rows observed
  ---------------------------- ---------------
  `bronze.crm_cust_info`                18,493
  `bronze.crm_prd_info`                    397
  `bronze.crm_sales_details`            60,398
  `bronze.erp_cust_az12`                18,483
  `bronze.erp_loc_a101`                 18,484
  `bronze.erp_px_cat_g1v2`                  37

### Silver layer

  Table                          Rows observed
  ---------------------------- ---------------
  `silver.crm_cust_info`                18,484
  `silver.crm_prd_info`                    397
  `silver.crm_sales_details`            60,398
  `silver.erp_cust_az12`                18,483
  `silver.erp_loc_a101`                 18,484
  `silver.erp_px_cat_g1v2`                  37

The Silver customer count is lower than the Bronze count because the
transformation excludes null customer IDs and keeps one latest record
per customer ID.

## Getting Started

### Prerequisites

1.  Install [SQL Server
    Express](https://www.microsoft.com/en-us/sql-server/sql-server-downloads).
2.  Install [SQL Server Management Studio
    (SSMS)](https://learn.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms).
3.  Clone or download this repository.
4.  Ensure the CSV files are available locally and update file paths in
    the loading scripts to match your machine.
5.  Connect to your SQL Server instance through SSMS.

### Setup and execution

1.  Create the `DataWarehouse` database.

2.  Run the Bronze DDL scripts to create the Bronze tables.

3.  Update the CSV file paths in the Bronze loading scripts.

4.  Execute the Bronze loading procedure:

    ``` sql
    EXEC bronze.load_bronze;
    ```

5.  Run the Silver DDL scripts to create the Silver tables.

6.  Create or update the Silver loading procedure, then execute it:

    ``` sql
    EXEC silver.load_silver;
    ```

7.  Verify row counts and data quality in the Silver tables.

8.  Run the Gold scripts to create the Gold views.

9.  Validate dimension keys, joins, and fact row counts before using the
    model for reporting.

> **Important:** The Bronze and Silver loading procedures use a
> truncate-and-reload pattern. Review the scripts and confirm the source
> paths and target database before running them. Do not run loading
> procedures against a database containing data you need to preserve
> without understanding their effects.

## Validation and Data Quality

Suggested checks include:

-   Compare Bronze and Silver row counts.
-   Check for duplicate customer IDs and product IDs.
-   Confirm expected data types, especially for dates.
-   Check that invalid source dates are represented as `NULL`.
-   Review standardized values such as gender, marital status, product
    line, and country.
-   Validate that product category IDs match the ERP category table.
-   Validate customer joins across CRM and ERP.
-   Confirm that joins in the Gold fact view do not multiply sales
    records.
-   Check unmatched customer and product keys before reporting.

## Documentation

Project documentation and diagrams are intended to live in `docs/`:

-   `data_architecture.drawio` --- overall architecture.
-   `data_flow.drawio` --- movement of data through the layers.
-   `data_models.drawio` --- data model and star schema.
-   `etl.drawio` --- ETL process.
-   `data_catalog.md` --- source and column descriptions.
-   `naming-conventions.md` --- naming conventions.
-   `requirements.md` --- analytics requirements.

## Future Improvements

-   Add repeatable automated data-quality tests.
-   Improve load logging and error handling.
-   Add transaction handling so a failed multi-table load can be rolled
    back consistently.
-   Validate all Gold joins and document unmatched records.
-   Build Power BI dashboards for customer behaviour, product
    performance, and sales trends.
-   Add screenshots of the final data model and dashboard to the
    repository.

## License

This project is distributed under the MIT License. See
[`LICENSE`](LICENSE) for details.

## Acknowledgements

This project was inspired by the SQL Data Warehouse Project learning
materials from [Data With Baraa](https://www.datawithbaraa.com/) and the
related [GitHub
repository](https://github.com/DataWithBaraa/sql-data-warehouse-project).

The project is adapted for learning and portfolio development. Dataset
attribution and licensing should follow the terms provided with the
original project materials.
