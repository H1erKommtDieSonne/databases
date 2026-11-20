SET LINESIZE 220
SET PAGESIZE 500
SET FEEDBACK ON
SELECT COUNT(*) FROM v7_ownership;
SELECT index_name, column_name, column_position FROM all_ind_columns WHERE index_owner = 'LAB7' AND table_name IN ('V7_OWNERSHIP','V7_BUILDINGS','V7_STREETS') ORDER BY index_name,column_position;
SELECT /*+ GATHER_PLAN_STATISTICS */ s.street_name, b.house_number, a.apartment_number
FROM (SELECT DISTINCT building_id, apartment_number FROM v7_ownership) a
JOIN v7_buildings b ON b.building_id = a.building_id
JOIN v7_streets s ON s.street_id = b.street_id
WHERE NOT EXISTS (
 SELECT 1
 FROM v7_ownership v
 WHERE v.building_id = a.building_id
   AND v.apartment_number = a.apartment_number
   AND v.started_on <= CURRENT_DATE
   AND (v.ended_on IS NULL OR v.ended_on > CURRENT_DATE)
)
ORDER BY s.street_name, b.house_number, a.apartment_number;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL,NULL,'ALLSTATS LAST'));
SELECT /*+ GATHER_PLAN_STATISTICS */ s.street_name, b.house_number, v.apartment_number
FROM v7_ownership v
JOIN v7_buildings b ON b.building_id = v.building_id
JOIN v7_streets s ON s.street_id = b.street_id
GROUP BY s.street_name, b.house_number, v.apartment_number
HAVING SUM(CASE WHEN v.started_on <= CURRENT_DATE
                    AND (v.ended_on IS NULL OR v.ended_on > CURRENT_DATE)
                THEN 1 ELSE 0 END) = 0
ORDER BY s.street_name, b.house_number, v.apartment_number;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL,NULL,'ALLSTATS LAST'));
EXIT


