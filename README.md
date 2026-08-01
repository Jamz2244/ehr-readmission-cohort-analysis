# EHR 30-Day Readmission Cohort Analysis

Exploratory cohort analysis of hospital readmissions using synthetic EHR data. Built to demonstrate SQL-based clinical data analysis, data quality investigation, and healthcare domain knowledge.

---

## Key Findings

- **Raw 30-day readmission rate: 13.4%** (165 readmission pairs, 43 patients)
- **Adjusted 30-day readmission rate: 3.1%** (37 pairs, 32 patients) after excluding planned chemotherapy cycling encounters
- Adjusted cohort is driven by **cardiac conditions** (coronary artery disease, aortic valve stenosis, CHF), **COVID-19**, and **kidney transplant** — a clinically realistic readmission profile
- Identified a data-generation artifact where Synthea models recurring NSCLC treatment cycles as separate inpatient encounters within 30 days, inflating the raw readmission rate; excluded these to isolate true unplanned readmissions

---

## Tech Stack

| Tool | Purpose |
|---|---|
| Python 3.13 | Analysis and visualization |
| DuckDB 1.5.3 | SQL queries directly against CSV files |
| pandas | DataFrame manipulation |
| matplotlib | Visualization |
| Jupyter Notebook | Interactive analysis environment |
| Synthea | Synthetic EHR data generation |
| Git + GitHub | Version control |

---

## Project Structure

```
ehr-readmission-cohort-analysis/
├── notebooks/
│   ├── 01_data_exploration.ipynb   # Cohort building and analysis
│   └── 02_visualization.ipynb      # Charts and visual summaries
├── sql/
│   └── readmission_cohort.sql      # Standalone SQL cohort query
├── reports/
│   ├── age_distribution.png
│   ├── age_distribution_adjusted.png
│   ├── top_conditions_adjusted.png
│   └── raw_vs_adjusted_rate.png
├── data/                           # Gitignored — not tracked
│   ├── raw/                        # Synthea JAR
│   └── processed/
├── output/                         # Gitignored — Synthea CSV output
└── src/
```

---

## Reproducing This Project

### 1. Prerequisites

- Python 3.10+
- Java (OpenJDK 11+)
- Git

### 2. Clone the repo

```bash
git clone https://github.com/Jamz2244/ehr-readmission-cohort-analysis.git
cd ehr-readmission-cohort-analysis
```

### 3. Install dependencies

```bash
pip install duckdb pandas matplotlib notebook
```

### 4. Generate Synthea data

Download `synthea-with-dependencies.jar` from [Synthea releases](https://github.com/synthetichealth/synthea/releases/latest) and place it in `data/raw/`. Then run:

```bash
java -jar data/raw/synthea-with-dependencies.jar -p 1000 Massachusetts --exporter.csv.export=true
```

This generates ~1,183 synthetic patient records in `output/csv/`.

### 5. Run the notebooks

```bash
jupyter notebook
```

Open `notebooks/01_data_exploration.ipynb` first, then `02_visualization.ipynb`.

---

## Methodology

### Readmission Definition
A 30-day readmission is defined as an inpatient encounter followed by another inpatient encounter for the same patient within 30 calendar days of discharge. This mirrors the CMS Hospital Readmissions Reduction Program (HRRP) definition.

### Cohort Construction
The core query uses a self-join on the encounters table, filtering to `ENCOUNTERCLASS = 'inpatient'` and computing the difference in days between one encounter's discharge date and the next encounter's admission date.

### Data Quality: Chemotherapy Cycling Artifact
Synthea generates recurring chemotherapy and treatment cycles as separate inpatient encounters. For patients with Non-Small Cell Lung Cancer (NSCLC), this produces 4-6 week treatment intervals that fall within the 30-day readmission window but represent **planned, scheduled care** rather than unplanned readmissions.

11 NSCLC patients contributed 126 of the 165 raw readmission pairs (76%), inflating the raw rate from a true ~3% to 13.4%. The adjusted analysis excludes these patients to produce a clinically meaningful readmission rate.

This pattern mirrors a real-world data quality challenge in EHR analytics — distinguishing planned recurring admissions (chemotherapy, dialysis, scheduled procedures) from true unplanned readmissions is a standard step in hospital quality reporting pipelines.

---

## Data Source

Synthetic patient data generated using [Synthea](https://github.com/synthetichealth/synthea) — an open-source synthetic patient generator developed by MITRE. Data is not real and contains no PHI.

