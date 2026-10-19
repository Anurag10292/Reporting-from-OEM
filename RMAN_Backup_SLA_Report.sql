Set lines 300
set pages 200
Col host_name for a35
Col target_name for a30
col full for a20
col incr for a20
col lev0 for a20
col lev1 for a20
SELECT 
ROWNUM n
,host_name
,target_name
--,full_h
,CASE
WHEN (NVL(full_h,1000)=1000) THEN ' '
WHEN (NVL(full_h,1000)<24)   THEN NVL(full_h,1000)||' hour(s)'
WHEN (NVL(full_h,1000)>=24)  THEN TRUNC(NVL(full_h,1000)/24)|| ' day(s) ' || SUBSTR((NUMTODSINTERVAL(NVL(full_h,1000), 'HOUR')), 12,2) || ' hour(s)'
END full
--,incr_h
,CASE
WHEN (NVL(incr_h,1000)=1000) THEN ' '
WHEN (NVL(incr_h,1000)<24)   THEN NVL(incr_h,1000)||' hour(s)'
WHEN (NVL(incr_h,1000)>=24)  THEN TRUNC(NVL(incr_h,1000)/24)|| ' day(s) ' || SUBSTR((NUMTODSINTERVAL(NVL(incr_h,1000), 'HOUR')), 12,2) || ' hour(s)'
END incr
--,lev0_h
,CASE
WHEN (NVL(lev0_h,1000)=1000) THEN ' '
WHEN (NVL(lev0_h,1000)<24)   THEN NVL(lev0_h,1000)||' hour(s)'
WHEN (NVL(lev0_h,1000)>=24)  THEN TRUNC(NVL(lev0_h,1000)/24)|| ' day(s) ' || SUBSTR((NUMTODSINTERVAL(NVL(lev0_h,1000), 'HOUR')), 12,2) || ' hour(s)'
END lev0
--,lev1_h
,CASE
WHEN (NVL(lev1_h,1000)=1000) THEN ' '
WHEN (NVL(lev1_h,1000)<24)   THEN NVL(lev1_h,1000)||' hour(s)'
WHEN (NVL(lev1_h,1000)>=24)  THEN TRUNC(NVL(lev1_h,1000)/24)|| ' day(s) ' || SUBSTR((NUMTODSINTERVAL(NVL(lev1_h,1000), 'HOUR')), 12,2) || ' hour(s)'
END lev1
--,arch_h
,CASE
WHEN (NVL(arch_h,1000)=1000) THEN ' '
WHEN (NVL(arch_h,1000)<24)   THEN NVL(arch_h,1000)||' hour(s)'
WHEN (NVL(arch_h,1000)>=24)  THEN TRUNC(NVL(arch_h,1000)/24)|| ' day(s) ' || SUBSTR((NUMTODSINTERVAL(NVL(arch_h,1000), 'HOUR')), 12,2) || ' hour(s)'
END arch
,CASE
WHEN ( NOT (NVL(full_h,1000)<7*24 OR NVL(lev0_h,1000)<7*24 or NVL(incr_h,1000)<7*24 ) )
THEN 'WARNING: No full or level0 on last 7 days'
WHEN ( NOT (NVL(full_h,1000)<24 or NVL(lev0_h,1000)<24 or NVL(lev1_h,1000)<24 or NVL(incr_h,1000)<24) )
THEN 'WARNING: No full, incr, level0 or level1 on last 24 hours'
WHEN ( NOT NVL(arch_h,1000)<6 )
THEN 'WARNING: No backup archive on last 6 hours'
END info
FROM
(
SELECT 
host_name
,target_name
,target_guid
,MAX(DECODE(typelevel, 'DB FULL', hours, NULL)    ) full_h
,MAX(DECODE(typelevel, 'DB INCR', hours, NULL)    ) incr_h
,MAX(DECODE(typelevel, 'DB INCR0', hours, NULL)   ) lev0_h
,MAX(DECODE(typelevel, 'DB INCR1', hours, NULL)   ) lev1_h
,MAX(DECODE(typelevel, 'ARCHIVELOG', hours, NULL) ) arch_h
FROM
(
SELECT 
T.host_name
,T.TARGET_GUID
,UPPER(T.TARGET_NAME) target_name
,B.INPUT_TYPE || B.INCREMENTAL_LEVEL typelevel
,CEIL((sysdate -  max(END_TIME))*24) hours
FROM SYSMAN.MGMT$TARGET T
,(select * from SYSMAN.MGMT$DB_BACKUP_HISTORY where status like 'COMPLETED%' )  B
-- WHERE B.TARGET_GUID (+) = T.TARGET_GUID
WHERE B.TARGET_GUID = T.TARGET_GUID
AND t.target_type in ('rac_database','oracle_database')
GROUP BY 
T.host_name
,T.TARGET_GUID
,T.target_name
,B.INPUT_TYPE || B.INCREMENTAL_LEVEL
)
GROUP BY HOST_NAME, TARGET_GUID,TARGET_NAME
ORDER BY HOST_NAME, TARGET_NAME
)
/
