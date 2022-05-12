-- Automatically generated, do not edit.
\set ON_ERROR_STOP 1

SET search_path = 'sitemaps';

ALTER TABLE artist_lastmod
   ADD CONSTRAINT artist_lastmod_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.artist(id)
   ON DELETE CASCADE;

ALTER TABLE label_lastmod
   ADD CONSTRAINT label_lastmod_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.label(id)
   ON DELETE CASCADE;

ALTER TABLE place_lastmod
   ADD CONSTRAINT place_lastmod_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.place(id)
   ON DELETE CASCADE;

ALTER TABLE recording_lastmod
   ADD CONSTRAINT recording_lastmod_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.recording(id)
   ON DELETE CASCADE;

ALTER TABLE release_group_lastmod
   ADD CONSTRAINT release_group_lastmod_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.release_group(id)
   ON DELETE CASCADE;

ALTER TABLE release_lastmod
   ADD CONSTRAINT release_lastmod_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.release(id)
   ON DELETE CASCADE;

ALTER TABLE work_lastmod
   ADD CONSTRAINT work_lastmod_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.work(id)
   ON DELETE CASCADE;

