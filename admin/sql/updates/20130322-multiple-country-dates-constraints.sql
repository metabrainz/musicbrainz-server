\set ON_ERROR_STOP 1

BEGIN;

ALTER TABLE release_country
  ADD FOREIGN KEY (release) REFERENCES release (id),
  ADD FOREIGN KEY (country) REFERENCES country_area (area);

ALTER TABLE release_unknown_country
  ADD FOREIGN KEY (release) REFERENCES release (id);

COMMIT;
