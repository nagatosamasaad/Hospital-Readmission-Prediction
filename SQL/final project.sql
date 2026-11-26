
USE carelyticsdata;

/*-----------------------------------------------------Database Exploration*/

DESCRIBE carelytics;

SELECT COUNT(*) AS carelytics
FROM carelytics;

SELECT COUNT(DISTINCT patient_id) AS Total_Patients
FROM carelytics;

/*------------------------------------------------------------Check Missing Patient IDs*/

SELECT
    COUNT(*) AS Total_Rows,
    COUNT(patient_id) AS Non_Null_Patient_IDs,
    COUNT(*) - COUNT(patient_id) AS Missing_Patient_IDs
FROM carelytics;
---------------------------/* we have no missing values*/


/*------------------------------------------------------------Check Repeated Patient Visits*/
SELECT
    patient_id,
    visit_date,
    COUNT(*) AS Record_Count
FROM carelytics
GROUP BY patient_id, visit_date
HAVING COUNT(*) > 1
ORDER BY Record_Count DESC
LIMIT 20;

/* the same patient has Multiple visits */


/*--------------------------------------------------------------------2-Data Quality Assessment*/

/*--------------------------------------------------------------------Count Records with Repeated Patient & Visit Datet*/

SELECT
    COUNT(*) AS Repeated_Groups,
    SUM(Record_Count) AS Total_Records_In_Groups
FROM (
    SELECT
        patient_id,
        visit_date,
        COUNT(*) AS Record_Count
    FROM carelytics
    GROUP BY patient_id, visit_date
    HAVING COUNT(*) > 1
) AS Duplicates;

/*--------------------------------------------------------------------Check Whether the Records Are Identical*/

SELECT *
FROM carelytics
WHERE patient_id = 'ca584efb9b6af9de'
  AND visit_date = '2023-03-01';
 ------------ /* it isn't dupicated*/
 
 
  /*--------------------------------------------------------------------Check Missing Values*/

SELECT
    SUM(CASE WHEN visit_date IS NULL OR TRIM(visit_date) = '' THEN 1 ELSE 0 END) AS Missing_Visit_Date,

    SUM(CASE WHEN discharge_date IS NULL OR TRIM(discharge_date) = '' THEN 1 ELSE 0 END) AS Missing_Discharge_Date,

    SUM(CASE WHEN diagnosis_text IS NULL OR TRIM(diagnosis_text) = '' THEN 1 ELSE 0 END) AS Missing_Diagnosis,

    SUM(CASE WHEN icd10 IS NULL OR TRIM(icd10) = '' THEN 1 ELSE 0 END) AS Missing_ICD10,

    SUM(CASE WHEN total_claim IS NULL THEN 1 ELSE 0 END) AS Missing_Total_Claim

FROM carelytics;

  /*--------------------------------------------------------------------Missing Values Analysis*/

SELECT
    COUNT(*) AS Total_Rows,

    SUM(CASE WHEN visit_date IS NULL OR TRIM(visit_date) = ''
        THEN 1 ELSE 0 END) AS Missing_Visit_Date,

    ROUND(
        SUM(CASE WHEN visit_date IS NULL OR TRIM(visit_date) = ''
        THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    ) AS Visit_Date_Missing_Percentage,

    SUM(CASE WHEN discharge_date IS NULL OR TRIM(discharge_date) = ''
        THEN 1 ELSE 0 END) AS Missing_Discharge_Date,

    ROUND(
        SUM(CASE WHEN discharge_date IS NULL OR TRIM(discharge_date) = ''
        THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    ) AS Discharge_Date_Missing_Percentage,

    SUM(CASE WHEN diagnosis_text IS NULL OR TRIM(diagnosis_text) = ''
        THEN 1 ELSE 0 END) AS Missing_Diagnosis,

    ROUND(
        SUM(CASE WHEN diagnosis_text IS NULL OR TRIM(diagnosis_text) = ''
        THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    ) AS Diagnosis_Missing_Percentage,

    SUM(CASE WHEN icd10 IS NULL OR TRIM(icd10) = ''
        THEN 1 ELSE 0 END) AS Missing_ICD10,

    ROUND(
        SUM(CASE WHEN icd10 IS NULL OR TRIM(icd10) = ''
        THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    ) AS ICD10_Missing_Percentage,

    SUM(CASE WHEN total_claim IS NULL
        THEN 1 ELSE 0 END) AS Missing_Total_Claim,

    ROUND(
        SUM(CASE WHEN total_claim IS NULL
        THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    ) AS Total_Claim_Missing_Percentage

FROM carelytics;

  /*--------------------------------------------------------------------Investigate Missing Discharge Dates*/

SELECT
    source_year,
    source_month,
    source_sheet,
    COUNT(*) AS Total_Records,

    SUM(
        CASE
            WHEN discharge_date IS NULL
              OR TRIM(discharge_date) = ''
            THEN 1 ELSE 0
        END
    ) AS Missing_Discharge,

    ROUND(
        SUM(
            CASE
                WHEN discharge_date IS NULL
                  OR TRIM(discharge_date) = ''
                THEN 1 ELSE 0
            END
        ) * 100.0 / COUNT(*), 2
    ) AS Missing_Percentage

FROM carelytics
GROUP BY source_year, source_month, source_sheet
ORDER BY Missing_Percentage DESC;

  /*--------------------------------------------------------------------Missing ICD10 with Available Diagnosis*/

SELECT
    COUNT(*) AS Missing_ICD10_Records,

    SUM(
        CASE
            WHEN diagnosis_text IS NOT NULL
             AND TRIM(diagnosis_text) <> ''
            THEN 1 ELSE 0
        END
    ) AS Diagnosis_Available,

    SUM(
        CASE
            WHEN diagnosis_text IS NULL
              OR TRIM(diagnosis_text) = ''
            THEN 1 ELSE 0
        END
    ) AS Diagnosis_Also_Missing

FROM carelytics
WHERE icd10 IS NULL
   OR TRIM(icd10) = '';
   
     /*--------------------------------------------------------------------   Check Missing Values in Other Important Columns*/
SELECT
    COUNT(*) AS Total_Rows,

    SUM(CASE WHEN age IS NULL THEN 1 ELSE 0 END) AS Missing_Age,

    SUM(CASE WHEN gender IS NULL OR TRIM(gender) = ''
        THEN 1 ELSE 0 END) AS Missing_Gender,

    SUM(CASE WHEN g_drg IS NULL OR TRIM(g_drg) = ''
        THEN 1 ELSE 0 END) AS Missing_G_DRG,

    SUM(CASE WHEN drugs_amount IS NULL
        THEN 1 ELSE 0 END) AS Missing_Drugs_Amount,

    SUM(CASE WHEN investigation_amount IS NULL
        THEN 1 ELSE 0 END) AS Missing_Investigation_Amount,

    SUM(CASE WHEN outpatient_amount IS NULL
        THEN 1 ELSE 0 END) AS Missing_Outpatient_Amount,

    SUM(CASE WHEN inpatient_amount IS NULL
        THEN 1 ELSE 0 END) AS Missing_Inpatient_Amount,

    SUM(CASE WHEN service_amount IS NULL
        THEN 1 ELSE 0 END) AS Missing_Service_Amount,

    SUM(CASE WHEN age_at_visit IS NULL
        THEN 1 ELSE 0 END) AS Missing_Age_At_Visit,

    SUM(CASE WHEN disease_category IS NULL
          OR TRIM(disease_category) = ''
        THEN 1 ELSE 0 END) AS Missing_Disease_Category,

    SUM(CASE WHEN target_disease_coarse IS NULL
          OR TRIM(target_disease_coarse) = ''
        THEN 1 ELSE 0 END) AS Missing_Target_Disease_Coarse

FROM carelytics;

/*------------------------------------------------------------Investigate Missing G_DRG*/

SELECT
    source_year,
    source_month,
    source_sheet,
    COUNT(*) AS Total_Records,

    SUM(
        CASE
            WHEN g_drg IS NULL OR TRIM(g_drg) = ''
            THEN 1 ELSE 0
        END
    ) AS Missing_G_DRG,

    ROUND(
        SUM(
            CASE
                WHEN g_drg IS NULL OR TRIM(g_drg) = ''
                THEN 1 ELSE 0
            END
        ) * 100.0 / COUNT(*), 2
    ) AS Missing_Percentage

FROM carelytics
GROUP BY source_year, source_month, source_sheet
HAVING Missing_G_DRG > 0
ORDER BY Missing_Percentage DESC;

/*------------------------------------------------------------Check Invalid Age*/
SELECT
    COUNT(*) AS Total_Records,

    SUM(CASE WHEN age < 0 THEN 1 ELSE 0 END) AS Negative_Ages,

    SUM(CASE WHEN age > 100 THEN 1 ELSE 0 END) AS Ages_Above_100,

    MIN(age) AS Minimum_Age,

    MAX(age) AS Maximum_Age,

    ROUND(AVG(age), 2) AS Average_Age

FROM carelytics;

/*------------------------------------------------------------Inspect Patients Above 100*/

SELECT
    patient_id,
    age,
    age_at_visit,
    age_source,
    age_conflict,
    visit_date,
    gender,
    diagnosis_text
FROM carelytics
WHERE age > 100
ORDER BY age DESC;

/*------------------------------------------------------------Investigate Age = 0*/

SELECT
    COUNT(*) AS Zero_Age_Records,
    COUNT(DISTINCT patient_id) AS Unique_Patients
FROM carelytics
WHERE age = 0;
/*------------------------------------------------------------Age Distribution*/

SELECT
    CASE
        WHEN age = 0 THEN '0 - Newborn'
        WHEN age BETWEEN 1 AND 17 THEN '1 - 17'
        WHEN age BETWEEN 18 AND 30 THEN '18 - 30'
        WHEN age BETWEEN 31 AND 45 THEN '31 - 45'
        WHEN age BETWEEN 46 AND 60 THEN '46 - 60'
        WHEN age BETWEEN 61 AND 75 THEN '61 - 75'
        WHEN age BETWEEN 76 AND 100 THEN '76 - 100'
        ELSE 'Above 100'
    END AS Age_Group,

    COUNT(*) AS Total_Patients

FROM carelytics
GROUP BY Age_Group
ORDER BY MIN(age);
/*------------------------------------------------------------Compare Age and Age at Visit*/

SELECT
    patient_id,
    age,
    age_at_visit,
    age_source,
    visit_date,
    age_conflict
FROM carelytics
WHERE age <> age_at_visit
ORDER BY patient_id, visit_date
LIMIT 100;
/*------------------------------------------------------------Investigate Age Sources*/

SELECT
    age_source,
    COUNT(*) AS Total_Records,
    MIN(age) AS Minimum_Age,
    MAX(age) AS Maximum_Age,
    ROUND(AVG(age), 2) AS Average_Age
FROM carelytics
GROUP BY age_source
ORDER BY Total_Records DESC;

/*------------------------------------------------------------Investigate Zero Ages*/

SELECT
    age_source,
    diagnosis_text,
    COUNT(*) AS Total_Records
FROM carelytics
WHERE age = 0
GROUP BY age_source, diagnosis_text
ORDER BY Total_Records DESC
LIMIT 30;
/*------------------------------------------------------------Investigate Ages Errors*/

SELECT *
FROM carelytics
WHERE patient_id IN (
    SELECT DISTINCT patient_id
    FROM carelytics
    WHERE age > 100 OR age = 0
)
ORDER BY patient_id, visit_date;

/*------------------------------------------------------------Fixing Ages Errors*/
SET SQL_SAFE_UPDATES = 0;
UPDATE carelytics
SET age = 109
WHERE patient_id = '475673a46188920d'
  AND source_year = 2017;

UPDATE carelytics
SET age = ABS(age)
WHERE age < 0;

/*------------------------------------------------------------Check Date Issues*/

SELECT
    COUNT(*) AS Total_Records,

    SUM(CASE
        WHEN discharge_date < visit_date THEN 1
        ELSE 0
    END) AS Discharge_Before_Visit,

    SUM(CASE
        WHEN discharge_date > CURDATE() THEN 1
        ELSE 0
    END) AS Future_Discharge_Dates,

    SUM(CASE
        WHEN visit_date > CURDATE() THEN 1
        ELSE 0
    END) AS Future_Visit_Dates,

    MIN(visit_date) AS First_Visit_Date,
    MAX(visit_date) AS Last_Visit_Date

FROM carelytics;

/*------------------------------------------------------------Inspect Incorrect Dates*/
SELECT
    patient_id,
    visit_date,
    discharge_date,
    DATEDIFF(discharge_date, visit_date) AS Length_of_Stay,
    source_year,
    source_month,
    source_sheet
FROM carelytics
WHERE discharge_date < visit_date
LIMIT 30;
/*------------------------------------------------------------check relation between g-drg and disgharge date*/

SELECT
    patient_id,
    visit_date,
    discharge_date,
    g_drg,
    diagnosis_text,
    source_year,
    source_month,
    source_sheet
FROM carelytics
WHERE g_drg IS NOT NULL
  AND g_drg <> ''
  AND (discharge_date IS NULL OR discharge_date = '')
LIMIT 30;
/*------------------------------------------------------------Fixing disgharge date with g-drg*/
SELECT
    g_drg,
    COUNT(*) AS Missing_Records
FROM carelytics
WHERE discharge_date IS NULL
GROUP BY g_drg
ORDER BY Missing_Records DESC
LIMIT 20;
  
 UPDATE carelytics
SET discharge_date = visit_date
WHERE TRIM(g_drg) = 'OPDC06C'
  AND discharge_date IS NULL;
  
/*------------------------------------------------------------fixing data type*/

SELECT
    COUNT(*) AS Total_Records,

    SUM(CASE
        WHEN STR_TO_DATE(visit_date, '%Y-%m-%d') IS NULL
             AND visit_date IS NOT NULL
             AND TRIM(visit_date) <> ''
        THEN 1 ELSE 0
    END) AS Invalid_Visit_Dates
FROM carelytics;

SELECT
    discharge_date,
    COUNT(*) AS Frequency
FROM carelytics
WHERE discharge_date IS NOT NULL
  AND TRIM(discharge_date) <> ''
  AND STR_TO_DATE(discharge_date, '%Y-%m-%d') IS NULL
GROUP BY discharge_date
ORDER BY Frequency DESC
LIMIT 30;
select
    SUM(CASE
        WHEN STR_TO_DATE(discharge_date, '%Y-%m-%d') IS NULL
             AND discharge_date IS NOT NULL
             AND TRIM(discharge_date) <> ''
        THEN 1 ELSE 0
    END) AS Invalid_Discharge_Dates
FROM carelytics;  



SELECT
    CASE
        WHEN discharge_date REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
            THEN 'YYYY-MM-DD'

        WHEN discharge_date REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$'
            THEN 'DD/MM/YYYY'

        WHEN discharge_date REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} '
            THEN 'YYYY-MM-DD HH:MM:SS'

        ELSE 'Other Format'
    END AS Date_Format,

    COUNT(*) AS Total_Records

FROM carelytics
WHERE discharge_date IS NOT NULL
  AND TRIM(discharge_date) <> ''
GROUP BY Date_Format;


UPDATE carelytics
SET discharge_date =
    CASE
        WHEN discharge_date REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$'
        THEN DATE_FORMAT(
            STR_TO_DATE(discharge_date, '%d/%m/%Y'),
            '%Y-%m-%d'
        )

        WHEN discharge_date REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} '
        THEN DATE_FORMAT(
            STR_TO_DATE(discharge_date, '%Y-%m-%d %H:%i:%s'),
            '%Y-%m-%d'
        )

        ELSE discharge_date
    END
WHERE discharge_date IS NOT NULL
  AND TRIM(discharge_date) <> '';
  
  
  SELECT
    CASE
        WHEN discharge_date REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
        THEN 'YYYY-MM-DD'
        ELSE 'Other Format'
    END AS Date_Format,
    COUNT(*) AS Total_Records
FROM carelytics
WHERE discharge_date IS NOT NULL
  AND TRIM(discharge_date) <> ''
GROUP BY Date_Format;


UPDATE carelytics
SET discharge_date = NULL
WHERE TRIM(discharge_date) = '';

SELECT
    COUNT(*) AS Total_Records,
    SUM(CASE WHEN discharge_date IS NULL THEN 1 ELSE 0 END) AS Missing_Discharge_Date,
    SUM(CASE WHEN discharge_date IS NOT NULL THEN 1 ELSE 0 END) AS Available_Discharge_Date
FROM carelytics;

ALTER TABLE carelytics
MODIFY COLUMN visit_date DATE,
MODIFY COLUMN discharge_date DATE;

/*------------------------------------------------------------discharge date before visit date*/

SELECT
    COUNT(*) AS Records_With_Both_Dates,

    SUM(
        CASE
            WHEN STR_TO_DATE(discharge_date, '%Y-%m-%d')
               < STR_TO_DATE(visit_date, '%Y-%m-%d')
            THEN 1 ELSE 0
        END
    ) AS Discharge_Before_Visit,

    SUM(
        CASE
            WHEN STR_TO_DATE(discharge_date, '%Y-%m-%d')
               = STR_TO_DATE(visit_date, '%Y-%m-%d')
            THEN 1 ELSE 0
        END
    ) AS Same_Day_Discharge

FROM carelytics
WHERE discharge_date IS NOT NULL
  AND TRIM(discharge_date) <> ''
  AND visit_date IS NOT NULL
  AND TRIM(visit_date) <> '';
  
  SELECT
    patient_id,
    visit_date,
    discharge_date,
    source_year,
    source_month,
    source_sheet,
    g_drg,
    diagnosis_text
FROM carelytics
WHERE STR_TO_DATE(discharge_date, '%Y-%m-%d')
    < STR_TO_DATE(visit_date, '%Y-%m-%d')
ORDER BY visit_date;

UPDATE carelytics
SET
    visit_date = @temp_date,
    discharge_date = @old_visit
WHERE 1 = 0;


/*------------------------------------------------------------Gender Standardization*/
SELECT
    gender,
    COUNT(*) AS Total_Records
FROM carelytics
GROUP BY gender
ORDER BY Total_Records DESC;

SELECT *
FROM carelytics
WHERE TRIM(gender) = '25';

UPDATE carelytics
SET gender = CASE
    WHEN UPPER(TRIM(gender)) IN ('F', 'FEMALE') THEN 'Female'
    WHEN UPPER(TRIM(gender)) IN ('M', 'MALE') THEN 'Male'
    WHEN TRIM(gender) = '25' THEN 'Unknown'
    ELSE 'Unknown'
END;

SELECT
    gender,
    COUNT(*) AS Total_Records
FROM carelytics
GROUP BY gender
ORDER BY Total_Records DESC;

/*------------------------------------------------------------Check Financial Columns*/

SELECT
    'drugs_amount' AS Column_Name,
    COUNT(*) AS Total_Records,
    SUM(drugs_amount IS NULL) AS Missing_Values,
    SUM(drugs_amount = 0) AS Zero_Values,
    SUM(drugs_amount < 0) AS Negative_Values,
    MIN(drugs_amount) AS Minimum_Value,
    MAX(drugs_amount) AS Maximum_Value,
    ROUND(AVG(drugs_amount), 2) AS Average_Value
FROM carelytics

UNION ALL

SELECT
    'investigation_amount',
    COUNT(*),
    SUM(investigation_amount IS NULL),
    SUM(investigation_amount = 0),
    SUM(investigation_amount < 0),
    MIN(investigation_amount),
    MAX(investigation_amount),
    ROUND(AVG(investigation_amount), 2)
FROM carelytics

UNION ALL

SELECT
    'outpatient_amount',
    COUNT(*),
    SUM(outpatient_amount IS NULL),
    SUM(outpatient_amount = 0),
    SUM(outpatient_amount < 0),
    MIN(outpatient_amount),
    MAX(outpatient_amount),
    ROUND(AVG(outpatient_amount), 2)
FROM carelytics

UNION ALL

SELECT
    'inpatient_amount',
    COUNT(*),
    SUM(inpatient_amount IS NULL),
    SUM(inpatient_amount = 0),
    SUM(inpatient_amount < 0),
    MIN(inpatient_amount),
    MAX(inpatient_amount),
    ROUND(AVG(inpatient_amount), 2)
FROM carelytics

UNION ALL

SELECT
    'service_amount',
    COUNT(*),
    SUM(service_amount IS NULL),
    SUM(service_amount = 0),
    SUM(service_amount < 0),
    MIN(service_amount),
    MAX(service_amount),
    ROUND(AVG(service_amount), 2)
FROM carelytics

UNION ALL

SELECT
    'total_claim',
    COUNT(*),
    SUM(total_claim IS NULL),
    SUM(total_claim = 0),
    SUM(total_claim < 0),
    MIN(total_claim),
    MAX(total_claim),
    ROUND(AVG(total_claim), 2)
FROM carelytics;

SELECT
    COUNT(*) AS Total_Records,

    SUM(
        CASE
            WHEN ABS(
                total_claim -
                (
                    drugs_amount +
                    investigation_amount +
                    outpatient_amount +
                    inpatient_amount +
                    service_amount
                )
            ) < 0.01
            THEN 1 ELSE 0
        END
    ) AS Matching_Records,

    SUM(
        CASE
            WHEN ABS(
                total_claim -
                (
                    drugs_amount +
                    investigation_amount +
                    outpatient_amount +
                    inpatient_amount +
                    service_amount
                )
            ) >= 0.01
            THEN 1 ELSE 0
        END
    ) AS Mismatching_Records
FROM carelytics;


SELECT
    patient_id,
    visit_date,
    drugs_amount,
    investigation_amount,
    outpatient_amount,
    inpatient_amount,
    service_amount,
    total_claim,
    (
        drugs_amount +
        investigation_amount +
        outpatient_amount +
        inpatient_amount +
        service_amount
    ) AS Components_Total,
    ROUND(
        total_claim -
        (
            drugs_amount +
            investigation_amount +
            outpatient_amount +
            inpatient_amount +
            service_amount
        ), 2
    ) AS Difference
FROM carelytics
WHERE ABS(
    total_claim -
    (
        drugs_amount +
        investigation_amount +
        outpatient_amount +
        inpatient_amount +
        service_amount
    )
) >= 0.01
ORDER BY ABS(
    total_claim -
    (
        drugs_amount +
        investigation_amount +
        outpatient_amount +
        inpatient_amount +
        service_amount
    )
) DESC
LIMIT 20;


SELECT
    patient_id,
    visit_date,
    source_year,
    source_month,
    source_sheet,
    g_drg,
    diagnosis_text,
    drugs_amount,
    outpatient_amount,
    inpatient_amount,
    service_amount,
    total_claim
FROM carelytics
WHERE visit_date = '2016-09-27'
ORDER BY total_claim DESC
LIMIT 20;

SELECT
    source_year,
    source_month,
    source_sheet,
    COUNT(*) AS Total_Records,
    ROUND(AVG(total_claim), 2) AS Avg_Total_Claim,
    ROUND(AVG(
        drugs_amount +
        investigation_amount +
        outpatient_amount +
        inpatient_amount +
        service_amount
    ), 2) AS Avg_Components,
    SUM(
        CASE
            WHEN ABS(
                total_claim -
                (
                    drugs_amount +
                    investigation_amount +
                    outpatient_amount +
                    inpatient_amount +
                    service_amount
                )
            ) >= 0.01
            THEN 1 ELSE 0
        END
    ) AS Mismatching_Records
FROM carelytics
GROUP BY source_year, source_month, source_sheet
ORDER BY source_year, source_month;

SELECT
    source_year,
    source_month,
    source_sheet,
    COUNT(*) AS Total_Records,
    SUM(CASE WHEN total_claim = 0 THEN 1 ELSE 0 END) AS Zero_Total_Claim,
    SUM(CASE WHEN total_claim > 0 THEN 1 ELSE 0 END) AS Positive_Total_Claim,
    ROUND(AVG(total_claim), 2) AS Avg_Total_Claim
FROM carelytics
GROUP BY source_year, source_month, source_sheet
HAVING Zero_Total_Claim > 0
ORDER BY source_year, source_month;

SELECT
    source_year,
    COUNT(*) AS Total_Records,

    SUM(CASE WHEN drugs_amount > 0 THEN 1 ELSE 0 END) AS Records_With_Drugs,
    SUM(CASE WHEN outpatient_amount > 0 THEN 1 ELSE 0 END) AS Records_With_Outpatient,
    SUM(CASE WHEN inpatient_amount > 0 THEN 1 ELSE 0 END) AS Records_With_Inpatient,
    SUM(CASE WHEN service_amount > 0 THEN 1 ELSE 0 END) AS Records_With_Service,

    ROUND(AVG(drugs_amount), 2) AS Avg_Drugs,
    ROUND(AVG(outpatient_amount), 2) AS Avg_Outpatient,
    ROUND(AVG(inpatient_amount), 2) AS Avg_Inpatient,
    ROUND(AVG(service_amount), 2) AS Avg_Service

FROM carelytics
WHERE source_sheet = 'ClaimData'
GROUP BY source_year
ORDER BY source_year;

SELECT
    CASE
        WHEN drugs_amount = 0 AND service_amount > 0
            THEN 'Service Only'

        WHEN drugs_amount > 0 AND service_amount > 0
            THEN 'Drugs + Service'

        WHEN drugs_amount > 0 AND service_amount = 0
            THEN 'Drugs Only'

        ELSE 'Both Zero'
    END AS Cost_Category,

    COUNT(*) AS Total_Records,

    ROUND(AVG(drugs_amount), 2) AS Avg_Drugs,
    ROUND(AVG(service_amount), 2) AS Avg_Service,
    ROUND(AVG(total_claim), 2) AS Avg_Total_Claim

FROM carelytics
WHERE source_sheet = 'ClaimData'
GROUP BY Cost_Category
ORDER BY Total_Records DESC;

/*------------------------------------------------------------Check Investigation Amount*/

SELECT
    source_year,
    source_sheet,
    COUNT(*) AS Total_Records,
    SUM(
        CASE
            WHEN investigation_amount > 0 THEN 1
            ELSE 0
        END
    ) AS Positive_Investigation,
    SUM(
        CASE
            WHEN investigation_amount = 0 THEN 1
            ELSE 0
        END
    ) AS Zero_Investigation,
    ROUND(AVG(investigation_amount), 2) AS Avg_Investigation
FROM carelytics
GROUP BY source_year, source_sheet
ORDER BY source_year, source_sheet;

-- investigation_amount:
-- Contains 100% zero values across all records (2015–2025)
-- No positive values were found in any source or year.
-- The column is retained in the raw dataset for data traceability
-- but excluded from financial analysis due to unavailable/unpopulated data.
-- Zero values do not necessarily mean that no investigations were performed.

/*------------------------------------------------------------Check Financial Outliers*/

SELECT
    'drugs_amount' AS Column_Name,
    COUNT(*) AS Outlier_Count,
    MIN(drugs_amount) AS Minimum_Outlier,
    MAX(drugs_amount) AS Maximum_Outlier
FROM carelytics
WHERE drugs_amount >
    (SELECT AVG(drugs_amount) + 3 * STDDEV(drugs_amount)
     FROM carelytics)

UNION ALL

SELECT
    'outpatient_amount',
    COUNT(*),
    MIN(outpatient_amount),
    MAX(outpatient_amount)
FROM carelytics
WHERE outpatient_amount >
    (SELECT AVG(outpatient_amount) + 3 * STDDEV(outpatient_amount)
     FROM carelytics)

UNION ALL

SELECT
    'inpatient_amount',
    COUNT(*),
    MIN(inpatient_amount),
    MAX(inpatient_amount)
FROM carelytics
WHERE inpatient_amount >
    (SELECT AVG(inpatient_amount) + 3 * STDDEV(inpatient_amount)
     FROM carelytics)

UNION ALL

SELECT
    'service_amount',
    COUNT(*),
    MIN(service_amount),
    MAX(service_amount)
FROM carelytics
WHERE service_amount >
    (SELECT AVG(service_amount) + 3 * STDDEV(service_amount)
     FROM carelytics);
/*------------------------------------------------------------Inspect Outliers*/

SELECT
    source_year,
    source_sheet,
    COUNT(*) AS Outlier_Count,
    ROUND(MIN(drugs_amount), 2) AS Min_Value,
    ROUND(MAX(drugs_amount), 2) AS Max_Value,
    ROUND(AVG(drugs_amount), 2) AS Avg_Value
FROM carelytics
WHERE drugs_amount > (
    SELECT AVG(drugs_amount) + 3 * STDDEV(drugs_amount)
    FROM carelytics
)
GROUP BY source_year, source_sheet
ORDER BY Outlier_Count DESC;

SELECT
    patient_id,
    source_year,
    source_month,
    source_sheet,
    visit_date,
    diagnosis_text,
    icd10,
    drugs_amount,
    service_amount,
    total_claim
FROM carelytics
WHERE drugs_amount > 50
ORDER BY drugs_amount DESC
LIMIT 20;

/*------------------------------------------------------------Check ICD-10 Data Quality*/

SELECT
    COUNT(*) AS Total_Records,

    SUM(
        CASE
            WHEN icd10 IS NULL OR TRIM(icd10) = ''
            THEN 1 ELSE 0
        END
    ) AS Missing_ICD10
    FROM carelytics;

    /*------------------------------------------------------------Inspect Unusual Characters*/

    SELECT
    patient_id,
    source_year,
    source_month,
    diagnosis_text,
    icd10
FROM carelytics
WHERE icd10 REGEXP '[^A-Za-z0-9., ]'
LIMIT 30;
select
    SUM(
        CASE
            WHEN icd10 LIKE '%,%'
            THEN 1 ELSE 0
        END
    ) AS Multiple_ICD10_Codes,

    SUM(
        CASE
            WHEN icd10 REGEXP '[^A-Za-z0-9., ]'
            THEN 1 ELSE 0
        END
    ) AS Unusual_Characters,

    SUM(
        CASE
            WHEN icd10 <> TRIM(icd10)
            THEN 1 ELSE 0
        END
    ) AS Leading_Trailing_Spaces

FROM carelytics;

SELECT
    icd10,
    diagnosis_text,
    COUNT(*) AS Frequency
FROM carelytics
WHERE icd10 REGEXP '[^A-Za-z0-9., ]'
   OR icd10 LIKE ',%'
GROUP BY icd10, diagnosis_text
ORDER BY Frequency DESC;

/*------------------------------------------------------------icd10,diagnosis_text Standardization*/
-- 1. Remove spaces around commas
UPDATE carelytics
SET icd10 = REPLACE(
    REPLACE(
        REPLACE(TRIM(icd10), ' ,', ','),
        ', ',
        ','
    ),
    ',,',
    ','
)
WHERE icd10 IS NOT NULL;

-- 2. Remove any remaining repeated commas
UPDATE carelytics
SET icd10 = REPLACE(icd10, ',,', ',')
WHERE icd10 LIKE '%,,%';

-- 3. Remove leading and trailing commas
UPDATE carelytics
SET icd10 = TRIM(BOTH ',' FROM icd10)
WHERE icd10 LIKE ',%'
   OR icd10 LIKE '%,';

-- 4. Verify
SELECT patient_id, diagnosis_text, icd10
FROM carelytics
WHERE icd10 REGEXP '(^,|,$|,,)'
ORDER BY source_year, source_month
LIMIT 100;


UPDATE carelytics
SET diagnosis_text =
    TRIM(BOTH ',' FROM
        REPLACE(
            REPLACE(
                REPLACE(
                    REPLACE(diagnosis_text, ',,,,,', ','),
                    ',,,,', ','
                ),
                ',,,', ','
            ),
            ',,', ','
        )
    )
WHERE diagnosis_text IS NOT NULL
  AND (
      diagnosis_text LIKE '%,,%'
      OR diagnosis_text LIKE '%,'
  );

-- Verify
SELECT
    patient_id,
    diagnosis_text,
    icd10
FROM carelytics
WHERE diagnosis_text LIKE '%,,%'
   OR diagnosis_text LIKE '%,'
LIMIT 100;


SELECT
    COUNT(*) AS Total_Records,

    SUM(CASE
        WHEN diagnosis_text IS NULL OR TRIM(diagnosis_text) = ''
        THEN 1 ELSE 0
    END) AS Missing_Diagnosis,

    SUM(CASE
        WHEN diagnosis_text <> TRIM(diagnosis_text)
        THEN 1 ELSE 0
    END) AS Extra_Spaces,

    SUM(CASE
        WHEN diagnosis_text LIKE '%  %'
        THEN 1 ELSE 0
    END) AS Multiple_Spaces,

    SUM(CASE
        WHEN diagnosis_text REGEXP '[0-9]'
        THEN 1 ELSE 0
    END) AS Contains_Numbers,

    SUM(CASE
        WHEN LOWER(TRIM(diagnosis_text)) IN ('unknown', 'unspecified', 'not specified')
        THEN 1 ELSE 0
    END) AS Unknown_Diagnosis

FROM carelytics;


SELECT
    diagnosis_text,
    COUNT(*) AS Records
FROM carelytics
WHERE diagnosis_text REGEXP '[0-9]'
GROUP BY diagnosis_text
ORDER BY Records DESC
LIMIT 100;

UPDATE carelytics
SET diagnosis_text = TRIM(BOTH ',' FROM TRIM(diagnosis_text))
WHERE diagnosis_text IS NOT NULL
  AND (
      TRIM(diagnosis_text) LIKE ',%'
      OR TRIM(diagnosis_text) LIKE '%,'
  );

-- Verify
SELECT
    patient_id,
    diagnosis_text
FROM carelytics
WHERE TRIM(diagnosis_text) LIKE ',%'
   OR TRIM(diagnosis_text) LIKE '%,'
LIMIT 100;
   /*------------------------------------------------------------check relation between icd10 and diagnosis_text*/
SELECT COUNT(*) AS Missing_ICD10
FROM carelytics
WHERE icd10 IS NULL
   OR TRIM(icd10) = '';
   
   CREATE TABLE diagnosis_icd10_mapping AS
SELECT
    TRIM(diagnosis_text) AS Diagnosis,
    MIN(TRIM(icd10)) AS ICD10_Code
FROM carelytics
WHERE icd10 IS NOT NULL
  AND TRIM(icd10) <> ''
  AND diagnosis_text IS NOT NULL
  AND TRIM(diagnosis_text) <> ''
GROUP BY TRIM(diagnosis_text)
HAVING COUNT(DISTINCT TRIM(icd10)) = 1;

ALTER TABLE diagnosis_icd10_mapping
ADD INDEX idx_diagnosis (Diagnosis(255));

SELECT
    COUNT(*) AS Total_Missing,
    SUM(CASE WHEN m.ICD10_Code IS NOT NULL THEN 1 ELSE 0 END) AS Matchable_Records
FROM carelytics c
LEFT JOIN diagnosis_icd10_mapping m
    ON TRIM(c.diagnosis_text) = m.Diagnosis
WHERE c.icd10 IS NULL
   OR TRIM(c.icd10) = '';
   
SET SQL_SAFE_UPDATES = 0;

UPDATE carelytics c
JOIN diagnosis_icd10_mapping m
    ON TRIM(c.diagnosis_text) = m.Diagnosis
SET c.icd10 = m.ICD10_Code
WHERE (c.icd10 IS NULL OR TRIM(c.icd10) = '');

SET SQL_SAFE_UPDATES = 1;

-- Verify
SELECT COUNT(*) AS Remaining_Missing_ICD10
FROM carelytics
WHERE icd10 IS NULL
   OR TRIM(icd10) = '';

   /*------------------------------------------------------------fillna diagnosis_text*/

SET SQL_SAFE_UPDATES = 0;

UPDATE carelytics
SET icd10 = 'N/A'
WHERE icd10 IS NULL
   OR TRIM(icd10) = '';

SET SQL_SAFE_UPDATES = 1;

-- Verify
SELECT COUNT(*) AS N_A_Records
FROM carelytics
WHERE icd10 = 'N/A';

   /*------------------------------------------------------------check icd10 Quality*/

SELECT
    COUNT(*) AS Total_Records,

    SUM(CASE
        WHEN icd10 IS NULL OR TRIM(icd10) = ''
        THEN 1 ELSE 0
    END) AS Missing_ICD10,

    SUM(CASE
        WHEN icd10 = 'N/A'
        THEN 1 ELSE 0
    END) AS NA_Records,

    SUM(CASE
        WHEN icd10 LIKE '%,,%'
        OR icd10 LIKE ',%'
        OR icd10 LIKE '%,'
        THEN 1 ELSE 0
    END) AS Formatting_Issues

FROM carelytics;

SELECT
    patient_id,
    source_year,
    source_month,
    diagnosis_text,
    icd10
FROM carelytics
WHERE icd10 LIKE '%,,%'
   OR icd10 LIKE ',%'
   OR icd10 LIKE '%,';
   
SET SQL_SAFE_UPDATES = 0;

UPDATE carelytics
SET icd10 = REPLACE(icd10, ',,', ',')
WHERE patient_id = '948cc7e2fde18a13'
  AND source_year = 2024
  AND source_month = 'February'
  AND icd10 = 'M79,,J18,K29';

SET SQL_SAFE_UPDATES = 1;


   /*------------------------------------------------------------check Data Quality*/

SELECT 'source_year' AS Column_Name,
       SUM(CASE WHEN source_year IS NULL OR TRIM(source_year) = '' THEN 1 ELSE 0 END) AS Missing_Values,
       ROUND(SUM(CASE WHEN source_year IS NULL OR TRIM(source_year) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Missing_Percentage
FROM carelytics

UNION ALL

SELECT 'source_month',
       SUM(CASE WHEN source_month IS NULL OR TRIM(source_month) = '' THEN 1 ELSE 0 END),
       ROUND(SUM(CASE WHEN source_month IS NULL OR TRIM(source_month) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
FROM carelytics

UNION ALL

SELECT 'source_sheet',
       SUM(CASE WHEN source_sheet IS NULL OR TRIM(source_sheet) = '' THEN 1 ELSE 0 END),
       ROUND(SUM(CASE WHEN source_sheet IS NULL OR TRIM(source_sheet) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
FROM carelytics

UNION ALL

SELECT 'load_order',
       SUM(CASE WHEN load_order IS NULL THEN 1 ELSE 0 END),
       ROUND(SUM(CASE WHEN load_order IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
FROM carelytics

UNION ALL

SELECT 'patient_id',
       SUM(CASE WHEN patient_id IS NULL OR TRIM(patient_id) = '' THEN 1 ELSE 0 END),
       ROUND(SUM(CASE WHEN patient_id IS NULL OR TRIM(patient_id) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
FROM carelytics

UNION ALL

SELECT 'visit_date',
       SUM(CASE WHEN visit_date IS NULL OR TRIM(visit_date) = '' THEN 1 ELSE 0 END),
       ROUND(SUM(CASE WHEN visit_date IS NULL OR TRIM(visit_date) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
FROM carelytics

UNION ALL

SELECT 'discharge_date',
       SUM(CASE WHEN discharge_date IS NULL OR TRIM(discharge_date) = '' THEN 1 ELSE 0 END),
       ROUND(SUM(CASE WHEN discharge_date IS NULL OR TRIM(discharge_date) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
FROM carelytics

UNION ALL

SELECT 'age',
       SUM(CASE WHEN age IS NULL THEN 1 ELSE 0 END),
       ROUND(SUM(CASE WHEN age IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
FROM carelytics

UNION ALL

SELECT 'gender',
       SUM(CASE WHEN gender IS NULL OR TRIM(gender) = '' THEN 1 ELSE 0 END),
       ROUND(SUM(CASE WHEN gender IS NULL OR TRIM(gender) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
FROM carelytics

UNION ALL

SELECT 'age_source',
       SUM(CASE WHEN age_source IS NULL OR TRIM(age_source) = '' THEN 1 ELSE 0 END),
       ROUND(SUM(CASE WHEN age_source IS NULL OR TRIM(age_source) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
FROM carelytics

UNION ALL

SELECT 'age_conflict',
       SUM(CASE WHEN age_conflict IS NULL THEN 1 ELSE 0 END),
       ROUND(SUM(CASE WHEN age_conflict IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
FROM carelytics

UNION ALL

SELECT 'diagnosis_text',
       SUM(CASE WHEN diagnosis_text IS NULL OR TRIM(diagnosis_text) = '' THEN 1 ELSE 0 END),
       ROUND(SUM(CASE WHEN diagnosis_text IS NULL OR TRIM(diagnosis_text) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
FROM carelytics

UNION ALL

SELECT 'icd10',
       SUM(CASE WHEN icd10 IS NULL OR TRIM(icd10) = '' THEN 1 ELSE 0 END),
       ROUND(SUM(CASE WHEN icd10 IS NULL OR TRIM(icd10) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
FROM carelytics

UNION ALL

SELECT 'g_drg',
       SUM(CASE WHEN g_drg IS NULL OR TRIM(g_drg) = '' THEN 1 ELSE 0 END),
       ROUND(SUM(CASE WHEN g_drg IS NULL OR TRIM(g_drg) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
FROM carelytics

UNION ALL

SELECT 'drugs_amount',
       SUM(CASE WHEN drugs_amount IS NULL THEN 1 ELSE 0 END),
       ROUND(SUM(CASE WHEN drugs_amount IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
FROM carelytics

UNION ALL

SELECT 'investigation_amount',
       SUM(CASE WHEN investigation_amount IS NULL THEN 1 ELSE 0 END),
       ROUND(SUM(CASE WHEN investigation_amount IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
FROM carelytics

UNION ALL

SELECT 'outpatient_amount',
       SUM(CASE WHEN outpatient_amount IS NULL THEN 1 ELSE 0 END),
       ROUND(SUM(CASE WHEN outpatient_amount IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
FROM carelytics

UNION ALL

SELECT 'inpatient_amount',
       SUM(CASE WHEN inpatient_amount IS NULL THEN 1 ELSE 0 END),
       ROUND(SUM(CASE WHEN inpatient_amount IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
FROM carelytics

UNION ALL

SELECT 'service_amount',
       SUM(CASE WHEN service_amount IS NULL THEN 1 ELSE 0 END),
       ROUND(SUM(CASE WHEN service_amount IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
FROM carelytics

UNION ALL

SELECT 'total_claim',
       SUM(CASE WHEN total_claim IS NULL THEN 1 ELSE 0 END),
       ROUND(SUM(CASE WHEN total_claim IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
FROM carelytics

UNION ALL

SELECT 'has_critical_missing',
       SUM(CASE WHEN has_critical_missing IS NULL THEN 1 ELSE 0 END),
       ROUND(SUM(CASE WHEN has_critical_missing IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
FROM carelytics

UNION ALL

SELECT 'age_at_visit',
       SUM(CASE WHEN age_at_visit IS NULL THEN 1 ELSE 0 END),
       ROUND(SUM(CASE WHEN age_at_visit IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
FROM carelytics

UNION ALL

SELECT 'icd10_codes',
       SUM(CASE WHEN icd10_codes IS NULL OR TRIM(icd10_codes) = '' THEN 1 ELSE 0 END),
       ROUND(SUM(CASE WHEN icd10_codes IS NULL OR TRIM(icd10_codes) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
FROM carelytics

UNION ALL

SELECT 'icd10_chapter',
       SUM(CASE WHEN icd10_chapter IS NULL OR TRIM(icd10_chapter) = '' THEN 1 ELSE 0 END),
       ROUND(SUM(CASE WHEN icd10_chapter IS NULL OR TRIM(icd10_chapter) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
FROM carelytics

UNION ALL

SELECT 'icd10_chapters',
       SUM(CASE WHEN icd10_chapters IS NULL OR TRIM(icd10_chapters) = '' THEN 1 ELSE 0 END),
       ROUND(SUM(CASE WHEN icd10_chapters IS NULL OR TRIM(icd10_chapters) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
FROM carelytics

UNION ALL

SELECT 'diagnosis_clean',
       SUM(CASE WHEN diagnosis_clean IS NULL OR TRIM(diagnosis_clean) = '' THEN 1 ELSE 0 END),
       ROUND(SUM(CASE WHEN diagnosis_clean IS NULL OR TRIM(diagnosis_clean) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
FROM carelytics

UNION ALL

SELECT 'disease_category',
       SUM(CASE WHEN disease_category IS NULL OR TRIM(disease_category) = '' THEN 1 ELSE 0 END),
       ROUND(SUM(CASE WHEN disease_category IS NULL OR TRIM(disease_category) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
FROM carelytics

UNION ALL

SELECT 'disease_categories_all',
       SUM(CASE WHEN disease_categories_all IS NULL OR TRIM(disease_categories_all) = '' THEN 1 ELSE 0 END),
       ROUND(SUM(CASE WHEN disease_categories_all IS NULL OR TRIM(disease_categories_all) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
FROM carelytics

UNION ALL

SELECT 'target_disease_fine',
       SUM(CASE WHEN target_disease_fine IS NULL OR TRIM(target_disease_fine) = '' THEN 1 ELSE 0 END),
       ROUND(SUM(CASE WHEN target_disease_fine IS NULL OR TRIM(target_disease_fine) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
FROM carelytics

UNION ALL

SELECT 'target_disease_coarse',
       SUM(CASE WHEN target_disease_coarse IS NULL OR TRIM(target_disease_coarse) = '' THEN 1 ELSE 0 END),
       ROUND(SUM(CASE WHEN target_disease_coarse IS NULL OR TRIM(target_disease_coarse) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
FROM carelytics

UNION ALL

SELECT 'total_visits',
       SUM(CASE WHEN total_visits IS NULL THEN 1 ELSE 0 END),
       ROUND(SUM(CASE WHEN total_visits IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
FROM carelytics

UNION ALL

SELECT 'visits_this_year',
       SUM(CASE WHEN visits_this_year IS NULL THEN 1 ELSE 0 END),
       ROUND(SUM(CASE WHEN visits_this_year IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
FROM carelytics

UNION ALL

SELECT 'visit_number',
       SUM(CASE WHEN visit_number IS NULL THEN 1 ELSE 0 END),
       ROUND(SUM(CASE WHEN visit_number IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
FROM carelytics

UNION ALL

SELECT 'days_since_last_visit',
       SUM(CASE WHEN days_since_last_visit IS NULL THEN 1 ELSE 0 END),
       ROUND(SUM(CASE WHEN days_since_last_visit IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
FROM carelytics

UNION ALL

SELECT 'days_to_next_visit',
       SUM(CASE WHEN days_to_next_visit IS NULL THEN 1 ELSE 0 END),
       ROUND(SUM(CASE WHEN days_to_next_visit IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
FROM carelytics

UNION ALL

SELECT 'revisit_30',
       SUM(CASE WHEN revisit_30 IS NULL THEN 1 ELSE 0 END),
       ROUND(SUM(CASE WHEN revisit_30 IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
FROM carelytics

UNION ALL

SELECT 'revisit_90',
       SUM(CASE WHEN revisit_90 IS NULL THEN 1 ELSE 0 END),
       ROUND(SUM(CASE WHEN revisit_90 IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
FROM carelytics

UNION ALL

SELECT 'revisit_180',
       SUM(CASE WHEN revisit_180 IS NULL THEN 1 ELSE 0 END),
       ROUND(SUM(CASE WHEN revisit_180 IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
FROM carelytics

ORDER BY Missing_Percentage DESC;


   /*------------------------------------------------------------fillna all missing values*/

SET SQL_SAFE_UPDATES = 0;

UPDATE carelytics
SET
    target_disease_fine = CASE
        WHEN target_disease_fine IS NULL OR TRIM(target_disease_fine) = ''
        THEN 'N/A' ELSE target_disease_fine
    END,

    g_drg = CASE
        WHEN g_drg IS NULL OR TRIM(g_drg) = ''
        THEN 'N/A' ELSE g_drg
    END,

    icd10_codes = CASE
        WHEN icd10_codes IS NULL OR TRIM(icd10_codes) = ''
        THEN 'N/A' ELSE icd10_codes
    END,

    disease_categories_all = CASE
        WHEN disease_categories_all IS NULL OR TRIM(disease_categories_all) = ''
        THEN 'N/A' ELSE disease_categories_all
    END,

    icd10_chapter = CASE
        WHEN icd10_chapter IS NULL OR TRIM(icd10_chapter) = ''
        THEN 'N/A' ELSE icd10_chapter
    END,

    diagnosis_clean = CASE
        WHEN diagnosis_clean IS NULL OR TRIM(diagnosis_clean) = ''
        THEN 'N/A' ELSE diagnosis_clean
    END,

    diagnosis_text = CASE
        WHEN diagnosis_text IS NULL OR TRIM(diagnosis_text) = ''
        THEN 'N/A' ELSE diagnosis_text
    END;

SET SQL_SAFE_UPDATES = 1;



   /*----------------------------------------------------------------------------------------Data Modeling*/
   
   /*----------------------------------------------------------------------------------------create PRIMARY KEY*/

ALTER TABLE carelytics
ADD COLUMN Visit_ID BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST;

   /*------------------------------------------------------------Create Dim_Date*/

CREATE TABLE Dim_Date (
    Date_ID INT PRIMARY KEY,
    Full_Date DATE NOT NULL UNIQUE,
    Year INT NOT NULL,
    Month_Number INT NOT NULL,
    Month_Name VARCHAR(20) NOT NULL,
    Quarter VARCHAR(2) NOT NULL
);

CREATE TEMPORARY TABLE Numbers (
    n INT PRIMARY KEY
);

INSERT INTO Numbers (n)
SELECT a.n + b.n * 10 + c.n * 100 + d.n * 1000
FROM
    (SELECT 0 AS n UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4
     UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) a
CROSS JOIN
    (SELECT 0 AS n UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4
     UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) b
CROSS JOIN
    (SELECT 0 AS n UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4
     UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) c
CROSS JOIN
    (SELECT 0 AS n UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4
     UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) d;
     
INSERT INTO Dim_Date
(Date_ID, Full_Date, Year, Month_Number, Month_Name, Quarter)

SELECT
    YEAR(DATE_ADD('2015-01-01', INTERVAL n DAY)) * 10000
      + MONTH(DATE_ADD('2015-01-01', INTERVAL n DAY)) * 100
      + DAY(DATE_ADD('2015-01-01', INTERVAL n DAY)),
    DATE_ADD('2015-01-01', INTERVAL n DAY),
    YEAR(DATE_ADD('2015-01-01', INTERVAL n DAY)),
    MONTH(DATE_ADD('2015-01-01', INTERVAL n DAY)),
    MONTHNAME(DATE_ADD('2015-01-01', INTERVAL n DAY)),
    CONCAT('Q', QUARTER(DATE_ADD('2015-01-01', INTERVAL n DAY)))

FROM Numbers
WHERE n <= DATEDIFF('2025-12-31', '2015-01-01')
ORDER BY n;

SELECT
    MIN(Full_Date) AS First_Date,
    MAX(Full_Date) AS Last_Date,
    COUNT(*) AS Total_Dates
FROM Dim_Date;

   /*------------------------------------------------------------Create Dim_Patient
   One row per patient. Age and Gender are patient-level attributes.
   Age is selected from the latest valid patient record; Gender is selected
   from the latest non-empty record and standardized.
*/
CREATE TABLE Dim_Patient (
    Patient_Key INT AUTO_INCREMENT PRIMARY KEY,
    Patient_ID VARCHAR(50) NOT NULL UNIQUE,
    Age INT NULL,
    Gender VARCHAR(20) NOT NULL DEFAULT 'Unknown'
);

INSERT INTO Dim_Patient (Patient_ID, Age, Gender)
SELECT
    p.patient_id,
    (
        SELECT CAST(NULLIF(TRIM(c2.age), '') AS UNSIGNED)
        FROM carelytics c2
        WHERE c2.patient_id = p.patient_id
          AND c2.age REGEXP '^[0-9]+$'
          AND CAST(c2.age AS UNSIGNED) BETWEEN 0 AND 120
        ORDER BY c2.visit_date DESC, c2.Visit_ID DESC
        LIMIT 1
    ) AS Age,
    COALESCE(
        (
            SELECT CASE
                WHEN UPPER(TRIM(c3.gender)) IN ('F', 'FEMALE') THEN 'Female'
                WHEN UPPER(TRIM(c3.gender)) IN ('M', 'MALE') THEN 'Male'
                ELSE 'Unknown'
            END
            FROM carelytics c3
            WHERE c3.patient_id = p.patient_id
              AND c3.gender IS NOT NULL
              AND TRIM(c3.gender) <> ''
            ORDER BY c3.visit_date DESC, c3.Visit_ID DESC
            LIMIT 1
        ),
        'Unknown'
    ) AS Gender
FROM (
    SELECT DISTINCT patient_id
    FROM carelytics
    WHERE patient_id IS NOT NULL
      AND TRIM(patient_id) <> ''
) p;

SELECT COUNT(*) AS Total_Patients
FROM Dim_Patient;
   /*------------------------------------------------------------Create Dim_Diagnosis*/

CREATE TABLE Dim_Diagnosis (
    Diagnosis_Key INT AUTO_INCREMENT PRIMARY KEY,
    Diagnosis_Text VARCHAR(500) NOT NULL UNIQUE
);

INSERT INTO Dim_Diagnosis (Diagnosis_Text)
SELECT DISTINCT TRIM(diagnosis_text)
FROM carelytics
WHERE diagnosis_text IS NOT NULL
  AND TRIM(diagnosis_text) <> '';
  
  ALTER TABLE dim_diagnosis
ADD COLUMN Diagnosis_Clean VARCHAR(500) NULL,
ADD COLUMN Disease_Category VARCHAR(255) NULL,
ADD COLUMN Target_Disease_Fine VARCHAR(255) NULL,
ADD COLUMN Target_Disease_Coarse VARCHAR(255) NULL;

UPDATE dim_diagnosis d
JOIN (
    SELECT
        TRIM(diagnosis_text) AS Diagnosis_Text,
        MIN(diagnosis_clean) AS Diagnosis_Clean,
        MIN(disease_category) AS Disease_Category,
        MIN(target_disease_fine) AS Target_Disease_Fine,
        MIN(target_disease_coarse) AS Target_Disease_Coarse
    FROM carelytics
    WHERE diagnosis_text IS NOT NULL
      AND TRIM(diagnosis_text) <> ''
    GROUP BY TRIM(diagnosis_text)
    HAVING
        COUNT(DISTINCT COALESCE(diagnosis_clean, '<NULL>')) = 1
        AND COUNT(DISTINCT COALESCE(disease_category, '<NULL>')) = 1
        AND COUNT(DISTINCT COALESCE(target_disease_fine, '<NULL>')) = 1
        AND COUNT(DISTINCT COALESCE(target_disease_coarse, '<NULL>')) = 1
) c
    ON d.Diagnosis_Text = c.Diagnosis_Text
SET
    d.Diagnosis_Clean = c.Diagnosis_Clean,
    d.Disease_Category = c.Disease_Category,
    d.Target_Disease_Fine = c.Target_Disease_Fine,
    d.Target_Disease_Coarse = c.Target_Disease_Coarse;
     /*------------------------------------------------------------Create Dim_ICD10*/

CREATE TABLE Dim_ICD10 (
    ICD10_Key INT AUTO_INCREMENT PRIMARY KEY,
    ICD10_Code VARCHAR(100) NOT NULL UNIQUE
);

INSERT INTO Dim_ICD10 (ICD10_Code)
SELECT DISTINCT TRIM(icd10)
FROM carelytics
WHERE icd10 IS NOT NULL
  AND TRIM(icd10) <> '';
  
  ALTER TABLE Dim_ICD10
ADD COLUMN ICD10_Chapter VARCHAR(100) NULL;
UPDATE Dim_ICD10
SET ICD10_Chapter =
    CASE
        WHEN LEFT(UPPER(TRIM(ICD10_Code)), 3) BETWEEN 'A00' AND 'B99'
            THEN 'I - Certain Infectious and Parasitic Diseases'

        WHEN LEFT(UPPER(TRIM(ICD10_Code)), 3) BETWEEN 'C00' AND 'D49'
            THEN 'II - Neoplasms'

        WHEN LEFT(UPPER(TRIM(ICD10_Code)), 3) BETWEEN 'D50' AND 'D89'
            THEN 'III - Diseases of the Blood'

        WHEN LEFT(UPPER(TRIM(ICD10_Code)), 3) BETWEEN 'E00' AND 'E90'
            THEN 'IV - Endocrine, Nutritional and Metabolic Diseases'

        WHEN LEFT(UPPER(TRIM(ICD10_Code)), 3) BETWEEN 'F00' AND 'F99'
            THEN 'V - Mental and Behavioural Disorders'

        WHEN LEFT(UPPER(TRIM(ICD10_Code)), 3) BETWEEN 'G00' AND 'G99'
            THEN 'VI - Diseases of the Nervous System'

        WHEN LEFT(UPPER(TRIM(ICD10_Code)), 3) BETWEEN 'H00' AND 'H59'
            THEN 'VII - Diseases of the Eye'

        WHEN LEFT(UPPER(TRIM(ICD10_Code)), 3) BETWEEN 'H60' AND 'H95'
            THEN 'VIII - Diseases of the Ear'

        WHEN LEFT(UPPER(TRIM(ICD10_Code)), 3) BETWEEN 'I00' AND 'I99'
            THEN 'IX - Diseases of the Circulatory System'

        WHEN LEFT(UPPER(TRIM(ICD10_Code)), 3) BETWEEN 'J00' AND 'J99'
            THEN 'X - Diseases of the Respiratory System'

        WHEN LEFT(UPPER(TRIM(ICD10_Code)), 3) BETWEEN 'K00' AND 'K95'
            THEN 'XI - Diseases of the Digestive System'

        WHEN LEFT(UPPER(TRIM(ICD10_Code)), 3) BETWEEN 'L00' AND 'L99'
            THEN 'XII - Diseases of the Skin'

        WHEN LEFT(UPPER(TRIM(ICD10_Code)), 3) BETWEEN 'M00' AND 'M99'
            THEN 'XIII - Diseases of the Musculoskeletal System'

        WHEN LEFT(UPPER(TRIM(ICD10_Code)), 3) BETWEEN 'N00' AND 'N99'
            THEN 'XIV - Diseases of the Genitourinary System'

        WHEN LEFT(UPPER(TRIM(ICD10_Code)), 3) BETWEEN 'O00' AND 'O9A'
            THEN 'XV - Pregnancy, Childbirth and Puerperium'

        WHEN LEFT(UPPER(TRIM(ICD10_Code)), 3) BETWEEN 'P00' AND 'P96'
            THEN 'XVI - Certain Conditions Originating in the Perinatal Period'

        WHEN LEFT(UPPER(TRIM(ICD10_Code)), 3) BETWEEN 'Q00' AND 'Q99'
            THEN 'XVII - Congenital Malformations'

        WHEN LEFT(UPPER(TRIM(ICD10_Code)), 3) BETWEEN 'R00' AND 'R99'
            THEN 'XVIII - Symptoms and Abnormal Findings'

        WHEN LEFT(UPPER(TRIM(ICD10_Code)), 3) BETWEEN 'S00' AND 'T98'
            THEN 'XIX - Injury and Poisoning'

        WHEN LEFT(UPPER(TRIM(ICD10_Code)), 3) BETWEEN 'V01' AND 'Y98'
            THEN 'XX - External Causes of Morbidity'

        WHEN LEFT(UPPER(TRIM(ICD10_Code)), 3) BETWEEN 'Z00' AND 'Z99'
            THEN 'XXI - Factors Influencing Health Status'

        WHEN LEFT(UPPER(TRIM(ICD10_Code)), 3) BETWEEN 'U00' AND 'U99'
            THEN 'XXII - Codes for Special Purposes'

        ELSE 'Unknown'
    END
    WHERE ICD10_Key > 0;
  
       /*------------------------------------------------------------Create Bridge_Diagnosis_ICD10*/

CREATE TABLE Bridge_Diagnosis_ICD10 (
    Diagnosis_Key INT NOT NULL,
    ICD10_Key INT NOT NULL,

    PRIMARY KEY (Diagnosis_Key, ICD10_Key),

    FOREIGN KEY (Diagnosis_Key)
        REFERENCES Dim_Diagnosis(Diagnosis_Key),

    FOREIGN KEY (ICD10_Key)
        REFERENCES Dim_ICD10(ICD10_Key)
);

INSERT IGNORE INTO Bridge_Diagnosis_ICD10
    (Diagnosis_Key, ICD10_Key)

SELECT DISTINCT
    d.Diagnosis_Key,
    i.ICD10_Key

FROM carelytics c

JOIN Dim_Diagnosis d
    ON d.Diagnosis_Text = TRIM(c.diagnosis_text)

JOIN Dim_ICD10 i
    ON i.ICD10_Code = TRIM(c.icd10)

WHERE c.diagnosis_text IS NOT NULL
  AND c.icd10 IS NOT NULL
  AND TRIM(c.diagnosis_text) <> ''
  AND TRIM(c.icd10) <> '';
  
SELECT COUNT(*) AS Total_Relationships
FROM Bridge_Diagnosis_ICD10;


       /*------------------------------------------------------------Create Dim_Source*/

SELECT
    COUNT(*) AS Unique_Source_Combinations
FROM (
    SELECT DISTINCT
        source_year,
        source_month,
        source_sheet
    FROM carelytics
) AS Sources;

CREATE TABLE Dim_Source (
    Source_Key INT AUTO_INCREMENT PRIMARY KEY,
    Source_Year INT,
    Source_Month VARCHAR(20),
    Source_Sheet VARCHAR(100),

    UNIQUE (Source_Year, Source_Month, Source_Sheet)
);

INSERT INTO Dim_Source (
    Source_Year,
    Source_Month,
    Source_Sheet
)
SELECT DISTINCT
    source_year,
    source_month,
    source_sheet
FROM carelytics;

SELECT COUNT(*) AS Total_Sources
FROM Dim_Source;

       /*------------------------------------------------------------Create Fact_Visits*/
CREATE TABLE Fact_Visits (
    Visit_ID BIGINT PRIMARY KEY,

    Patient_Key INT NOT NULL,
    Visit_Date_ID INT,
    Discharge_Date_ID INT,
    Source_Key INT,

    G_DRG VARCHAR(100),

    Drugs_Amount DOUBLE,
    Outpatient_Amount DOUBLE,
    Inpatient_Amount DOUBLE,
    Service_Amount DOUBLE,
    Total_Claim DOUBLE,

    Total_Visits DOUBLE,
    Visits_This_Year DOUBLE,
    Visit_Number INT,

    Revisit_30 VARCHAR(10),
    Revisit_90 VARCHAR(10),
    Revisit_180 VARCHAR(10),

    FOREIGN KEY (Patient_Key)
        REFERENCES Dim_Patient(Patient_Key),

    FOREIGN KEY (Visit_Date_ID)
        REFERENCES Dim_Date(Date_ID),

    FOREIGN KEY (Discharge_Date_ID)
        REFERENCES Dim_Date(Date_ID),

    FOREIGN KEY (Source_Key)
        REFERENCES Dim_Source(Source_Key)
);

SELECT
    COUNT(*) AS Total_Records,

    SUM(CASE WHEN p.Patient_Key IS NULL THEN 1 ELSE 0 END)
        AS Missing_Patient,

    SUM(CASE
        WHEN c.visit_date IS NOT NULL
        AND vd.Date_ID IS NULL
        THEN 1 ELSE 0
    END) AS Missing_Visit_Date,

    SUM(CASE
        WHEN c.discharge_date IS NOT NULL
        AND dd.Date_ID IS NULL
        THEN 1 ELSE 0
    END) AS Missing_Discharge_Date,

    SUM(CASE WHEN s.Source_Key IS NULL THEN 1 ELSE 0 END)
        AS Missing_Source

FROM carelytics c

LEFT JOIN Dim_Patient p
    ON p.Patient_ID = c.patient_id

LEFT JOIN Dim_Date vd
    ON vd.Date_ID = CAST(DATE_FORMAT(c.visit_date, '%Y%m%d') AS UNSIGNED)

LEFT JOIN Dim_Date dd
    ON dd.Date_ID = CAST(DATE_FORMAT(c.discharge_date, '%Y%m%d') AS UNSIGNED)

LEFT JOIN Dim_Source s
    ON s.Source_Year = c.source_year
    AND s.Source_Month = c.source_month
    AND s.Source_Sheet = c.source_sheet;
    
INSERT INTO Fact_Visits (
    Visit_ID,
    Patient_Key,
    Visit_Date_ID,
    Discharge_Date_ID,
    Source_Key,
    G_DRG,
    Drugs_Amount,
    Outpatient_Amount,
    Inpatient_Amount,
    Service_Amount,
    Total_Claim,
    Total_Visits,
    Visits_This_Year,
    Visit_Number,
    Revisit_30,
    Revisit_90,
    Revisit_180
)

SELECT
    c.Visit_ID,
    p.Patient_Key,
    vd.Date_ID,
    dd.Date_ID,
    s.Source_Key,
    c.g_drg,
    c.drugs_amount,
    c.outpatient_amount,
    c.inpatient_amount,
    c.service_amount,
    c.total_claim,
    c.total_visits,
    c.visits_this_year,
    c.visit_number,
    c.revisit_30,
    c.revisit_90,
    c.revisit_180

FROM carelytics c

JOIN Dim_Patient p
    ON p.Patient_ID = c.patient_id

LEFT JOIN Dim_Date vd
    ON vd.Date_ID = CAST(DATE_FORMAT(c.visit_date, '%Y%m%d') AS UNSIGNED)

LEFT JOIN Dim_Date dd
    ON dd.Date_ID = CAST(DATE_FORMAT(c.discharge_date, '%Y%m%d') AS UNSIGNED)

JOIN Dim_Source s
    ON s.Source_Year = c.source_year
    AND s.Source_Month = c.source_month
    AND s.Source_Sheet = c.source_sheet;
    
    SELECT
    COUNT(*) AS Total_Fact_Records,
    COUNT(DISTINCT Visit_ID) AS Unique_Visits
FROM Fact_Visits;

SELECT
    COUNT(*) AS Total_Records,

    SUM(CASE WHEN p.Patient_Key IS NULL THEN 1 ELSE 0 END)
        AS Missing_Patient,

    SUM(CASE WHEN vd.Date_ID IS NULL THEN 1 ELSE 0 END)
        AS Missing_Visit_Date,

    SUM(CASE
        WHEN f.Discharge_Date_ID IS NOT NULL
        AND dd.Date_ID IS NULL
        THEN 1 ELSE 0
    END) AS Missing_Discharge_Date,

    SUM(CASE WHEN s.Source_Key IS NULL THEN 1 ELSE 0 END)
        AS Missing_Source

FROM Fact_Visits f

LEFT JOIN Dim_Patient p
    ON p.Patient_Key = f.Patient_Key

LEFT JOIN Dim_Date vd
    ON vd.Date_ID = f.Visit_Date_ID

LEFT JOIN Dim_Date dd
    ON dd.Date_ID = f.Discharge_Date_ID

LEFT JOIN Dim_Source s
    ON s.Source_Key = f.Source_Key;
    
ALTER TABLE fact_visits
ADD COLUMN Age_at_Visit DOUBLE NULL,
ADD COLUMN Has_Critical_Missing VARCHAR(10) NULL,
ADD COLUMN Age_Source VARCHAR(100) NULL,
ADD COLUMN Age_Conflict VARCHAR(20) NULL;

UPDATE fact_visits f
JOIN carelytics c
    ON f.Visit_ID = c.Visit_ID
SET
    f.Age_at_Visit = c.age_at_visit,
    f.Has_Critical_Missing = c.has_critical_missing,
    f.Age_Source = c.age_source,
    f.Age_Conflict = c.age_conflict;
/*------------------------------------------------------------Create Bridge_Visit_Diagnosis*/

CREATE TABLE Bridge_Visit_Diagnosis (
    Visit_ID BIGINT NOT NULL,
    Diagnosis_Key INT NOT NULL,

    PRIMARY KEY (Visit_ID, Diagnosis_Key),

    FOREIGN KEY (Visit_ID)
        REFERENCES Fact_Visits(Visit_ID),

    FOREIGN KEY (Diagnosis_Key)
        REFERENCES Dim_Diagnosis(Diagnosis_Key)
);

INSERT IGNORE INTO Bridge_Visit_Diagnosis (
    Visit_ID,
    Diagnosis_Key
)
SELECT DISTINCT
    c.Visit_ID,
    d.Diagnosis_Key
FROM carelytics c
JOIN Dim_Diagnosis d
    ON d.Diagnosis_Text = TRIM(c.diagnosis_text)
WHERE c.diagnosis_text IS NOT NULL
  AND TRIM(c.diagnosis_text) <> '';
  
  
             /*------------------------------------------------------------Create Bridge_Visit_ICD10*/

CREATE TABLE Bridge_Visit_ICD10 (
    Visit_ID BIGINT NOT NULL,
    ICD10_Key INT NOT NULL,

    PRIMARY KEY (Visit_ID, ICD10_Key),

    FOREIGN KEY (Visit_ID)
        REFERENCES Fact_Visits(Visit_ID),

    FOREIGN KEY (ICD10_Key)
        REFERENCES Dim_ICD10(ICD10_Key)
);

INSERT IGNORE INTO Bridge_Visit_ICD10 (
    Visit_ID,
    ICD10_Key
)
SELECT DISTINCT
    c.Visit_ID,
    i.ICD10_Key
FROM carelytics c
JOIN Dim_ICD10 i
    ON i.ICD10_Code = TRIM(c.icd10)
WHERE c.icd10 IS NOT NULL
  AND TRIM(c.icd10) <> '';
-- Raw source table retained: later QA/report queries still use carelytics.
-- carelytics_backup is not dropped by this script.

ALTER TABLE carelytics
ADD COLUMN Visit_ID BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST;
             /*------------------------------------------------------------Create Relationships*/

SELECT
    COUNT(*) AS Total_Relationships,
    SUM(CASE WHEN f.Visit_ID IS NULL THEN 1 ELSE 0 END) AS Missing_Visit,
    SUM(CASE WHEN i.ICD10_Key IS NULL THEN 1 ELSE 0 END) AS Missing_ICD10
FROM Bridge_Visit_ICD10 b
LEFT JOIN Fact_Visits f
    ON f.Visit_ID = b.Visit_ID
LEFT JOIN Dim_ICD10 i
    ON i.ICD10_Key = b.ICD10_Key;
           /*------------------------------------------------------------KPI 1 — Patient & Visit Overview*/

SELECT
    COUNT(DISTINCT Patient_Key) AS Total_Patients,
    COUNT(Visit_ID) AS Total_Visit_Records,
    ROUND(
        COUNT(Visit_ID) / COUNT(DISTINCT Patient_Key),
        2
    ) AS Avg_Records_Per_Patient
FROM Fact_Visits;

           /*------------------------------------------------------------KPI2-Patient Readmission Rates*/
SELECT
    COUNT(*) AS Total_Records,

    SUM(CASE
        WHEN LOWER(TRIM(Revisit_30)) IN ('1', 'yes', 'true')
        THEN 1 ELSE 0
    END) AS Revisit_30_Count,

    ROUND(
        100.0 * SUM(CASE
            WHEN LOWER(TRIM(Revisit_30)) IN ('1', 'yes', 'true')
            THEN 1 ELSE 0
        END) / COUNT(*), 2
    ) AS Revisit_30_Rate,

    SUM(CASE
        WHEN LOWER(TRIM(Revisit_90)) IN ('1', 'yes', 'true')
        THEN 1 ELSE 0
    END) AS Revisit_90_Count,

    ROUND(
        100.0 * SUM(CASE
            WHEN LOWER(TRIM(Revisit_90)) IN ('1', 'yes', 'true')
            THEN 1 ELSE 0
        END) / COUNT(*), 2
    ) AS Revisit_90_Rate,

    SUM(CASE
        WHEN LOWER(TRIM(Revisit_180)) IN ('1', 'yes', 'true')
        THEN 1 ELSE 0
    END) AS Revisit_180_Count,

    ROUND(
        100.0 * SUM(CASE
            WHEN LOWER(TRIM(Revisit_180)) IN ('1', 'yes', 'true')
            THEN 1 ELSE 0
        END) / COUNT(*), 2
    ) AS Revisit_180_Rate

FROM Fact_Visits;

           /*------------------------------------------------------------KPI 3 — Average Length of Stay (ALOS)*/

SELECT
    COUNT(*) AS Total_Valid_Records,

    ROUND(
        AVG(DATEDIFF(
            dd.Full_Date,
            vd.Full_Date
        )), 2
    ) AS Average_Length_Of_Stay,

    MIN(DATEDIFF(
        dd.Full_Date,
        vd.Full_Date
    )) AS Minimum_Stay_Days,

    MAX(DATEDIFF(
        dd.Full_Date,
        vd.Full_Date
    )) AS Maximum_Stay_Days

FROM Fact_Visits f

JOIN Dim_Date vd
    ON f.Visit_Date_ID = vd.Date_ID

JOIN Dim_Date dd
    ON f.Discharge_Date_ID = dd.Date_ID

WHERE dd.Full_Date >= vd.Full_Date;


           /*------------------------------------------------------------KPI 4 — Patient Demographics*/
SELECT
    p.Gender,
    COUNT(DISTINCT f.Patient_Key) AS Total_Patients,
    ROUND(
        100.0 * COUNT(DISTINCT f.Patient_Key) /
        (SELECT COUNT(DISTINCT Patient_Key) FROM Fact_Visits),
        2
    ) AS Patient_Percentage
FROM Fact_Visits f
JOIN Dim_Patient p ON p.Patient_Key = f.Patient_Key
GROUP BY p.Gender
ORDER BY Total_Patients DESC;

           /*------------------------------------------------------------Age Distribution*/
SELECT
    CASE
        WHEN Age < 18 THEN 'Under 18'
        WHEN Age BETWEEN 18 AND 30 THEN '18-30'
        WHEN Age BETWEEN 31 AND 45 THEN '31-45'
        WHEN Age BETWEEN 46 AND 60 THEN '46-60'
        WHEN Age BETWEEN 61 AND 75 THEN '61-75'
        ELSE 'Above 75'
    END AS Age_Group,
    COUNT(*) AS Total_Patients
FROM Dim_Patient
WHERE Age IS NOT NULL
GROUP BY Age_Group
ORDER BY FIELD(Age_Group, 'Under 18', '18-30', '31-45', '46-60', '61-75', 'Above 75');

           /*------------------------------------------------------------Top Diagnoses*/

SELECT
    d.Diagnosis_Text,
    COUNT(*) AS Diagnosis_Records
FROM Bridge_Visit_Diagnosis b
JOIN Dim_Diagnosis d
    ON b.Diagnosis_Key = d.Diagnosis_Key
GROUP BY d.Diagnosis_Text
ORDER BY Diagnosis_Records DESC
LIMIT 10;

           /*------------------------------------------------------------Disease Category Distribution*/
SELECT
    disease_category,
    COUNT(*) AS Total_Records
FROM carelytics
GROUP BY disease_category
ORDER BY Total_Records DESC;

           /*------------------------------------------------------------Cost Analysis*/
           /*------------------------------------------------------------KPI 1 – Overall Healthcare Cost*/
SELECT
    COUNT(*) AS Total_Records,
    ROUND(SUM(Total_Claim), 2) AS Total_Healthcare_Cost,
    ROUND(AVG(Total_Claim), 2) AS Average_Cost_Per_Record,
    ROUND(MIN(Total_Claim), 2) AS Minimum_Cost,
    ROUND(MAX(Total_Claim), 2) AS Maximum_Cost
FROM Fact_Visits;
           /*------------------------------------------------------------KPI 2 – Cost Components Analysis*/

SELECT
    ROUND(SUM(Drugs_Amount), 2) AS Total_Drugs_Cost,
    ROUND(SUM(Outpatient_Amount), 2) AS Total_Outpatient_Cost,
    ROUND(SUM(Inpatient_Amount), 2) AS Total_Inpatient_Cost,
    ROUND(SUM(Service_Amount), 2) AS Total_Service_Cost
FROM Fact_Visits;

           /*------------------------------------------------------------KPI 3 – Cost by Age Group*/
SELECT
    CASE
        WHEN p.Age < 18 THEN 'Under 18'
        WHEN p.Age BETWEEN 18 AND 30 THEN '18-30'
        WHEN p.Age BETWEEN 31 AND 45 THEN '31-45'
        WHEN p.Age BETWEEN 46 AND 60 THEN '46-60'
        WHEN p.Age BETWEEN 61 AND 75 THEN '61-75'
        WHEN p.Age BETWEEN 76 AND 100 THEN '76-100'
        WHEN p.Age > 100 THEN 'Above 100 - Review'
        ELSE 'Unknown'
    END AS Age_Group,
    COUNT(*) AS Total_Records,
    ROUND(SUM(f.Total_Claim), 2) AS Total_Cost,
    ROUND(AVG(f.Total_Claim), 2) AS Average_Cost
FROM Fact_Visits f
JOIN Dim_Patient p ON p.Patient_Key = f.Patient_Key
GROUP BY Age_Group
ORDER BY MIN(p.Age);

           /*------------------------------------------------------------Cost by Gender*/
SELECT
    p.Gender,
    COUNT(*) AS Total_Records,
    ROUND(SUM(f.Total_Claim), 2) AS Total_Cost,
    ROUND(AVG(f.Total_Claim), 2) AS Average_Cost
FROM Fact_Visits f
JOIN Dim_Patient p ON p.Patient_Key = f.Patient_Key
GROUP BY p.Gender
ORDER BY Total_Cost DESC;

           /*------------------------------------------------------------Cost by Disease Category*/
SELECT
    d.Disease_Category,
    COUNT(DISTINCT f.Visit_ID) AS Total_Visits,
    ROUND(SUM(f.Total_Claim), 2) AS Total_Cost,
    ROUND(
        SUM(f.Total_Claim) / COUNT(DISTINCT f.Visit_ID), 2
    ) AS Average_Cost_Per_Visit
FROM Fact_Visits f
JOIN Bridge_Visit_Diagnosis b
    ON f.Visit_ID = b.Visit_ID
JOIN Dim_Diagnosis d
    ON b.Diagnosis_Key = d.Diagnosis_Key
WHERE d.Disease_Category IS NOT NULL
GROUP BY d.Disease_Category
ORDER BY Total_Cost DESC;
           /*------------------------------------------------------------KPI 5 — Top 10 Diagnoses by Cost*/
SELECT
    d.Diagnosis_Text,
    COUNT(*) AS Total_Records,
    ROUND(SUM(f.Total_Claim), 2) AS Total_Cost,
    ROUND(AVG(f.Total_Claim), 2) AS Average_Cost
FROM Fact_Visits f
JOIN Bridge_Visit_Diagnosis b
    ON f.Visit_ID = b.Visit_ID
JOIN Dim_Diagnosis d
    ON b.Diagnosis_Key = d.Diagnosis_Key
GROUP BY d.Diagnosis_Text
ORDER BY Total_Cost DESC
LIMIT 10;



/*---------------------------------Phase 7: Disease Analysis*/

/*--7.1 Disease Category Overview*/
SELECT
    Disease_Category,
    COUNT(*) AS Total_Visits,
    COUNT(DISTINCT Patient_Key) AS Unique_Patients,
    ROUND(
        100.0 * COUNT(*) /
        (SELECT COUNT(*) FROM Fact_Visits),
        2
    ) AS Visit_Percentage,
    ROUND(SUM(Total_Claim), 2) AS Total_Cost,
    ROUND(AVG(Total_Claim), 2) AS Avg_Cost_Per_Visit
FROM (
    SELECT DISTINCT
        f.Visit_ID,
        f.Patient_Key,
        f.Total_Claim,
        COALESCE(NULLIF(TRIM(d.Disease_Category), ''), 'Unknown')
            AS Disease_Category
    FROM Fact_Visits f
    LEFT JOIN Bridge_Visit_Diagnosis b
        ON f.Visit_ID = b.Visit_ID
    LEFT JOIN Dim_Diagnosis d
        ON b.Diagnosis_Key = d.Diagnosis_Key
) AS Visit_Category
GROUP BY Disease_Category
ORDER BY Total_Visits DESC;
/*---7.2 Top 10 Diagnoses by Frequency*/
SELECT
    d.Diagnosis_Text,
    COUNT(*) AS Total_Visits,
    COUNT(DISTINCT f.Patient_Key) AS Unique_Patients,
    ROUND(AVG(f.Total_Claim), 2) AS Avg_Cost
FROM Fact_Visits f
JOIN Bridge_Visit_Diagnosis b
    ON f.Visit_ID = b.Visit_ID
JOIN Dim_Diagnosis d
    ON b.Diagnosis_Key = d.Diagnosis_Key
WHERE d.Diagnosis_Text <> 'N/A'
GROUP BY d.Diagnosis_Text
ORDER BY Total_Visits DESC
LIMIT 10;

/* 7.3 Target Disease (Coarse) Distribution */

SELECT
    Disease_Category AS Target_Disease,
    COUNT(*) AS Total_Visits,
    COUNT(DISTINCT Patient_Key) AS Unique_Patients,

    ROUND(
        100.0 * COUNT(*) /
        (SELECT COUNT(*) FROM Fact_Visits),
        2
    ) AS Visit_Percentage,

    ROUND(AVG(Total_Claim), 2) AS Avg_Cost

FROM (
    SELECT DISTINCT
        f.Visit_ID,
        f.Patient_Key,
        f.Total_Claim,
        COALESCE(
            NULLIF(TRIM(d.Target_Disease_Coarse), ''),
            'Unknown'
        ) AS Disease_Category

    FROM Fact_Visits f

    LEFT JOIN Bridge_Visit_Diagnosis b
        ON f.Visit_ID = b.Visit_ID

    LEFT JOIN Dim_Diagnosis d
        ON b.Diagnosis_Key = d.Diagnosis_Key

) AS Visit_Disease

GROUP BY Disease_Category
ORDER BY Total_Visits DESC;
/*---7.4 ICD-10 Chapter Distribution*/
SELECT
    COALESCE(i.ICD10_Chapter, 'Unknown') AS ICD10_Chapter,

    COUNT(DISTINCT f.Visit_ID) AS Total_Visits,

    COUNT(DISTINCT f.Patient_Key) AS Unique_Patients,

    ROUND(
        100.0 * COUNT(DISTINCT f.Visit_ID) /
        (SELECT COUNT(*) FROM Fact_Visits),
        2
    ) AS Visit_Percentage,

    ROUND(SUM(x.Total_Claim), 2) AS Total_Cost

FROM (
    SELECT DISTINCT
        f.Visit_ID,
        f.Patient_Key,
        f.Total_Claim,
        b.ICD10_Key
    FROM Fact_Visits f
    LEFT JOIN Bridge_Visit_ICD10 b
        ON f.Visit_ID = b.Visit_ID
) x

JOIN Fact_Visits f
    ON x.Visit_ID = f.Visit_ID

LEFT JOIN Dim_ICD10 i
    ON x.ICD10_Key = i.ICD10_Key

GROUP BY COALESCE(i.ICD10_Chapter, 'Unknown')

ORDER BY Total_Visits DESC;
/*--7.5 Disease Category by Gender*/
SELECT
    x.Disease_Category,
    SUM(CASE WHEN x.Gender = 'Male' THEN 1 ELSE 0 END) AS Male_Visits,
    SUM(CASE WHEN x.Gender = 'Female' THEN 1 ELSE 0 END) AS Female_Visits,
    SUM(CASE WHEN x.Gender = 'Unknown' THEN 1 ELSE 0 END) AS Unknown_Visits,
    COUNT(*) AS Total_Visits
FROM (
    SELECT DISTINCT
        f.Visit_ID,
        f.Patient_Key,
        p.Gender,
        COALESCE(NULLIF(TRIM(d.Disease_Category), ''), 'Unknown') AS Disease_Category
    FROM Fact_Visits f
    JOIN Dim_Patient p ON p.Patient_Key = f.Patient_Key
    LEFT JOIN Bridge_Visit_Diagnosis b ON f.Visit_ID = b.Visit_ID
    LEFT JOIN Dim_Diagnosis d ON b.Diagnosis_Key = d.Diagnosis_Key
) AS x
GROUP BY x.Disease_Category
ORDER BY Total_Visits DESC;
/*--7.6 Disease Category by Age Group*/
SELECT
    x.Disease_Category,

    SUM(CASE WHEN x.Age < 18 THEN 1 ELSE 0 END) AS `Under_18`,

    SUM(CASE WHEN x.Age BETWEEN 18 AND 30 THEN 1 ELSE 0 END) AS `18_30`,

    SUM(CASE WHEN x.Age BETWEEN 31 AND 45 THEN 1 ELSE 0 END) AS `31_45`,

    SUM(CASE WHEN x.Age BETWEEN 46 AND 60 THEN 1 ELSE 0 END) AS `46_60`,

    SUM(CASE WHEN x.Age BETWEEN 61 AND 75 THEN 1 ELSE 0 END) AS `61_75`,

    SUM(CASE WHEN x.Age > 75 THEN 1 ELSE 0 END) AS `Above_75`,

    COUNT(*) AS Total_Visits

FROM (
    SELECT DISTINCT
        f.Visit_ID,
        f.Patient_Key,
        p.Age,
        COALESCE(
            NULLIF(TRIM(d.Disease_Category), ''),
            'Unknown'
        ) AS Disease_Category

    FROM Fact_Visits f

    JOIN Dim_Patient p
        ON p.Patient_Key = f.Patient_Key

    LEFT JOIN Bridge_Visit_Diagnosis b
        ON f.Visit_ID = b.Visit_ID

    LEFT JOIN Dim_Diagnosis d
        ON b.Diagnosis_Key = d.Diagnosis_Key

) AS x

GROUP BY x.Disease_Category
ORDER BY Total_Visits DESC;
/*--7.7 Disease Trend by Year (Top 5 Categories)*/
SELECT
    Yearly.Visit_Year,
    Yearly.Disease_Category,
    COUNT(*) AS Total_Visits

FROM (
    SELECT DISTINCT
        f.Visit_ID,
        dt.Year AS Visit_Year,
        d.Disease_Category

    FROM Fact_Visits f

    JOIN Dim_Date dt
        ON f.Visit_Date_ID = dt.Date_ID

    JOIN Bridge_Visit_Diagnosis b
        ON f.Visit_ID = b.Visit_ID

    JOIN Dim_Diagnosis d
        ON b.Diagnosis_Key = d.Diagnosis_Key

    WHERE d.Disease_Category IN (

        SELECT Top5.Disease_Category

        FROM (
            SELECT
                d2.Disease_Category,
                COUNT(DISTINCT f2.Visit_ID) AS Total_Visits

            FROM Fact_Visits f2

            JOIN Bridge_Visit_Diagnosis b2
                ON f2.Visit_ID = b2.Visit_ID

            JOIN Dim_Diagnosis d2
                ON b2.Diagnosis_Key = d2.Diagnosis_Key

            WHERE d2.Disease_Category IS NOT NULL
              AND TRIM(d2.Disease_Category) <> ''

            GROUP BY d2.Disease_Category
            ORDER BY Total_Visits DESC
            LIMIT 5

        ) AS Top5
    )

) AS Yearly

GROUP BY
    Yearly.Visit_Year,
    Yearly.Disease_Category

ORDER BY
    Yearly.Visit_Year,
    Total_Visits DESC;
/*------------------------------------------------------------Phase 8: Patient Behavior Analysis*/

/*------------------------------------------------------------8.1 Visit Frequency Distribution*/
SELECT
    Visit_Group,
    COUNT(*) AS Total_Patients,
    ROUND(
        100.0 * COUNT(*) / (SELECT COUNT(DISTINCT Patient_Key) FROM Fact_Visits),
        2
    ) AS Patient_Percentage
FROM (
    SELECT
        Patient_Key,
        CASE
            WHEN COUNT(*) = 1 THEN '1 visit'
            WHEN COUNT(*) BETWEEN 2 AND 3 THEN '2-3 visits'
            WHEN COUNT(*) BETWEEN 4 AND 6 THEN '4-6 visits'
            WHEN COUNT(*) BETWEEN 7 AND 10 THEN '7-10 visits'
            ELSE 'More than 10 visits'
        END AS Visit_Group
    FROM Fact_Visits
    GROUP BY Patient_Key
) AS Patient_Visits
GROUP BY Visit_Group
ORDER BY FIELD(
    Visit_Group,
    '1 visit',
    '2-3 visits',
    '4-6 visits',
    '7-10 visits',
    'More than 10 visits'
);


/*------------------------------------------------------------8.2 One-Time vs Repeat Patients*/
SELECT
    Patient_Type,
    COUNT(*) AS Total_Patients,
    ROUND(
        100.0 * COUNT(*) /
        (SELECT COUNT(DISTINCT Patient_Key) FROM Fact_Visits),
        2
    ) AS Patient_Percentage,
    SUM(Visits) AS Total_Visits,
    ROUND(SUM(Cost), 2) AS Total_Cost
FROM (
    SELECT
        Patient_Key,
        COUNT(*) AS Visits,
        SUM(Total_Claim) AS Cost,
        CASE
            WHEN COUNT(*) = 1 THEN 'One-Time Patient'
            ELSE 'Repeat Patient'
        END AS Patient_Type
    FROM Fact_Visits
    GROUP BY Patient_Key
) AS p
GROUP BY Patient_Type;

/*------------------------------------------------------------8.3 Top 10 Most Frequent Patients*/
SELECT
    p.Patient_ID,
    COUNT(*) AS Total_Visits,
    ROUND(SUM(f.Total_Claim), 2) AS Total_Cost,
    ROUND(AVG(f.Total_Claim), 2) AS Avg_Cost_Per_Visit
FROM Fact_Visits f
JOIN Dim_Patient p
    ON f.Patient_Key = p.Patient_Key
GROUP BY p.Patient_ID
ORDER BY Total_Visits DESC
LIMIT 10;

/*------------------------------------------------------------8.4 Time Between Visits*/
/* Gap Between Visits Distribution */

SELECT
    g.Gap_Between_Visits,
    COUNT(*) AS Total_Visits,

    ROUND(
        100.0 * COUNT(*) / (
            SELECT COUNT(*)
            FROM Fact_Visits f
            JOIN Dim_Date cd
                ON f.Visit_Date_ID = cd.Date_ID
            WHERE (
                SELECT MAX(pd.Full_Date)
                FROM Fact_Visits f2
                JOIN Dim_Date pd
                    ON f2.Visit_Date_ID = pd.Date_ID
                WHERE f2.Patient_Key = f.Patient_Key
                  AND (
                      pd.Full_Date < cd.Full_Date
                      OR (
                          pd.Full_Date = cd.Full_Date
                          AND f2.Visit_ID < f.Visit_ID
                      )
                  )
            ) IS NOT NULL
        ),
        2
    ) AS Percentage

FROM (
    SELECT
        CASE
            WHEN x.Days_Gap <= 7 THEN '0-7 days'
            WHEN x.Days_Gap <= 30 THEN '8-30 days'
            WHEN x.Days_Gap <= 90 THEN '31-90 days'
            WHEN x.Days_Gap <= 180 THEN '91-180 days'
            WHEN x.Days_Gap <= 365 THEN '181-365 days'
            ELSE 'More than 1 year'
        END AS Gap_Between_Visits

    FROM (
        SELECT
            f.Visit_ID,

            DATEDIFF(
                cd.Full_Date,
                (
                    SELECT MAX(pd.Full_Date)
                    FROM Fact_Visits f2
                    JOIN Dim_Date pd
                        ON f2.Visit_Date_ID = pd.Date_ID
                    WHERE f2.Patient_Key = f.Patient_Key
                      AND (
                          pd.Full_Date < cd.Full_Date
                          OR (
                              pd.Full_Date = cd.Full_Date
                              AND f2.Visit_ID < f.Visit_ID
                          )
                      )
                )
            ) AS Days_Gap

        FROM Fact_Visits f

        JOIN Dim_Date cd
            ON f.Visit_Date_ID = cd.Date_ID

    ) x

    WHERE x.Days_Gap IS NOT NULL
      AND x.Days_Gap >= 0

) g

GROUP BY g.Gap_Between_Visits

ORDER BY FIELD(
    g.Gap_Between_Visits,
    '0-7 days',
    '8-30 days',
    '31-90 days',
    '91-180 days',
    '181-365 days',
    'More than 1 year'
);
/*------------------------------------------------------------8.5 Average Days Between Visits*/
SELECT
    COUNT(*) AS Records_With_Previous_Visit,
    ROUND(AVG(days_since_last_visit), 2) AS Avg_Days_Between_Visits,
    MIN(days_since_last_visit) AS Min_Days,
    MAX(days_since_last_visit) AS Max_Days
FROM carelytics
WHERE days_since_last_visit IS NOT NULL
  AND days_since_last_visit >= 0;

/*------------------------------------------------------------8.6 Yearly Visit Trend*/
SELECT
    d.Year AS Visit_Year,
    COUNT(*) AS Total_Visits,
    COUNT(DISTINCT f.Patient_Key) AS Unique_Patients,
    ROUND(
        COUNT(*) / COUNT(DISTINCT f.Patient_Key),
        2
    ) AS Visits_Per_Patient,
    ROUND(SUM(f.Total_Claim), 2) AS Total_Cost
FROM Fact_Visits f
JOIN Dim_Date d
    ON f.Visit_Date_ID = d.Date_ID
GROUP BY d.Year
ORDER BY d.Year;

/*------------------------------------------------------------Phase 9: Readmission Analysis*/

/*------------------------------------------------------------9.1 Overall Readmission Summary*/
SELECT
    Window_Days,
    Readmitted_Visits,
    Total_Visits,
    ROUND(100.0 * Readmitted_Visits / Total_Visits, 2) AS Readmission_Rate,
    Patients_Readmitted
FROM (
    SELECT '30 days' AS Window_Days,
           SUM(LOWER(TRIM(Revisit_30)) IN ('1','yes','true')) AS Readmitted_Visits,
           COUNT(*) AS Total_Visits,
           COUNT(DISTINCT CASE WHEN LOWER(TRIM(Revisit_30)) IN ('1','yes','true') THEN Patient_Key END) AS Patients_Readmitted
    FROM Fact_Visits
    UNION ALL
    SELECT '90 days',
           SUM(LOWER(TRIM(Revisit_90)) IN ('1','yes','true')),
           COUNT(*),
           COUNT(DISTINCT CASE WHEN LOWER(TRIM(Revisit_90)) IN ('1','yes','true') THEN Patient_Key END)
    FROM Fact_Visits
    UNION ALL
    SELECT '180 days',
           SUM(LOWER(TRIM(Revisit_180)) IN ('1','yes','true')),
           COUNT(*),
           COUNT(DISTINCT CASE WHEN LOWER(TRIM(Revisit_180)) IN ('1','yes','true') THEN Patient_Key END)
    FROM Fact_Visits
) AS s;

/*------------------------------------------------------------9.2 Readmission Rate by Disease Category*/
SELECT
    x.Disease_Category,

    COUNT(*) AS Total_Visits,

    SUM(
        LOWER(TRIM(x.Revisit_30)) IN ('1', 'yes', 'true')
    ) AS Revisit_30_Count,

    ROUND(
        100.0 * SUM(
            LOWER(TRIM(x.Revisit_30)) IN ('1', 'yes', 'true')
        ) / COUNT(*),
        2
    ) AS Revisit_30_Rate,

    ROUND(
        100.0 * SUM(
            LOWER(TRIM(x.Revisit_90)) IN ('1', 'yes', 'true')
        ) / COUNT(*),
        2
    ) AS Revisit_90_Rate,

    ROUND(
        100.0 * SUM(
            LOWER(TRIM(x.Revisit_180)) IN ('1', 'yes', 'true')
        ) / COUNT(*),
        2
    ) AS Revisit_180_Rate

FROM (
    SELECT DISTINCT
        f.Visit_ID,

        COALESCE(
            NULLIF(TRIM(d.Disease_Category), ''),
            'Unknown'
        ) AS Disease_Category,

        f.Revisit_30,
        f.Revisit_90,
        f.Revisit_180

    FROM Fact_Visits f

    LEFT JOIN Bridge_Visit_Diagnosis b
        ON f.Visit_ID = b.Visit_ID

    LEFT JOIN Dim_Diagnosis d
        ON b.Diagnosis_Key = d.Diagnosis_Key

) AS x

GROUP BY x.Disease_Category

HAVING COUNT(*) >= 100

ORDER BY Revisit_30_Rate DESC;
/*------------------------------------------------------------9.3 Readmission Rate by Gender*/
SELECT
    p.Gender,
    COUNT(*) AS Total_Visits,
    ROUND(100.0 * SUM(LOWER(TRIM(f.Revisit_30)) IN ('1','yes','true')) / COUNT(*), 2) AS Revisit_30_Rate,
    ROUND(100.0 * SUM(LOWER(TRIM(f.Revisit_90)) IN ('1','yes','true')) / COUNT(*), 2) AS Revisit_90_Rate,
    ROUND(100.0 * SUM(LOWER(TRIM(f.Revisit_180)) IN ('1','yes','true')) / COUNT(*), 2) AS Revisit_180_Rate
FROM Fact_Visits f
JOIN Dim_Patient p ON p.Patient_Key = f.Patient_Key
GROUP BY p.Gender
ORDER BY Revisit_30_Rate DESC;

/*------------------------------------------------------------9.4 Readmission Rate by Age Group*/
SELECT
    CASE
        WHEN p.Age < 18 THEN 'Under 18'
        WHEN p.Age BETWEEN 18 AND 30 THEN '18-30'
        WHEN p.Age BETWEEN 31 AND 45 THEN '31-45'
        WHEN p.Age BETWEEN 46 AND 60 THEN '46-60'
        WHEN p.Age BETWEEN 61 AND 75 THEN '61-75'
        WHEN p.Age > 75 THEN 'Above 75'
        ELSE 'Unknown'
    END AS Age_Group,
    COUNT(*) AS Total_Visits,
    ROUND(100.0 * SUM(LOWER(TRIM(f.Revisit_30)) IN ('1','yes','true')) / COUNT(*), 2) AS Revisit_30_Rate,
    ROUND(100.0 * SUM(LOWER(TRIM(f.Revisit_90)) IN ('1','yes','true')) / COUNT(*), 2) AS Revisit_90_Rate,
    ROUND(100.0 * SUM(LOWER(TRIM(f.Revisit_180)) IN ('1','yes','true')) / COUNT(*), 2) AS Revisit_180_Rate
FROM Fact_Visits f
JOIN Dim_Patient p ON p.Patient_Key = f.Patient_Key
GROUP BY Age_Group
ORDER BY FIELD(
    Age_Group,
    'Under 18', '18-30', '31-45', '46-60', '61-75', 'Above 75', 'Unknown'
);

/*------------------------------------------------------------9.5 Readmission Trend by Year*/
SELECT
    d.Year AS Visit_Year,
    COUNT(*) AS Total_Visits,
    ROUND(100.0 * SUM(LOWER(TRIM(f.Revisit_30)) IN ('1','yes','true')) / COUNT(*), 2) AS Revisit_30_Rate,
    ROUND(100.0 * SUM(LOWER(TRIM(f.Revisit_90)) IN ('1','yes','true')) / COUNT(*), 2) AS Revisit_90_Rate,
    ROUND(100.0 * SUM(LOWER(TRIM(f.Revisit_180)) IN ('1','yes','true')) / COUNT(*), 2) AS Revisit_180_Rate
FROM Fact_Visits f
JOIN Dim_Date d
    ON f.Visit_Date_ID = d.Date_ID
GROUP BY d.Year
ORDER BY d.Year;

/*------------------------------------------------------------9.6 Top 10 Diagnoses by 30-Day Readmission Rate (min 100 visits)*/
SELECT
    d.Diagnosis_Text,
    COUNT(*) AS Total_Visits,
    SUM(LOWER(TRIM(f.Revisit_30)) IN ('1','yes','true')) AS Revisit_30_Count,
    ROUND(100.0 * SUM(LOWER(TRIM(f.Revisit_30)) IN ('1','yes','true')) / COUNT(*), 2) AS Revisit_30_Rate,
    ROUND(AVG(f.Total_Claim), 2) AS Avg_Cost
FROM Fact_Visits f
JOIN Bridge_Visit_Diagnosis b
    ON f.Visit_ID = b.Visit_ID
JOIN Dim_Diagnosis d
    ON b.Diagnosis_Key = d.Diagnosis_Key
WHERE d.Diagnosis_Text <> 'N/A'
GROUP BY d.Diagnosis_Text
HAVING COUNT(*) >= 100
ORDER BY Revisit_30_Rate DESC
LIMIT 10;

/*------------------------------------------------------------9.7 Days to Next Visit Distribution*/
SELECT
    x.Days_To_Next_Visit,
    COUNT(*) AS Total_Visits,

    ROUND(
        100.0 * COUNT(*) /
        (
            SELECT COUNT(*)
            FROM (
                SELECT
                    f.Visit_ID,
                    (
                        SELECT MIN(nd.Full_Date)
                        FROM Fact_Visits nf
                        JOIN Dim_Date nd
                            ON nf.Visit_Date_ID = nd.Date_ID
                        WHERE nf.Patient_Key = f.Patient_Key
                          AND (
                              nd.Full_Date > cd.Full_Date
                              OR (
                                  nd.Full_Date = cd.Full_Date
                                  AND nf.Visit_ID > f.Visit_ID
                              )
                          )
                    ) AS Next_Visit_Date

                FROM Fact_Visits f
                JOIN Dim_Date cd
                    ON f.Visit_Date_ID = cd.Date_ID
            ) AS next_visits
            WHERE next_visits.Next_Visit_Date IS NOT NULL
        ),
        2
    ) AS Percentage

FROM (
    SELECT
        CASE
            WHEN Days_Gap <= 7 THEN '0-7 days'
            WHEN Days_Gap <= 30 THEN '8-30 days'
            WHEN Days_Gap <= 90 THEN '31-90 days'
            WHEN Days_Gap <= 180 THEN '91-180 days'
            ELSE 'More than 180 days'
        END AS Days_To_Next_Visit

    FROM (
        SELECT
            f.Visit_ID,

            DATEDIFF(
                (
                    SELECT MIN(nd.Full_Date)
                    FROM Fact_Visits nf
                    JOIN Dim_Date nd
                        ON nf.Visit_Date_ID = nd.Date_ID
                    WHERE nf.Patient_Key = f.Patient_Key
                      AND (
                          nd.Full_Date > cd.Full_Date
                          OR (
                              nd.Full_Date = cd.Full_Date
                              AND nf.Visit_ID > f.Visit_ID
                          )
                      )
                ),
                cd.Full_Date
            ) AS Days_Gap

        FROM Fact_Visits f
        JOIN Dim_Date cd
            ON f.Visit_Date_ID = cd.Date_ID
    ) AS gaps

    WHERE Days_Gap IS NOT NULL
      AND Days_Gap >= 0

) AS x

GROUP BY x.Days_To_Next_Visit

ORDER BY FIELD(
    x.Days_To_Next_Visit,
    '0-7 days',
    '8-30 days',
    '31-90 days',
    '91-180 days',
    'More than 180 days'
);

/*------------------------------------------------------------9.8 Cost: Readmitted vs Not Readmitted (30 days)*/
SELECT
    CASE
        WHEN LOWER(TRIM(Revisit_30)) IN ('1', 'yes', 'true')
        THEN 'Readmitted within 30 days'
        ELSE 'Not readmitted'
    END AS Readmission_Status,

    COUNT(*) AS Total_Visits,

    ROUND(SUM(Total_Claim), 2) AS Total_Cost,

    ROUND(AVG(Total_Claim), 2) AS Avg_Cost_Per_Visit,

    ROUND(
        100.0 * SUM(Total_Claim) /
        (SELECT SUM(Total_Claim) FROM Fact_Visits),
        2
    ) AS Cost_Share_Percentage

FROM Fact_Visits

GROUP BY Readmission_Status;

/*------------------------------------------------------------9.9 Readmission Rate: Inpatient vs Outpatient-Only Visits*/
SELECT
    CASE
        WHEN Inpatient_Amount > 0 THEN 'Inpatient Visit'
        ELSE 'Outpatient / Other Visit'
    END AS Visit_Type,
    COUNT(*) AS Total_Visits,
    ROUND(100.0 * SUM(LOWER(TRIM(Revisit_30)) IN ('1','yes','true')) / COUNT(*), 2) AS Revisit_30_Rate,
    ROUND(100.0 * SUM(LOWER(TRIM(Revisit_90)) IN ('1','yes','true')) / COUNT(*), 2) AS Revisit_90_Rate,
    ROUND(AVG(Total_Claim), 2) AS Avg_Cost
FROM Fact_Visits
GROUP BY Visit_Type;

/*------------------------------------------------------------9.10 Frequent Readmitters (Patients by Number of 30-Day Revisits)*/
SELECT
    Readmission_Group,
    COUNT(*) AS Total_Patients,

    ROUND(
        100.0 * COUNT(*) /
        (SELECT COUNT(DISTINCT Patient_Key) FROM Fact_Visits),
        2
    ) AS Patient_Percentage,

    ROUND(SUM(Patient_Cost), 2) AS Total_Cost

FROM (
    SELECT
        Patient_Key,
        SUM(Total_Claim) AS Patient_Cost,

        CASE
            WHEN SUM(
                LOWER(TRIM(Revisit_30)) IN ('1', 'yes', 'true')
            ) = 0 THEN '0 readmissions'

            WHEN SUM(
                LOWER(TRIM(Revisit_30)) IN ('1', 'yes', 'true')
            ) BETWEEN 1 AND 2 THEN '1-2 readmissions'

            WHEN SUM(
                LOWER(TRIM(Revisit_30)) IN ('1', 'yes', 'true')
            ) BETWEEN 3 AND 5 THEN '3-5 readmissions'

            ELSE 'More than 5 readmissions'
        END AS Readmission_Group

    FROM Fact_Visits
    GROUP BY Patient_Key
) AS p

GROUP BY Readmission_Group

ORDER BY FIELD(
    Readmission_Group,
    '0 readmissions',
    '1-2 readmissions',
    '3-5 readmissions',
    'More than 5 readmissions'
);

/*------------------------------------------------------------Phase 10: Advanced SQL Queries*/

/*------------------------------------------------------------10.1 Monthly Cost with Running Total (Window Function: SUM OVER)*/
SELECT
    m.Year,
    m.Month_Name,
    m.Total_Visits,
    ROUND(m.Monthly_Cost, 2) AS Monthly_Cost,
    ROUND(
        (
            SELECT SUM(f2.Total_Claim)
            FROM Fact_Visits f2
            JOIN Dim_Date d2
                ON f2.Visit_Date_ID = d2.Date_ID
            WHERE d2.Year = m.Year
              AND d2.Month_Number <= m.Month_Number
        ),
        2
    ) AS Running_Total_In_Year

FROM (
    SELECT
        d.Year,
        d.Month_Number,
        d.Month_Name,
        COUNT(*) AS Total_Visits,
        SUM(f.Total_Claim) AS Monthly_Cost
    FROM Fact_Visits f
    JOIN Dim_Date d
        ON f.Visit_Date_ID = d.Date_ID
    GROUP BY
        d.Year,
        d.Month_Number,
        d.Month_Name
) AS m

ORDER BY
    m.Year,
    m.Month_Number;


/*------------------------------------------------------------10.2 Year-over-Year Cost Growth (Window Function: LAG)*/
SELECT
    y.Year,
    y.Total_Visits,
    ROUND(y.Total_Cost, 2) AS Total_Cost,

    (
        SELECT ROUND(SUM(f2.Total_Claim), 2)
        FROM Fact_Visits f2
        JOIN Dim_Date d2
            ON f2.Visit_Date_ID = d2.Date_ID
        WHERE d2.Year = y.Year - 1
    ) AS Previous_Year_Cost,

    ROUND(
        (
            y.Total_Cost -
            (
                SELECT SUM(f2.Total_Claim)
                FROM Fact_Visits f2
                JOIN Dim_Date d2
                    ON f2.Visit_Date_ID = d2.Date_ID
                WHERE d2.Year = y.Year - 1
            )
        )
        /
        NULLIF(
            (
                SELECT SUM(f2.Total_Claim)
                FROM Fact_Visits f2
                JOIN Dim_Date d2
                    ON f2.Visit_Date_ID = d2.Date_ID
                WHERE d2.Year = y.Year - 1
            ), 0
        ) * 100, 2
    ) AS Cost_Growth_Percentage

FROM (
    SELECT
        d.Year,
        COUNT(*) AS Total_Visits,
        SUM(f.Total_Claim) AS Total_Cost
    FROM Fact_Visits f
    JOIN Dim_Date d
        ON f.Visit_Date_ID = d.Date_ID
    GROUP BY d.Year
) y
ORDER BY y.Year;

/*------------------------------------------------------------10.3 Visits Costing More Than the Average of Their Own Disease Category (Correlated Subquery)*/

/* Step 1: Calculate Average Cost per Disease Category */

DROP TEMPORARY TABLE IF EXISTS Temp_Category_Avg;

CREATE TEMPORARY TABLE Temp_Category_Avg AS

SELECT
    x.Disease_Category,
    AVG(x.Visit_Cost) AS Category_Avg_Cost

FROM (
    SELECT DISTINCT
        f.Visit_ID,
        f.Total_Claim AS Visit_Cost,

        COALESCE(
            NULLIF(TRIM(d.Disease_Category), ''),
            'Unknown'
        ) AS Disease_Category

    FROM Fact_Visits f

    JOIN Bridge_Visit_Diagnosis b
        ON f.Visit_ID = b.Visit_ID

    JOIN Dim_Diagnosis d
        ON b.Diagnosis_Key = d.Diagnosis_Key

    WHERE f.Total_Claim IS NOT NULL
) AS x

GROUP BY x.Disease_Category;


/* Step 2: Create Index */

CREATE INDEX idx_category_avg
ON Temp_Category_Avg (Disease_Category(100));


/* Step 3: Identify High-Cost Visits */

SELECT
    x.Visit_ID,
    x.Disease_Category,

    ROUND(x.Visit_Cost, 2) AS Visit_Cost,

    ROUND(t.Category_Avg_Cost, 2) AS Category_Avg_Cost

FROM (
    SELECT DISTINCT
        f.Visit_ID,
        f.Total_Claim AS Visit_Cost,

        COALESCE(
            NULLIF(TRIM(d.Disease_Category), ''),
            'Unknown'
        ) AS Disease_Category

    FROM Fact_Visits f

    JOIN Bridge_Visit_Diagnosis b
        ON f.Visit_ID = b.Visit_ID

    JOIN Dim_Diagnosis d
        ON b.Diagnosis_Key = d.Diagnosis_Key

    WHERE f.Total_Claim IS NOT NULL
) AS x

JOIN Temp_Category_Avg t
    ON x.Disease_Category = t.Disease_Category

WHERE x.Visit_Cost > 3 * t.Category_Avg_Cost

ORDER BY x.Visit_Cost DESC

LIMIT 20;

/*------------------------------------------------------------10.4 Patient Visit Timeline with Gap Between Visits (Window Function: LAG on Dates)*/

DROP TEMPORARY TABLE IF EXISTS Temp_Top3_Patients;
CREATE TEMPORARY TABLE Temp_Top3_Patients AS
SELECT
    Patient_Key,
    COUNT(*) AS Total_Visits
FROM Fact_Visits
GROUP BY Patient_Key
ORDER BY Total_Visits DESC
LIMIT 3;

SELECT
    p.Patient_ID,
    d.Full_Date AS Visit_Date,
    f.Visit_ID,
    f.Total_Claim,

    (
        SELECT MAX(d2.Full_Date)
        FROM Fact_Visits f2
        JOIN Dim_Date d2
            ON f2.Visit_Date_ID = d2.Date_ID
        WHERE f2.Patient_Key = f.Patient_Key
          AND (
              d2.Full_Date < d.Full_Date
              OR (
                  d2.Full_Date = d.Full_Date
                  AND f2.Visit_ID < f.Visit_ID
              )
          )
    ) AS Previous_Visit_Date,

    (
        SELECT DATEDIFF(
            d.Full_Date,
            MAX(d2.Full_Date)
        )
        FROM Fact_Visits f2
        JOIN Dim_Date d2
            ON f2.Visit_Date_ID = d2.Date_ID
        WHERE f2.Patient_Key = f.Patient_Key
          AND (
              d2.Full_Date < d.Full_Date
              OR (
                  d2.Full_Date = d.Full_Date
                  AND f2.Visit_ID < f.Visit_ID
              )
          )
    ) AS Days_Since_Previous_Visit,

    (
        SELECT ROUND(SUM(f2.Total_Claim), 2)
        FROM Fact_Visits f2
        JOIN Dim_Date d2
            ON f2.Visit_Date_ID = d2.Date_ID
        WHERE f2.Patient_Key = f.Patient_Key
          AND (
              d2.Full_Date < d.Full_Date
              OR (
                  d2.Full_Date = d.Full_Date
                  AND f2.Visit_ID <= f.Visit_ID
              )
          )
    ) AS Patient_Cumulative_Cost

FROM Fact_Visits f
JOIN Dim_Patient p
    ON f.Patient_Key = p.Patient_Key
JOIN Dim_Date d
    ON f.Visit_Date_ID = d.Date_ID
JOIN Temp_Top3_Patients t
    ON f.Patient_Key = t.Patient_Key

ORDER BY
    p.Patient_ID,
    d.Full_Date,
    f.Visit_ID;

/*------------------------------------------------------------10.5 Top 20 Percent of Patients by Cost (Window Function: PERCENT_RANK)*/
-- ============================================
-- 1. Calculate Total Visits and Cost Per Patient
-- ============================================

SELECT
    Patient_Key,
    COUNT(*) AS Total_Visits,
    ROUND(SUM(Total_Claim), 2) AS Total_Cost
FROM Fact_Visits
GROUP BY Patient_Key
ORDER BY Total_Cost DESC;


-- ============================================
-- 2. Create Temporary Patient Cost Table
-- ============================================

DROP TEMPORARY TABLE IF EXISTS Temp_Patient_Cost;

CREATE TEMPORARY TABLE Temp_Patient_Cost AS
SELECT
    Patient_Key,
    COUNT(*) AS Total_Visits,
    SUM(Total_Claim) AS Total_Cost
FROM Fact_Visits
GROUP BY Patient_Key;


-- ============================================
-- 3. Rank Patients By Total Cost
-- ============================================

SET @Patient_Rank = 0;

DROP TEMPORARY TABLE IF EXISTS Temp_Ranked_Patients;

CREATE TEMPORARY TABLE Temp_Ranked_Patients AS
SELECT
    Patient_Key,
    Total_Cost,
    (@Patient_Rank := @Patient_Rank + 1) AS Patient_Rank
FROM (
    SELECT
        Patient_Key,
        Total_Cost
    FROM Temp_Patient_Cost
    ORDER BY Total_Cost DESC, Patient_Key
) AS Sorted_Patients;


-- ============================================
-- 4. Calculate Top 20% High-Cost Patients
-- ============================================

SELECT
    COUNT(*) AS Patients_In_Top_20_Percent,

    ROUND(SUM(Total_Cost), 2) AS Cost_Of_Top_20_Percent,

    ROUND(
        100.0 * SUM(Total_Cost) /
        NULLIF(
            (SELECT SUM(Total_Claim)
             FROM Fact_Visits),
            0
        ),
        2
    ) AS Share_Of_Total_Cost

FROM Temp_Ranked_Patients

WHERE Patient_Rank <= CEIL(
    (SELECT COUNT(*) FROM Temp_Patient_Cost) * 0.20
);

-- ============================================
-- 5. Display Patients Included In Top 20%
-- ============================================
SELECT
    R.Patient_Key,
    R.Total_Visits,
    ROUND(R.Total_Cost, 2) AS Total_Cost,
    R.Patient_Rank

FROM (
    SELECT
        RP.Patient_Key,
        PC.Total_Visits,
        RP.Total_Cost,
        RP.Patient_Rank
    FROM Temp_Ranked_Patients RP
    INNER JOIN Temp_Patient_Cost PC
        ON RP.Patient_Key = PC.Patient_Key
) AS R

WHERE R.Patient_Rank <= (
    SELECT CEIL(COUNT(*) * 0.20)
    FROM (
        SELECT Patient_Key
        FROM Fact_Visits
        GROUP BY Patient_Key
    ) AS Patient_Count
)

ORDER BY R.Patient_Rank;
/*------------------------------------------------------------10.7 Cost Component Share per Disease Category (Conditional Aggregation)*/

SELECT
    x.Disease_Category,

    ROUND(SUM(x.Total_Claim), 2) AS Total_Cost,

    ROUND(
        100.0 * SUM(x.Drugs_Amount)
        / NULLIF(SUM(x.Total_Claim), 0),
        2
    ) AS Drugs_Pct,

    ROUND(
        100.0 * SUM(x.Outpatient_Amount)
        / NULLIF(SUM(x.Total_Claim), 0),
        2
    ) AS Outpatient_Pct,

    ROUND(
        100.0 * SUM(x.Inpatient_Amount)
        / NULLIF(SUM(x.Total_Claim), 0),
        2
    ) AS Inpatient_Pct,

    ROUND(
        100.0 * SUM(x.Service_Amount)
        / NULLIF(SUM(x.Total_Claim), 0),
        2
    ) AS Service_Pct

FROM (
    SELECT DISTINCT
        f.Visit_ID,
        f.Total_Claim,
        f.Drugs_Amount,
        f.Outpatient_Amount,
        f.Inpatient_Amount,
        f.Service_Amount,

        COALESCE(
            NULLIF(TRIM(d.Disease_Category), ''),
            'Unknown'
        ) AS Disease_Category

    FROM Fact_Visits f

    JOIN Bridge_Visit_Diagnosis b
        ON f.Visit_ID = b.Visit_ID

    JOIN Dim_Diagnosis d
        ON b.Diagnosis_Key = d.Diagnosis_Key

) AS x

GROUP BY x.Disease_Category

HAVING COUNT(*) >= 100

ORDER BY Total_Cost DESC;

/*------------------------------------------------------------10.8 Diagnoses with More Than One ICD-10 Code (Bridge Table + HAVING)*/

SELECT
    d.Diagnosis_Text,

    COUNT(DISTINCT i.ICD10_Key) AS ICD10_Code_Count,

    GROUP_CONCAT(
        DISTINCT i.ICD10_Code
        ORDER BY i.ICD10_Code
        SEPARATOR ' | '
    ) AS ICD10_Codes

FROM Bridge_Visit_Diagnosis bd

JOIN Dim_Diagnosis d
    ON bd.Diagnosis_Key = d.Diagnosis_Key

JOIN Bridge_Visit_ICD10 bi
    ON bd.Visit_ID = bi.Visit_ID

JOIN Dim_ICD10 i
    ON bi.ICD10_Key = i.ICD10_Key

GROUP BY
    d.Diagnosis_Text

HAVING COUNT(DISTINCT i.ICD10_Key) > 1

ORDER BY
    ICD10_Code_Count DESC

LIMIT 20;

/*------------------------------------------------------------10.9 Reusable View: Visit Summary*/

CREATE OR REPLACE VIEW vw_visit_summary AS
SELECT
    f.Visit_ID,
    p.Patient_ID,

    vd.Full_Date AS Visit_Date,
    vd.Year AS Visit_Year,
    vd.Month_Name AS Visit_Month,

    p.Gender,
    p.Age,

    COALESCE(
        NULLIF(TRIM(d.Disease_Category), ''),
        'Unknown'
    ) AS Disease_Category,

    COALESCE(
        NULLIF(TRIM(d.Target_Disease_Coarse), ''),
        'Unknown'
    ) AS Target_Disease,

    f.Drugs_Amount,
    f.Outpatient_Amount,
    f.Inpatient_Amount,
    f.Service_Amount,
    f.Total_Claim,

    f.Revisit_30,
    f.Revisit_90,
    f.Revisit_180

FROM Fact_Visits f

JOIN Dim_Patient p
    ON f.Patient_Key = p.Patient_Key

JOIN Dim_Date vd
    ON f.Visit_Date_ID = vd.Date_ID

LEFT JOIN Bridge_Visit_Diagnosis b
    ON f.Visit_ID = b.Visit_ID

LEFT JOIN Dim_Diagnosis d
    ON b.Diagnosis_Key = d.Diagnosis_Key;
-- Test the view
CREATE OR REPLACE
ALGORITHM = UNDEFINED
SQL SECURITY INVOKER
VIEW vw_visit_summary AS

SELECT
    f.Visit_ID,
    p.Patient_ID,
    vd.Full_Date AS Visit_Date,
    vd.Year AS Visit_Year,
    vd.Month_Name AS Visit_Month,
    p.Gender,
    p.Age,

    COALESCE(dx.Disease_Category, 'Unknown') AS Disease_Category,
    COALESCE(dx.Target_Disease, 'Unknown') AS Target_Disease,

    f.Drugs_Amount,
    f.Outpatient_Amount,
    f.Inpatient_Amount,
    f.Service_Amount,
    f.Total_Claim,

    f.Revisit_30,
    f.Revisit_90,
    f.Revisit_180

FROM Fact_Visits f

JOIN Dim_Patient p
    ON f.Patient_Key = p.Patient_Key

LEFT JOIN Dim_Date vd
    ON f.Visit_Date_ID = vd.Date_ID

LEFT JOIN (
    SELECT
        b.Visit_ID,

        GROUP_CONCAT(
            DISTINCT NULLIF(TRIM(d.Disease_Category), '')
            SEPARATOR ' | '
        ) AS Disease_Category,

        GROUP_CONCAT(
            DISTINCT NULLIF(TRIM(d.Target_Disease_Coarse), '')
            SEPARATOR ' | '
        ) AS Target_Disease

    FROM Bridge_Visit_Diagnosis b

    JOIN Dim_Diagnosis d
        ON b.Diagnosis_Key = d.Diagnosis_Key

    GROUP BY b.Visit_ID
) dx
    ON f.Visit_ID = dx.Visit_ID;

/*------------------------------------------------------------10.10 Index to Speed Up Common Joins and Filters*/
CREATE INDEX idx_fact_patient
ON Fact_Visits (Patient_Key);

CREATE INDEX idx_fact_visit_date
ON Fact_Visits (Visit_Date_ID);

/*------------------------------------------------------------Phase 11: Business Insights Report*/

/*------------------------------------------------------------11.1 Executive Snapshot*/
SELECT
    COUNT(DISTINCT Patient_ID) AS Total_Patients,
    COUNT(*) AS Total_Visits,
    ROUND(SUM(Total_Claim), 2) AS Total_Cost,
    ROUND(AVG(Total_Claim), 2) AS Avg_Cost_Per_Visit,
    ROUND(SUM(Total_Claim) / COUNT(DISTINCT Patient_ID), 2) AS Avg_Cost_Per_Patient,
    ROUND(COUNT(*) / COUNT(DISTINCT Patient_ID), 2) AS Visits_Per_Patient,
    ROUND(100.0 * SUM(LOWER(TRIM(Revisit_30)) IN ('1','yes','true')) / COUNT(*), 2) AS Revisit_30_Rate,
    ROUND(100.0 * SUM(LOWER(TRIM(Revisit_90)) IN ('1','yes','true')) / COUNT(*), 2) AS Revisit_90_Rate,
    ROUND(100.0 * SUM(LOWER(TRIM(Revisit_180)) IN ('1','yes','true')) / COUNT(*), 2) AS Revisit_180_Rate,
    MIN(Visit_Year) AS First_Year,
    MAX(Visit_Year) AS Last_Year
FROM vw_visit_summary;

/*------------------------------------------------------------11.2 Cost Drivers: Components*/
SELECT
    ROUND(100.0 * SUM(Drugs_Amount) / SUM(Total_Claim), 2) AS Drugs_Pct,
    ROUND(100.0 * SUM(Outpatient_Amount) / SUM(Total_Claim), 2) AS Outpatient_Pct,
    ROUND(100.0 * SUM(Inpatient_Amount) / SUM(Total_Claim), 2) AS Inpatient_Pct,
    ROUND(100.0 * SUM(Service_Amount) / SUM(Total_Claim), 2) AS Service_Pct
FROM vw_visit_summary;

/*------------------------------------------------------------11.3 Volume vs Cost by Disease Category (Top 5 by Cost)*/
SELECT
    Disease_Category,
    COUNT(*) AS Total_Visits,

    ROUND(
        100.0 * COUNT(*) /
        (
            SELECT COUNT(*)
            FROM vw_visit_summary
            WHERE Disease_Category IS NOT NULL
              AND TRIM(Disease_Category) <> ''
        ), 2
    ) AS Visit_Share_Pct,

    ROUND(SUM(Total_Claim), 2) AS Total_Cost,

    ROUND(
        100.0 * SUM(Total_Claim) /
        (
            SELECT SUM(Total_Claim)
            FROM vw_visit_summary
            WHERE Disease_Category IS NOT NULL
              AND TRIM(Disease_Category) <> ''
        ), 2
    ) AS Cost_Share_Pct,

    ROUND(AVG(Total_Claim), 2) AS Avg_Cost_Per_Visit

FROM vw_visit_summary
WHERE Disease_Category IS NOT NULL
  AND TRIM(Disease_Category) <> ''

GROUP BY Disease_Category
ORDER BY Total_Cost DESC
LIMIT 5;

/*------------------------------------------------------------11.5 Cost of Quick Returns (30-Day Revisits)*/
SELECT
    CASE
        WHEN LOWER(TRIM(Revisit_30)) IN ('1','yes','true')
        THEN 'Returned within 30 days'
        ELSE 'Did not return'
    END AS Visit_Group,

    COUNT(*) AS Total_Visits,

    ROUND(SUM(Total_Claim), 2) AS Total_Cost,

    ROUND(
        100.0 * SUM(Total_Claim) /
        (
            SELECT SUM(Total_Claim)
            FROM vw_visit_summary
        ),
        2
    ) AS Cost_Share_Pct

FROM vw_visit_summary

GROUP BY Visit_Group;

/*------------------------------------------------------------11.6 High-Risk Segments (Age Group x Gender)*/
SELECT
    CASE
        WHEN Age < 18 THEN 'Under 18'
        WHEN Age BETWEEN 18 AND 45 THEN '18-45'
        WHEN Age BETWEEN 46 AND 60 THEN '46-60'
        WHEN Age BETWEEN 61 AND 75 THEN '61-75'
        WHEN Age > 75 THEN 'Above 75'
        ELSE 'Unknown'
    END AS Age_Group,
    Gender,
    COUNT(*) AS Total_Visits,
    COUNT(DISTINCT Patient_ID) AS Unique_Patients,
    ROUND(AVG(Total_Claim), 2) AS Avg_Cost_Per_Visit,
    ROUND(SUM(Total_Claim), 2) AS Total_Cost,
    ROUND(100.0 * SUM(LOWER(TRIM(Revisit_30)) IN ('1','yes','true')) / COUNT(*), 2) AS Revisit_30_Rate
FROM vw_visit_summary
WHERE Gender IN ('Male', 'Female')
GROUP BY Age_Group, Gender
HAVING COUNT(*) >= 100
ORDER BY Total_Cost DESC
LIMIT 10;

/*------------------------------------------------------------11.7 Yearly Performance Scorecard*/
DROP TEMPORARY TABLE IF EXISTS Temp_Yearly;
CREATE TEMPORARY TABLE Temp_Yearly AS
SELECT
    d.Year AS Visit_Year,
    COUNT(*) AS Total_Visits,
    COUNT(DISTINCT f.Patient_Key) AS Unique_Patients,
    SUM(f.Total_Claim) AS Total_Cost,
    AVG(f.Total_Claim) AS Avg_Cost_Per_Visit,
    100.0 * SUM(LOWER(TRIM(f.Revisit_30)) IN ('1','yes','true')) / COUNT(*) AS Revisit_30_Rate
FROM Fact_Visits f
JOIN Dim_Date d ON d.Date_ID = f.Visit_Date_ID
GROUP BY d.Year;


DROP TEMPORARY TABLE IF EXISTS Temp_Yearly_Previous;
CREATE TEMPORARY TABLE Temp_Yearly_Previous AS
SELECT *
FROM Temp_Yearly;
SELECT
    Y.Visit_Year,
    Y.Total_Visits,
    Y.Unique_Patients,

    ROUND(Y.Total_Cost, 2) AS Total_Cost,

    ROUND(Y.Avg_Cost_Per_Visit, 2) AS Avg_Cost_Per_Visit,

    ROUND(Y.Revisit_30_Rate, 2) AS Revisit_30_Rate,

    ROUND(
        100.0 * (Y.Total_Cost - P.Total_Cost)
        / NULLIF(P.Total_Cost, 0),
        2
    ) AS Cost_Growth_Pct

FROM Temp_Yearly Y

LEFT JOIN Temp_Yearly_Previous P
    ON P.Visit_Year = Y.Visit_Year - 1

ORDER BY Y.Visit_Year;

/*------------------------------------------------------------11.8 Data Limitations (for the Report)*/
SELECT 'Unknown gender' AS Issue,
       SUM(Gender = 'Unknown') AS Records,
       ROUND(100.0 * SUM(Gender = 'Unknown') / COUNT(*), 2) AS Percentage
FROM Dim_Patient
UNION ALL
SELECT 'Missing patient age',
       SUM(Age IS NULL),
       ROUND(100.0 * SUM(Age IS NULL) / COUNT(*), 2)
FROM Dim_Patient
UNION ALL
SELECT 'Missing discharge date',
       SUM(Discharge_Date_ID IS NULL),
       ROUND(100.0 * SUM(Discharge_Date_ID IS NULL) / COUNT(*), 2)
FROM Fact_Visits
UNION ALL
SELECT 'Missing diagnosis (N/A)',
       SUM(diagnosis_text = 'N/A'),
       ROUND(100.0 * SUM(diagnosis_text = 'N/A') / COUNT(*), 2)
FROM carelytics
UNION ALL
SELECT 'Missing ICD-10 (N/A)',
       SUM(icd10 = 'N/A'),
       ROUND(100.0 * SUM(icd10 = 'N/A') / COUNT(*), 2)
FROM carelytics
UNION ALL
SELECT 'Missing G-DRG (N/A)',
       SUM(G_DRG = 'N/A'),
       ROUND(100.0 * SUM(G_DRG = 'N/A') / COUNT(*), 2)
FROM Fact_Visits;






----------------/*editing*/

UPDATE Dim_Patient AS DP
SET DP.Age = (
    SELECT CAST(TRIM(C.age) AS UNSIGNED)
    FROM carelytics AS C
    WHERE C.patient_id = DP.Patient_ID
      AND C.age IS NOT NULL
      AND TRIM(C.age) REGEXP '^[0-9]+$'
    ORDER BY STR_TO_DATE(C.visit_date, '%Y-%m-%d') DESC
    LIMIT 1
)
WHERE DP.Patient_Key > 0;

UPDATE Dim_Patient AS DP
SET DP.Gender = (
    SELECT
        CASE
            WHEN LOWER(TRIM(C.gender)) IN ('f', 'female')
                THEN 'Female'
            WHEN LOWER(TRIM(C.gender)) IN ('m', 'male')
                THEN 'Male'
            ELSE 'Unknown'
        END
    FROM carelytics AS C
    WHERE C.patient_id = DP.Patient_ID
      AND C.gender IS NOT NULL
      AND TRIM(C.gender) <> ''
    ORDER BY STR_TO_DATE(C.visit_date, '%Y-%m-%d') DESC
    LIMIT 1
)
WHERE DP.Patient_Key > 0;

SELECT
    COUNT(*) AS Total_Patients,
    COUNT(Age) AS Patients_With_Age,
    SUM(Age IS NULL) AS Missing_Age
FROM Dim_Patient
WHERE Patient_Key > 0;


USE health_care;

ALTER TABLE dim_patient
ADD COLUMN Age INT,
ADD COLUMN Gender VARCHAR(20);


UPDATE dim_patient dp
JOIN (
    SELECT
        patient_id,
        MAX(age) AS Age,
        MAX(gender) AS Gender
    FROM carelytics
    WHERE patient_id IS NOT NULL
    GROUP BY patient_id
) c
ON dp.Patient_ID = c.patient_id
SET
    dp.Age = c.Age,
    dp.Gender = c.Gender;
    
ALTER TABLE fact_visits
DROP COLUMN Investigation_Amount;

select diagnosis_text  , icd10_codes
from Carelytics;

USE health_care;

-- Check Primary Keys and Foreign Keys
SELECT
    TABLE_NAME,
    CONSTRAINT_NAME,
    COLUMN_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'health_care'
AND TABLE_NAME IN (
    'bridge_visit_diagnosis',
    'bridge_visit_icd10',
    'bridge_diagnosis_icd10'
)
ORDER BY TABLE_NAME, CONSTRAINT_NAME;

-- Check Bridge Visit Diagnosis
SELECT
    Visit_ID,
    Diagnosis_Key,
    COUNT(*) AS Duplicate_Count
FROM bridge_visit_diagnosis
GROUP BY Visit_ID, Diagnosis_Key
HAVING COUNT(*) > 1;


-- Check Bridge Visit ICD10
SELECT
    Visit_ID,
    ICD10_Key,
    COUNT(*) AS Duplicate_Count
FROM bridge_visit_icd10
GROUP BY Visit_ID, ICD10_Key
HAVING COUNT(*) > 1;

-- Check Missing Visits in Diagnosis Bridge
SELECT COUNT(*) AS Missing_Visits
FROM bridge_visit_diagnosis B
LEFT JOIN fact_visits F
    ON B.Visit_ID = F.Visit_ID
WHERE F.Visit_ID IS NULL;


-- Check Missing Diagnoses
SELECT COUNT(*) AS Missing_Diagnoses
FROM bridge_visit_diagnosis B
LEFT JOIN dim_diagnosis D
    ON B.Diagnosis_Key = D.Diagnosis_Key
WHERE D.Diagnosis_Key IS NULL;


-- Check Missing Visits in ICD10 Bridge
SELECT COUNT(*) AS Missing_Visits
FROM bridge_visit_icd10 B
LEFT JOIN fact_visits F
    ON B.Visit_ID = F.Visit_ID
WHERE F.Visit_ID IS NULL;


-- Check Missing ICD10
SELECT COUNT(*) AS Missing_ICD10
FROM bridge_visit_icd10 B
LEFT JOIN dim_icd10 I
    ON B.ICD10_Key = I.ICD10_Key
WHERE I.ICD10_Key IS NULL;

DROP TABLE bridge_diagnosis_icd10;
DROP TABLE carelytics;

SET SQL_SAFE_UPDATES = 0;
UPDATE dim_patient
SET Gender = CASE
    WHEN UPPER(TRIM(Gender)) IN ('FEMALE', 'F') THEN 'FEMALE'
    WHEN UPPER(TRIM(Gender)) IN ('MALE', 'M') THEN 'MALE'
    ELSE Gender
END;