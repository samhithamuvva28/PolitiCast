# NYT Political Articles Data Pipeline (Airflow + AWS S3 + BigQuery)

An end‑to‑end ELT pipeline that collects political articles from the New York Times Archive API, stores raw data in Amazon S3, performs incremental consolidation and format conversion (CSV ➜ JSON ➜ NDJSON), preprocesses for analytics, and models the data in Google BigQuery using a star schema for downstream analysis. The repository also includes notebooks for topic modeling, sentiment analysis, and hypothesis testing.

---

## Overview
- Fetch monthly NYT Archive data and filter to politics articles.
- Land raw CSVs in S3 and incrementally merge updates.
- Convert to NDJSON and clean fields and timestamps.
- Load to BigQuery (staging) and build a star schema for analytics.
- Run SQL analyses and notebooks (topic modeling, sentiment, hypothesis testing).

Data sources: NYT Archive API. Storage: AWS S3. Orchestration: Apache Airflow. Warehouse: BigQuery.

---

## Architecture
1. Ingestion (Airflow DAG `fetch_political_nytimes_data_S3`)
   - Calls NYT Archive API per year/month.
   - Filters to politics articles.
   - Writes monthly CSVs to S3 under `s3://<bucket>/NYTData/<year>/<month>.csv`.
2. Incremental Load (Airflow DAG `incremental_load_csv_s3`)
   - Consolidates monthly CSVs into a latest snapshot.
   - Publishes merged file(s) back to S3.
3. Conversion (Airflow DAG `convert_json_to_ndjson`)
   - Converts JSON to NDJSON and writes to S3.
4. Preprocessing (Airflow DAG `ndjson_preprocessing`)
   - Cleans nulls, removes heavy fields (e.g., multimedia), fixes timestamps.
   - Outputs processed NDJSON to S3 (query‑ready).
5. Warehouse Modeling (BigQuery)
   - Load processed NDJSON into `archive.staging`.
   - Build dimensions and fact tables via `star_schema.sql`.
6. Analytics
   - Run `queries_bigquery.sql` for trends, keyword and author analyses.
   - Use notebooks for NLP/ML and statistical analysis.

A master DAG (`main_dag`) triggers the sub‑DAGs in order.

---

## Repository Layout
Current files:
- Airflow DAGs
  - `fetching_real-time_api_data_to_S3.py`
  - `incremental_load.py`
  - `converting_json_to_ndjson.py`
  - `pre-processing_ndjson.py`
  - `schedule_dag_tasks.py` (orchestrator)
- BigQuery
  - `star_schema.sql`
  - `queries_bigquery.sql`
- Notebooks
  - `Topic_Modeling_Sentiment_Analysis.ipynb`
  - `Hypothesis_Testing.ipynb`
  - `archived_data_preprocessing.ipynb`
  - `data_upload_to_MongoDB.ipynb` (optional path; not required for core pipeline)

Suggested structure for long‑term maintenance:
- `dags/` (all Airflow DAGs)
- `sql/` (`star_schema.sql`, `queries_bigquery.sql`)
- `notebooks/` (Jupyter notebooks)
- `scripts/` (one‑off utilities)
- `requirements.txt` (Python deps)
- `README.md`

---

## Prerequisites
- Python 3.9+
- Apache Airflow 2.x
- AWS account with S3 bucket
- GCP project with BigQuery dataset (e.g., `archive`)
- NYT Archive API key

Recommended Airflow providers:
- `apache-airflow-providers-amazon`
- `apache-airflow-providers-google`

Core Python packages (minimum):
- `requests`, `boto3`, `pandas`, `pendulum`

---

## Configuration
Use environment variables and/or Airflow Connections. Do not hardcode secrets.

Environment variables (example):
- `NYT_API_KEY` — NYT Archive API key
- `S3_BUCKET` — Target S3 bucket name
- `AWS_DEFAULT_REGION`, `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` — If not using instance/IAM role
- `MONGODB_URI` — Only if using the MongoDB upload notebook
- `GCP_PROJECT` — BigQuery project (for doc consistency)

Airflow Connections (recommended):
- `aws_default` — AWS credentials/region for S3 (used by S3Hook)
- `google_cloud_default` — GCP creds for BigQuery

---

## Deploying DAGs
1. Install Airflow and providers, configure a metastore and executor.
2. Place DAG files under `$AIRFLOW_HOME/dags` (or mount the repo path).
3. Configure connections in Airflow UI (Admin ➜ Connections) or via env.
4. Start scheduler and webserver; enable the following DAGs:
   - `fetch_political_nytimes_data_S3`
   - `incremental_load_csv_s3`
   - `convert_json_to_ndjson`
   - `ndjson_preprocessing`
   - `main_dag` (orchestrates the above)

Notes
- The `pre-processing_ndjson.py` DAG uses `S3Hook(aws_conn_id='aws_default')`.
- Some DAGs currently use `boto3` directly; you can migrate to Hooks for Airflow‑managed credentials.

---

## BigQuery Modeling and Analytics
- Load the processed NDJSON from S3 into BigQuery staging (via transfer service or one‑time export).
- Run `sql/star_schema.sql` to create dimension and fact tables.
- Run `sql/queries_bigquery.sql` for example analyses:
  - Keywords over time
  - Author contributions by year
  - Election‑related trends
  - Region/topic distributions

Example (CLI):
```bash
bq query --use_legacy_sql=false < sql/star_schema.sql
bq query --use_legacy_sql=false < sql/queries_bigquery.sql
```

---

## Notebooks
- `Topic_Modeling_Sentiment_Analysis.ipynb` — NLP topic modeling and sentiment analysis.
- `Hypothesis_Testing.ipynb` — Statistical tests on article distributions.
- `archived_data_preprocessing.ipynb` — Exploratory cleaning and shaping.
- `data_upload_to_MongoDB.ipynb` — Optional Mongo bulk load; not required for the S3/BigQuery pipeline.

Run with a kernel that has the requirements installed.

---

## Security and Compliance
- Never commit secrets. Replace any hardcoded keys/URIs with environment variables or Airflow connections.
- Add a `.env.example` with variable names only and a `.gitignore` to exclude `.env`.
- Use IAM roles/instance profiles where possible instead of static keys.

---

## Known Issues / TODO
- Update Airflow imports to v2 style where needed (e.g., `TriggerDagRunOperator` import path).
- `converting_json_to_ndjson.py`: fix `default_args` (`retries` value missing), add `from datetime import timedelta`.
- `pre-processing_ndjson.py`: add `from datetime import timedelta` import.
- `incremental_load.py`: implement the placeholder functions and define `incremental_load_csv_s3` or update the operator to call an existing function.
- Parameterize S3 bucket and keys via env/variables; avoid hardcoded names.
- Add `requirements.txt` and pin versions; consider `constraints` for Airflow.
- Optionally refactor to use Airflow Hooks for S3/HTTP for better observability.

---

## Quickstart (Local)
1. Create and activate a virtual environment.
2. Install Airflow and providers (or use an existing deployment).
3. Export required env vars and configure Airflow connections.
4. Put DAGs under `dags/` and start scheduler/webserver.
5. Trigger `main_dag` or run sub‑DAGs sequentially.
6. Load to BigQuery and run SQL queries.

---

## License
Choose a license for your repository (e.g., MIT) and include a `LICENSE` file.

## Acknowledgments
- New York Times Archive API
- Apache Airflow, AWS S3, Google BigQuery
