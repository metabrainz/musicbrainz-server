\set ON_ERROR_STOP 1
BEGIN;

ALTER TABLE editor_subscribe_artist_deleted
   ADD CONSTRAINT editor_subscribe_artist_deleted_fk_gid
   FOREIGN KEY (gid)
   REFERENCES deleted_entity(gid);

ALTER TABLE editor_subscribe_label_deleted
   ADD CONSTRAINT editor_subscribe_label_deleted_fk_gid
   FOREIGN KEY (gid)
   REFERENCES deleted_entity(gid);

ALTER TABLE editor_subscribe_series_deleted
   ADD CONSTRAINT editor_subscribe_series_deleted_fk_gid
   FOREIGN KEY (gid)
   REFERENCES deleted_entity(gid);

COMMIT;
