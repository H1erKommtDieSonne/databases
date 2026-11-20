SET DEFINE OFF
UPDATE v7_streets SET street_name='Lenina' WHERE street_id=1;
UPDATE v7_owners SET full_name='Иванов Иван2 Иванович' WHERE owner_id=1;
UPDATE v7_owners SET full_name='иванов Иван Иванович' WHERE owner_id=1;
UPDATE v7_documents SET document_number='12А456' WHERE document_id=1;
UPDATE v7_owners SET birth_date=CURRENT_DATE+1 WHERE owner_id=1;
UPDATE v7_documents SET document_number='123' WHERE document_id=1;
UPDATE v7_streets SET street_name='8 Марта' WHERE street_id=1;
UPDATE v7_owners SET full_name='Иванов-Петров Пётр Ильич' WHERE owner_id=1;
ROLLBACK;
EXIT
