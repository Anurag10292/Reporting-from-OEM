SET LINESIZE 250
SET PAGESIZE 1000

COLUMN DATABASE_NAME      FORMAT A35
COLUMN HOST_NAME          FORMAT A35
COLUMN DATABASE_SIZE_GB   FORMAT 999,999,990.99
COLUMN STATUS             FORMAT A15
COLUMN LAST_STARTED       FORMAT A20
COLUMN LAST_METRIC_TIME   FORMAT A20

WITH db_size AS
(
    SELECT
        target_guid,
        SUM(file_size) / POWER(1024,3) AS database_size_gb
    FROM
        sysman.mgmt$db_datafiles
    GROUP BY
        target_guid
),
db_status AS
(
    SELECT
        target_guid,
        target_name,
        target_type,
        host_name,
        last_metric_load_time
    FROM
        sysman.mgmt$target
    WHERE
        target_type = 'oracle_database'
)
SELECT
    t.target_name                                   AS database_name,
    t.host_name                                     AS host_name,

    ROUND(s.database_size_gb,2)                     AS database_size_gb,

    CASE
        WHEN t.last_metric_load_time >=
             SYSDATE - (15/1440)
        THEN 'RUNNING'
        ELSE 'STOPPED/UNKNOWN'
    END                                             AS status,

    'N/A'                                           AS last_started,

    TO_CHAR(t.last_metric_load_time,
            'DD-MON-YYYY HH24:MI')                  AS last_metric_time

FROM
    db_status t
LEFT JOIN
    db_size s
ON
    s.target_guid = t.target_guid

ORDER BY
    t.target_name;




SET LINES 250
SET PAGES 1000

COLUMN TARGET_NAME FORMAT A35
COLUMN HOST_NAME FORMAT A35
COLUMN LAST_METRIC_LOAD_TIME FORMAT A25
COLUMN OEM_STATUS FORMAT A20

SELECT
       target_name,
       host_name,

       CASE
           WHEN last_metric_load_time >= SYSDATE - 15/1440
             THEN 'RUNNING/MONITORED'
           WHEN last_metric_load_time IS NULL
             THEN 'UNKNOWN'
           ELSE
             'STOPPED/UNKNOWN'
       END AS oem_status,

       TO_CHAR(last_metric_load_time,
               'DD-MON-YYYY HH24:MI:SS')
               AS last_metric_load_time

FROM   sysman.mgmt$target

WHERE  target_type = 'oracle_database'

ORDER BY target_name;
