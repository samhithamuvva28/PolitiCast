# PolitiCast — Election Analytics Data Pipeline

PolitiCast is a **cloud-native election analytics and prediction system** that processes large-scale historical and real-time political news data from the New York Times to analyze public sentiment, media trends, and election-related discourse.

The project implements a **production-style data pipeline** using **Apache Airflow**, **AWS S3**, and **Google BigQuery**, supporting incremental ingestion, scalable warehousing, and downstream analytics including **sentiment analysis, topic modeling, and statistical evaluation**.

---

## 🔍 What This Project Demonstrates

- End-to-end **data engineering pipelines** for large, semi-structured text data  
- **Incremental ETL orchestration** using Apache Airflow (MWAA-compatible)
- Analytical data modeling using a **star schema** in BigQuery
- **NLP and statistical analysis** applied to real-world political data
- Systems built with **scalability, reproducibility, and data integrity** in mind

---

## 🧠 System Overview

**Data Sources**
- New York Times Archive API (historical + monthly real-time updates)

**Pipeline Flow**
1. Fetch monthly NYT archive data via API
2. Filter political articles
3. Store raw CSVs in AWS S3
4. Perform incremental consolidation to avoid duplication
5. Convert data formats (CSV → JSON → NDJSON)
6. Clean and normalize fields for analytics
7. Load into BigQuery staging tables
8. Build star-schema fact and dimension tables
9. Run analytical queries, NLP models, and statistical tests

---

## 🏗 Architecture

### Ingestion
- **Airflow DAG:** `fetch_political_nytimes_data_S3`
- Pulls NYT archive data by year/month
- Filters to political content
- Writes monthly CSVs to: s3://<bucket>/NYTData/<year>/<month>.csv

- 
### Incremental Load
- **Airflow DAG:** `incremental_load_csv_s3`
- Merges new data with existing snapshots
- Ensures idempotent updates without duplication

### Transformation
- **Airflow DAG:** `convert_json_to_ndjson`
- Converts consolidated JSON to NDJSON
- Optimized for analytical warehouses

### Preprocessing
- **Airflow DAG:** `ndjson_preprocessing`
- Removes heavy/unnecessary fields
- Cleans nulls and timestamps
- Produces query-ready NDJSON

### Orchestration
- **Master DAG:** `main_dag`
- Triggers sub-DAGs sequentially to enforce data integrity

---

## 📊 Data Warehouse & Analytics

**Warehouse**
- Google BigQuery
- Staging + analytics datasets
- **Star schema** with:
- Fact table: Articles
- Dimension tables: Authors, Keywords, Headlines, Publications, Sources

**Analytics**
- Keyword trends over time
- Author contributions by year
- Election-related topic frequency
- Geographic and subject-level distributions

SQL examples:
sql/star_schema.sql
sql/queries_bigquery.sql

---

## 🤖 Modeling & Statistical Analysis

Included notebooks cover:
- Topic modeling (LDA)
- Sentiment analysis (Logistic Regression, VADER)
- Hypothesis testing and correlation analysis

These analyses explore:
- Public sentiment around political figures
- Election-year discourse shifts
- Relationships between article characteristics and sentiment

---
## 📁 Repository Structure
dags/ # Airflow DAGs
sql/ # BigQuery schema and queries
notebooks/ # NLP and statistical analysis
scripts/ # One-off utilities
docs/ # Case study + full report
requirements.txt
README.md


---

## ⚙️ Prerequisites

- Python 3.9+
- Apache Airflow 2.x
- AWS account with S3
- GCP project with BigQuery
- NYT Archive API key

---

## 🔐 Configuration & Security

- Secrets managed via **environment variables or Airflow Connections**
- No credentials committed to the repository
- IAM roles recommended over static access keys

Example environment variables:
NYT_API_KEY
S3_BUCKET
GCP_PROJECT


---

## 📄 Documentation
- **Full Project Report:** `artifacts/Detailed_Report.pdf`


---

## 🙌 Acknowledgments

- New York Times Archive API  
- Apache Airflow  
- AWS S3  
- Google BigQuery  
