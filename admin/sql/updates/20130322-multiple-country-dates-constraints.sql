\set ON_ERROR_STOP 1

BEGIN;

ALTER TABLE release_country
  ADD FOREIGN KEY (release) REFERENCES release (id),
  ADD FOREIGN KEY (country) REFERENCES country_area (area);

ALTER TABLE release_unknown_country
  ADD FOREIGN KEY (release) REFERENCES release (id);

ALTER TABLE release_unknown_country ADD CONSTRAINT non_empty_date
  CHECK (date_year IS NOT NULL OR date_month IS NOT NULL OR date_day IS NOT NULL);

CREATE TRIGGER a_ins_release_event AFTER INSERT ON release_country
    FOR EACH ROW EXECUTE PROCEDURE a_ins_release_event();

CREATE TRIGGER a_upd_release_event AFTER UPDATE ON release_country
    FOR EACH ROW EXECUTE PROCEDURE a_upd_release_event();

CREATE TRIGGER a_del_release_event AFTER DELETE ON release_country
    FOR EACH ROW EXECUTE PROCEDURE a_del_release_event();

CREATE TRIGGER a_ins_release_event AFTER INSERT ON release_unknown_country
    FOR EACH ROW EXECUTE PROCEDURE a_ins_release_event();

CREATE TRIGGER a_upd_release_event AFTER UPDATE ON release_unknown_country
    FOR EACH ROW EXECUTE PROCEDURE a_upd_release_event();

CREATE TRIGGER a_del_release_event AFTER DELETE ON release_unknown_country
    FOR EACH ROW EXECUTE PROCEDURE a_del_release_event();

COMMIT;
