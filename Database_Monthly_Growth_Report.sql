WITH monthly_size AS
(
    SELECT target_name,
           TRUNC(collection_timestamp, 'MM') month_start,
           MAX(TO_NUMBER(value)) size_gb
    FROM   sysman.mgmt$metric_details
    WHERE  target_type = 'oracle_database'
    AND    metric_name   = '<YOUR_SIZE_METRIC>'
    AND    metric_column = '<YOUR_SIZE_COLUMN>'
    AND    collection_timestamp >= ADD_MONTHS(TRUNC(SYSDATE,'MM'), -12)
    GROUP BY target_name,
             TRUNC(collection_timestamp, 'MM')
),
growth AS
(
    SELECT target_name,
           month_start,
           size_gb,
           LAG(size_gb)
             OVER (
                PARTITION BY target_name
                ORDER BY month_start
             ) previous_size_gb
    FROM monthly_size
)
SELECT target_name,
       TO_CHAR(month_start,'MON-YYYY') report_month,
       ROUND(size_gb,2) database_size_gb,
       ROUND(previous_size_gb,2) previous_month_gb,
       ROUND(size_gb - previous_size_gb,2) growth_gb,
       ROUND(
          ((size_gb - previous_size_gb) /
            NULLIF(previous_size_gb,0)) * 100,
          2
       ) growth_pct
FROM growth
ORDER BY target_name,
         month_start;
