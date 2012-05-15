BEGIN;

CREATE TRIGGER a_ins_track AFTER INSERT ON track FOR EACH ROW EXECUTE PROCEDURE a_ins_track();
CREATE TRIGGER a_upd_track AFTER UPDATE ON track FOR EACH ROW EXECUTE PROCEDURE a_upd_track();
CREATE TRIGGER a_del_track AFTER DELETE ON track FOR EACH ROW EXECUTE PROCEDURE a_del_track();
CREATE TRIGGER b_upd_track BEFORE UPDATE ON track FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

ALTER TABLE track ADD CONSTRAINT track_fk_recording FOREIGN KEY (recording) REFERENCES recording(id);
ALTER TABLE track ADD CONSTRAINT track_fk_tracklist FOREIGN KEY (tracklist) REFERENCES tracklist(id);
ALTER TABLE track ADD CONSTRAINT track_fk_name FOREIGN KEY (name) REFERENCES track_name(id);
ALTER TABLE track ADD CONSTRAINT track_fk_artist_credit
      FOREIGN KEY (artist_credit) REFERENCES artist_credit(id);

COMMIT;
