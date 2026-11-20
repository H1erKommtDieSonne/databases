
CREATE TABLE v7_streets (
 street_id NUMBER(6) PRIMARY KEY,
 street_name VARCHAR2(100 CHAR) NOT NULL UNIQUE
);
CREATE TABLE v7_buildings (
 building_id NUMBER(6) PRIMARY KEY,
 street_id NUMBER(6) NOT NULL REFERENCES v7_streets(street_id),
 house_number VARCHAR2(15 CHAR) NOT NULL,
 CONSTRAINT v7_building_address_uq UNIQUE(street_id, house_number)
);
CREATE TABLE v7_owners (
 owner_id NUMBER(6) PRIMARY KEY,
 full_name VARCHAR2(150 CHAR) NOT NULL,
 birth_date DATE NOT NULL,
 gender CHAR(1 CHAR) NOT NULL CHECK(gender IN ('M','F'))
);
CREATE TABLE v7_documents (
 document_id NUMBER(6) PRIMARY KEY,
 owner_id NUMBER(6) NOT NULL REFERENCES v7_owners(owner_id),
 document_type VARCHAR2(50 CHAR) NOT NULL,
 document_series VARCHAR2(15 CHAR),
 document_number VARCHAR2(30 CHAR) NOT NULL,
 issued_by VARCHAR2(250 CHAR) NOT NULL,
 issued_on DATE NOT NULL,
 CONSTRAINT v7_document_uq UNIQUE(document_type,document_series,document_number)
);
CREATE TABLE v7_ownership (
 ownership_id NUMBER(6) PRIMARY KEY,
 owner_id NUMBER(6) NOT NULL REFERENCES v7_owners(owner_id),
 building_id NUMBER(6) NOT NULL REFERENCES v7_buildings(building_id),
 apartment_number NUMBER(4) NOT NULL CHECK(apartment_number > 0),
 ownership_share NUMBER(5,4) NOT NULL CHECK(ownership_share > 0 AND ownership_share <= 1),
 started_on DATE NOT NULL,
 ended_on DATE,
 CONSTRAINT v7_ownership_dates_ck CHECK(ended_on > started_on),
 CONSTRAINT v7_ownership_uq UNIQUE(owner_id,building_id,apartment_number,started_on)
);

CREATE OR REPLACE TRIGGER v7_ownership_end_check
BEFORE INSERT OR UPDATE OF ended_on ON v7_ownership
FOR EACH ROW
BEGIN
 IF :NEW.ended_on > CURRENT_DATE THEN
  raise_application_error(-20001, 'Дата окончания владения не может быть указана в будущем');
 END IF;
END;
/

