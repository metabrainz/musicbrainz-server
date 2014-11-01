\set ON_ERROR_STOP 1
BEGIN;

ALTER TABLE area_tag ADD CONSTRAINT area_tag_fk_area FOREIGN KEY (area) REFERENCES area(id);
ALTER TABLE area_tag ADD CONSTRAINT area_tag_fk_tag FOREIGN KEY (tag) REFERENCES tag(id);

ALTER TABLE area_tag_raw ADD CONSTRAINT area_tag_raw_fk_area FOREIGN KEY (area) REFERENCES area(id);
ALTER TABLE area_tag_raw ADD CONSTRAINT area_tag_raw_fk_editor FOREIGN KEY (editor) REFERENCES editor(id);
ALTER TABLE area_tag_raw ADD CONSTRAINT area_tag_raw_fk_tag FOREIGN KEY (tag) REFERENCES tag(id);

ALTER TABLE instrument_tag ADD CONSTRAINT instrument_tag_fk_instrument FOREIGN KEY (instrument) REFERENCES instrument(id);
ALTER TABLE instrument_tag ADD CONSTRAINT instrument_tag_fk_tag FOREIGN KEY (tag) REFERENCES tag(id);

ALTER TABLE instrument_tag_raw ADD CONSTRAINT instrument_tag_raw_fk_instrument FOREIGN KEY (instrument) REFERENCES instrument(id);
ALTER TABLE instrument_tag_raw ADD CONSTRAINT instrument_tag_raw_fk_editor FOREIGN KEY (editor) REFERENCES editor(id);
ALTER TABLE instrument_tag_raw ADD CONSTRAINT instrument_tag_raw_fk_tag FOREIGN KEY (tag) REFERENCES tag(id);

ALTER TABLE series_tag ADD CONSTRAINT series_tag_fk_series FOREIGN KEY (series) REFERENCES series(id);
ALTER TABLE series_tag ADD CONSTRAINT series_tag_fk_tag FOREIGN KEY (tag) REFERENCES tag(id);

ALTER TABLE series_tag_raw ADD CONSTRAINT series_tag_raw_fk_series FOREIGN KEY (series) REFERENCES series(id);
ALTER TABLE series_tag_raw ADD CONSTRAINT series_tag_raw_fk_editor FOREIGN KEY (editor) REFERENCES editor(id);
ALTER TABLE series_tag_raw ADD CONSTRAINT series_tag_raw_fk_tag FOREIGN KEY (tag) REFERENCES tag(id);

CREATE TRIGGER b_upd_area_tag BEFORE UPDATE ON area_tag FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER b_upd_instrument_tag BEFORE UPDATE ON instrument_tag FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER b_upd_series_tag BEFORE UPDATE ON series_tag FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE CONSTRAINT TRIGGER delete_unused_tag
AFTER DELETE ON area_tag DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE PROCEDURE trg_delete_unused_tag_ref();

CREATE CONSTRAINT TRIGGER delete_unused_tag
AFTER DELETE ON instrument_tag DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE PROCEDURE trg_delete_unused_tag_ref();

CREATE CONSTRAINT TRIGGER delete_unused_tag
AFTER DELETE ON series_tag DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE PROCEDURE trg_delete_unused_tag_ref();

COMMIT;
