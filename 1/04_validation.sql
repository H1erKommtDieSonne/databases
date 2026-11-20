SET DEFINE OFF
WHENEVER SQLERROR EXIT FAILURE ROLLBACK
CREATE OR REPLACE TRIGGER v7_streets_validate
BEFORE INSERT OR UPDATE ON v7_streets FOR EACH ROW
BEGIN
 IF :NEW.street_name IS NULL OR NOT REGEXP_LIKE(:NEW.street_name, '^[А-Яа-яЁё0-9 .-]+$', 'c') OR NOT REGEXP_LIKE(:NEW.street_name, '[А-Яа-яЁё]', 'c') THEN
 raise_application_error(-20010, 'Улица: только русские буквы, цифры, пробел, точка и дефис');
 END IF;
END;
/
CREATE OR REPLACE TRIGGER v7_owners_validate
BEFORE INSERT OR UPDATE ON v7_owners FOR EACH ROW
BEGIN
 IF :NEW.full_name IS NULL OR NOT REGEXP_LIKE(:NEW.full_name, '^[А-ЯЁ][а-яё]+(-[А-ЯЁ][а-яё]+)?( [А-ЯЁ][а-яё]+(-[А-ЯЁ][а-яё]+)?){1,2}$', 'c') THEN
 raise_application_error(-20011, 'ФИО содержит русские буквы без цифр, каждая часть с заглавной. Укажите фамилию, имя и отчество');
 END IF;
 IF :NEW.birth_date > CURRENT_DATE THEN
 raise_application_error(-20012, 'Дата рождения не может быть в будущем');
 END IF;
END;
/
CREATE OR REPLACE TRIGGER v7_documents_validate
BEFORE INSERT OR UPDATE ON v7_documents FOR EACH ROW
DECLARE
 kind VARCHAR2(50 CHAR);
BEGIN
 kind := LOWER(TRIM(:NEW.document_type));
 IF kind IS NULL OR TRIM(:NEW.issued_by) IS NULL OR TRIM(:NEW.document_number) IS NULL THEN
 raise_application_error(-20014, 'Заполните тип, номер документа и кем он выдан');
 END IF;
 IF kind IN ('паспорт', 'заграничный паспорт') THEN
 IF :NEW.document_series IS NULL OR NOT REGEXP_LIKE(:NEW.document_series, '^[0-9]+$', 'c') OR NOT REGEXP_LIKE(:NEW.document_number, '^[0-9]+$', 'c') THEN
 raise_application_error(-20015, 'Серия и номер паспорта должны содержать только цифры');
 END IF;
 IF (kind = 'паспорт' AND (LENGTH(:NEW.document_series) <> 4 OR LENGTH(:NEW.document_number) <> 6)) OR (kind = 'заграничный паспорт' AND (LENGTH(:NEW.document_series) <> 2 OR LENGTH(:NEW.document_number) <> 9)) THEN
 raise_application_error(-20016, 'Формат: паспорт серия 4 и номер 6 цифр, загранпаспорт серия 2 и номер 9 цифр');
 END IF;
 END IF;
 IF :NEW.issued_on > CURRENT_DATE THEN
 raise_application_error(-20017, 'Дата выдачи не может быть в будущем');
 END IF;
END;
/
UPDATE v7_streets SET street_name=street_name;
UPDATE v7_owners SET full_name=full_name;
UPDATE v7_documents SET document_number=document_number;
COMMIT;
SELECT object_name,status FROM user_objects WHERE object_type='TRIGGER';
EXIT
