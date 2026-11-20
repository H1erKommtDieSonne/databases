EXPLAIN PLAN SET STATEMENT_ID = 'V7_NOT_EXISTS' FOR
SELECT s.street_name, b.house_number, a.apartment_number
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

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY('PLAN_TABLE', 'V7_NOT_EXISTS', 'TYPICAL'));

SELECT s.street_name, b.house_number, v.apartment_number
FROM v7_ownership v
JOIN v7_buildings b ON b.building_id = v.building_id
JOIN v7_streets s ON s.street_id = b.street_id
GROUP BY s.street_name, b.house_number, v.apartment_number
HAVING SUM(CASE WHEN v.started_on <= CURRENT_DATE
                    AND (v.ended_on IS NULL OR v.ended_on > CURRENT_DATE)
                THEN 1 ELSE 0 END) = 0
ORDER BY s.street_name, b.house_number, v.apartment_number;

EXPLAIN PLAN SET STATEMENT_ID = 'V7_GROUP_BY' FOR
SELECT s.street_name, b.house_number, v.apartment_number
FROM v7_ownership v
JOIN v7_buildings b ON b.building_id = v.building_id
JOIN v7_streets s ON s.street_id = b.street_id
GROUP BY s.street_name, b.house_number, v.apartment_number
HAVING SUM(CASE WHEN v.started_on <= CURRENT_DATE
                    AND (v.ended_on IS NULL OR v.ended_on > CURRENT_DATE)
                THEN 1 ELSE 0 END) = 0
ORDER BY s.street_name, b.house_number, v.apartment_number;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY('PLAN_TABLE', 'V7_GROUP_BY', 'TYPICAL'));
