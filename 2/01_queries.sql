SELECT o.full_name, s.street_name, b.house_number, v.apartment_number
FROM v7_ownership v
JOIN v7_owners o ON o.owner_id = v.owner_id
JOIN v7_buildings b ON b.building_id = v.building_id
JOIN v7_streets s ON s.street_id = b.street_id
WHERE v.ownership_share = 1
  AND v.started_on <= CURRENT_DATE
  AND (v.ended_on IS NULL OR v.ended_on > CURRENT_DATE)
ORDER BY o.full_name, s.street_name, b.house_number, v.apartment_number;

SELECT o.full_name, o.birth_date, d.document_type, d.document_series,
       d.document_number, d.issued_by, d.issued_on
FROM v7_owners o
LEFT JOIN v7_documents d ON d.owner_id = o.owner_id
ORDER BY o.full_name, o.owner_id, d.document_type, d.document_series, d.document_number;

SELECT DISTINCT s.street_name, b.house_number, v.apartment_number
FROM v7_ownership v
JOIN v7_owners o ON o.owner_id = v.owner_id
JOIN v7_buildings b ON b.building_id = v.building_id
JOIN v7_streets s ON s.street_id = b.street_id
WHERE o.birth_date < ADD_MONTHS(TRUNC(CURRENT_DATE), -70 * 12)
  AND v.started_on <= CURRENT_DATE
  AND (v.ended_on IS NULL OR v.ended_on > CURRENT_DATE)
ORDER BY s.street_name, b.house_number, v.apartment_number;

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

SELECT s.street_name, b.house_number, v.apartment_number,
       SUM(v.ownership_share) AS total_share
FROM v7_ownership v
JOIN v7_buildings b ON b.building_id = v.building_id
JOIN v7_streets s ON s.street_id = b.street_id
WHERE v.started_on <= CURRENT_DATE
  AND (v.ended_on IS NULL OR v.ended_on > CURRENT_DATE)
GROUP BY s.street_name, b.house_number, v.apartment_number
HAVING SUM(v.ownership_share) > 1
ORDER BY s.street_name, b.house_number, v.apartment_number;
