-- 30 day readmission cohort analysis
-- uses Synthea-generated synthetic EHR data queried via DuckDB
-- identifies inpatient encounters followed by another inpatient encounter within 30 days 
-- excludes planned chemotherapy cycling (NCSLC patients) to isolate true unplanned readmissions

-- set CSV path before running (update to match local output directory)
-- CSV_PATH = '../output/csv'

WITH inpatient AS (
    SELECT
        Id AS encounter_id,
        PATIENT,
        START AS admit_date,
        STOP AS discharge_date,
        REASONDESCRIPTION AS reason
    FROM read_csv_auto('../output/csv/encounters.csv')
    WHERE ENCOUNTERCLASS = 'inpatient'
),

readmissions AS (
    SELECT
        a.PATIENT,
        a.encounter_id AS index_encounter,
        a.admit_date AS index_admit,
        a.discharge_date AS index_discharge,
        a.reason AS index_reason,
        a.encounter_id AS readmit_encounter,
        b.admit_date AS readmit_date,
        DATEDIFF ('day', a.discharge_date, b.admit_date) AS days_to_readmit
    FROM inpatient a 
    JOIN inpatient b 
        ON a.PATIENT = b.PATIENT
        AND b.admit_date > a.discharge_date
        AND DATEDIFF('day', a.discharge_date, b.admit_date) <= 30
        AND a.encounter_id != b.encounter_id
)

SELECT
    r.*,
    p.GENDER, 
    p.RACE,
    p.BIRTHDATE,
    DATE_DIFF('year', CAST(p.BIRTHDATE AS DATE), CAST(r.index_discharge AS DATE)) AS age_at_discharge
FROM readmissions r 
JOIN read_csv_auto('../output/csv/patients.csv') p
    ON r.PATIENT = p.Id
ORDER BY r.PATIENT, r.index_admit;