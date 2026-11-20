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
  raise_application_error(-20001, 'Дата окончания срока владения не может быть назначена в будущем');
 END IF;
END;
/


