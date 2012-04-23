-- MBS-842, Allow vinyl style track numbers and sides by adding a free-text trackno column.

BEGIN;

CREATE TABLE tmp_track AS SELECT *, position::text AS number FROM track;

ALTER TABLE track DROP CONSTRAINT track_pkey;
ALTER TABLE tmp_track ADD CONSTRAINT track_pkey PRIMARY KEY (id);

DROP INDEX track_idx_recording;
DROP INDEX track_idx_tracklist;
DROP INDEX track_idx_name;
DROP INDEX track_idx_artist_credit;

CREATE INDEX track_idx_recording ON tmp_track (recording);
CREATE INDEX track_idx_tracklist ON tmp_track (tracklist, position);
CREATE INDEX track_idx_name ON tmp_track (name);
CREATE INDEX track_idx_artist_credit ON tmp_track (artist_credit);

DROP TRIGGER a_ins_track ON track;
DROP TRIGGER a_upd_track ON track;
DROP TRIGGER a_del_track ON track;
DROP TRIGGER b_upd_track ON track;

CREATE TRIGGER a_ins_track AFTER INSERT ON tmp_track FOR EACH ROW EXECUTE PROCEDURE a_ins_track();
CREATE TRIGGER a_upd_track AFTER UPDATE ON tmp_track FOR EACH ROW EXECUTE PROCEDURE a_upd_track();
CREATE TRIGGER a_del_track AFTER DELETE ON tmp_track FOR EACH ROW EXECUTE PROCEDURE a_del_track();
CREATE TRIGGER b_upd_track BEFORE UPDATE ON tmp_track FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

ALTER TABLE tmp_track ADD CONSTRAINT track_fk_recording FOREIGN KEY (recording) REFERENCES recording(id);
ALTER TABLE tmp_track ADD CONSTRAINT track_fk_tracklist FOREIGN KEY (tracklist) REFERENCES tracklist(id);
ALTER TABLE tmp_track ADD CONSTRAINT track_fk_name FOREIGN KEY (name) REFERENCES track_name(id);
ALTER TABLE tmp_track ADD CONSTRAINT track_fk_artist_credit
      FOREIGN KEY (artist_credit) REFERENCES artist_credit(id);

ALTER TABLE tmp_track ADD CONSTRAINT track_edits_pending_check CHECK (edits_pending >= 0);
ALTER TABLE tmp_track ADD CONSTRAINT track_length_check CHECK (length IS NULL OR length > 0);

ALTER TABLE tmp_track ALTER COLUMN id            SET DEFAULT nextval('track_id_seq'::regclass);
ALTER TABLE tmp_track ALTER COLUMN recording     SET NOT NULL;
ALTER TABLE tmp_track ALTER COLUMN tracklist     SET NOT NULL;
ALTER TABLE tmp_track ALTER COLUMN position      SET NOT NULL;
ALTER TABLE tmp_track ALTER COLUMN number        SET NOT NULL;
ALTER TABLE tmp_track ALTER COLUMN name          SET NOT NULL;
ALTER TABLE tmp_track ALTER COLUMN artist_credit SET NOT NULL;
ALTER TABLE tmp_track ALTER COLUMN last_updated  SET NOT NULL;
ALTER TABLE tmp_track ALTER COLUMN last_updated  SET DEFAULT now();

ALTER SEQUENCE track_id_seq OWNED BY tmp_track.id;
DROP TABLE track;
ALTER TABLE tmp_track RENAME TO track;

COMMIT;

