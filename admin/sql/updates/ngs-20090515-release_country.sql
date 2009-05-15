BEGIN;

ALTER TABLE release ADD country INTEGER;

ALTER TABLE release ADD CONSTRAINT release_fk_country
    FOREIGN KEY (country) REFERENCES country(id);

COMMIT;