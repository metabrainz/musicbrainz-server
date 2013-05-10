\set ON_ERROR_STOP 1

BEGIN;

SET search_path = 'documentation';

ALTER TABLE l_artist_artist_example
   ADD CONSTRAINT l_artist_artist_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_artist_artist(id);

ALTER TABLE l_artist_label_example
   ADD CONSTRAINT l_artist_label_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_artist_label(id);

ALTER TABLE l_artist_recording_example
   ADD CONSTRAINT l_artist_recording_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_artist_recording(id);

ALTER TABLE l_artist_release_example
   ADD CONSTRAINT l_artist_release_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_artist_release(id);

ALTER TABLE l_artist_release_group_example
   ADD CONSTRAINT l_artist_release_group_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_artist_release_group(id);

ALTER TABLE l_artist_url_example
   ADD CONSTRAINT l_artist_url_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_artist_url(id);

ALTER TABLE l_artist_work_example
   ADD CONSTRAINT l_artist_work_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_artist_work(id);

COMMIT;
