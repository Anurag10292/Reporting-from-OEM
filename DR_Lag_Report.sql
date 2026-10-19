SELECT
target_name AS standby_database,
MAX(CASE
WHEN LOWER(metric_column) LIKE '%apply%lag%'
THEN value
END) AS apply_lag,
MAX(CASE
WHEN LOWER(metric_column) LIKE '%transport%lag%'
THEN value
END) AS transport_lag
FROM sysman.mgmt$metric_current
WHERE target_type = 'oracle_database'
AND (
LOWER(metric_column) LIKE '%apply%lag%'
OR LOWER(metric_column) LIKE '%transport%lag%'
)
GROUP BY target_name
ORDER BY target_name;


SELECT owner,
       object_name,
       object_type
FROM   dba_objects
WHERE  owner = 'SYSMAN'
AND    object_name LIKE 'MGMT$%'
AND   (
          UPPER(object_name) LIKE '%DATAGUARD%'
       OR UPPER(object_name) LIKE '%DATA_GUARD%'
       OR UPPER(object_name) LIKE '%DG%'
       OR UPPER(object_name) LIKE '%ASSOC%'
      )
ORDER BY object_name;


SET LINES 250
SET PAGES 1000
 
COLUMN METRIC_NAME FORMAT A50
COLUMN METRIC_COLUMN FORMAT A50
 
SELECT DISTINCT
metric_name,
metric_column
FROM sysman.mgmt$metric_current
WHERE target_type = 'oracle_database'
AND (
LOWER(metric_name) LIKE '%dataguard%'
OR LOWER(metric_name) LIKE '%standby%'
OR LOWER(metric_column) LIKE '%lag%'
)
ORDER BY 1,2;
