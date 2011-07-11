BEGIN;

ALTER TABLE edit
   ADD CONSTRAINT edit_fk_editor
   FOREIGN KEY (editor)
   REFERENCES editor(id);

ALTER TABLE edit_artist
   ADD CONSTRAINT edit_artist_fk_artist
   FOREIGN KEY (artist)
   REFERENCES artist(id)
   ON DELETE CASCADE;

ALTER TABLE edit_label
   ADD CONSTRAINT edit_label_fk_label
   FOREIGN KEY (label)
   REFERENCES label(id)
   ON DELETE CASCADE;

ALTER TABLE edit_note
   ADD CONSTRAINT edit_note_fk_editor
   FOREIGN KEY (editor)
   REFERENCES editor(id);

ALTER TABLE edit_recording
   ADD CONSTRAINT edit_recording_fk_recording
   FOREIGN KEY (recording)
   REFERENCES recording(id)
   ON DELETE CASCADE;

ALTER TABLE edit_release
   ADD CONSTRAINT edit_release_fk_release
   FOREIGN KEY (release)
   REFERENCES release(id)
   ON DELETE CASCADE;

ALTER TABLE edit_release_group
   ADD CONSTRAINT edit_release_group_fk_release_group
   FOREIGN KEY (release_group)
   REFERENCES release_group(id)
   ON DELETE CASCADE;

ALTER TABLE edit_url
   ADD CONSTRAINT edit_url_fk_url
   FOREIGN KEY (url)
   REFERENCES url(id)
   ON DELETE CASCADE;

ALTER TABLE edit_work
   ADD CONSTRAINT edit_work_fk_work
   FOREIGN KEY (work)
   REFERENCES work(id)
   ON DELETE CASCADE;

ALTER TABLE vote
   ADD CONSTRAINT vote_fk_editor
   FOREIGN KEY (editor)
   REFERENCES editor(id);

ALTER TABLE artist_rating_raw
   ADD CONSTRAINT artist_rating_raw_fk_artist
   FOREIGN KEY (artist)
   REFERENCES artist(id);

ALTER TABLE artist_rating_raw
   ADD CONSTRAINT artist_rating_raw_fk_editor
   FOREIGN KEY (editor)
   REFERENCES editor(id);

ALTER TABLE artist_tag_raw
   ADD CONSTRAINT artist_tag_raw_fk_artist
   FOREIGN KEY (artist)
   REFERENCES artist(id);

ALTER TABLE artist_tag_raw
   ADD CONSTRAINT artist_tag_raw_fk_editor
   FOREIGN KEY (editor)
   REFERENCES editor(id);

ALTER TABLE artist_tag_raw
   ADD CONSTRAINT artist_tag_raw_fk_tag
   FOREIGN KEY (tag)
   REFERENCES tag(id);

ALTER TABLE label_rating_raw
   ADD CONSTRAINT label_rating_raw_fk_label
   FOREIGN KEY (label)
   REFERENCES label(id);

ALTER TABLE label_rating_raw
   ADD CONSTRAINT label_rating_raw_fk_editor
   FOREIGN KEY (editor)
   REFERENCES editor(id);

ALTER TABLE label_tag_raw
   ADD CONSTRAINT label_tag_raw_fk_label
   FOREIGN KEY (label)
   REFERENCES label(id);

ALTER TABLE label_tag_raw
   ADD CONSTRAINT label_tag_raw_fk_editor
   FOREIGN KEY (editor)
   REFERENCES editor(id);

ALTER TABLE label_tag_raw
   ADD CONSTRAINT label_tag_raw_fk_tag
   FOREIGN KEY (tag)
   REFERENCES tag(id);

ALTER TABLE release_tag_raw
   ADD CONSTRAINT release_tag_raw_fk_release
   FOREIGN KEY (release)
   REFERENCES release(id);

ALTER TABLE release_tag_raw
   ADD CONSTRAINT release_tag_raw_fk_editor
   FOREIGN KEY (editor)
   REFERENCES editor(id);

ALTER TABLE release_tag_raw
   ADD CONSTRAINT release_tag_raw_fk_tag
   FOREIGN KEY (tag)
   REFERENCES tag(id);

ALTER TABLE release_group_rating_raw
   ADD CONSTRAINT release_group_rating_raw_fk_release_group
   FOREIGN KEY (release_group)
   REFERENCES release_group(id);

ALTER TABLE release_group_rating_raw
   ADD CONSTRAINT release_group_rating_raw_fk_editor
   FOREIGN KEY (editor)
   REFERENCES editor(id);

ALTER TABLE release_group_tag_raw
   ADD CONSTRAINT release_group_tag_raw_fk_release_group
   FOREIGN KEY (release_group)
   REFERENCES release_group(id);

ALTER TABLE release_group_tag_raw
   ADD CONSTRAINT release_group_tag_raw_fk_editor
   FOREIGN KEY (editor)
   REFERENCES editor(id);

ALTER TABLE release_group_tag_raw
   ADD CONSTRAINT release_group_tag_raw_fk_tag
   FOREIGN KEY (tag)
   REFERENCES tag(id);

ALTER TABLE recording_rating_raw
   ADD CONSTRAINT recording_rating_raw_fk_recording
   FOREIGN KEY (recording)
   REFERENCES recording(id);

ALTER TABLE recording_rating_raw
   ADD CONSTRAINT recording_rating_raw_fk_editor
   FOREIGN KEY (editor)
   REFERENCES editor(id);

ALTER TABLE recording_tag_raw
   ADD CONSTRAINT recording_tag_raw_fk_recording
   FOREIGN KEY (recording)
   REFERENCES recording(id);

ALTER TABLE recording_tag_raw
   ADD CONSTRAINT recording_tag_raw_fk_editor
   FOREIGN KEY (editor)
   REFERENCES editor(id);

ALTER TABLE recording_tag_raw
   ADD CONSTRAINT recording_tag_raw_fk_tag
   FOREIGN KEY (tag)
   REFERENCES tag(id);

ALTER TABLE work_rating_raw
   ADD CONSTRAINT work_rating_raw_fk_work
   FOREIGN KEY (work)
   REFERENCES work(id);

ALTER TABLE work_rating_raw
   ADD CONSTRAINT work_rating_raw_fk_editor
   FOREIGN KEY (editor)
   REFERENCES editor(id);

ALTER TABLE work_tag_raw
   ADD CONSTRAINT work_tag_raw_fk_work
   FOREIGN KEY (work)
   REFERENCES work(id);

ALTER TABLE work_tag_raw
   ADD CONSTRAINT work_tag_raw_fk_editor
   FOREIGN KEY (editor)
   REFERENCES editor(id);

ALTER TABLE work_tag_raw
   ADD CONSTRAINT work_tag_raw_fk_tag
   FOREIGN KEY (tag)
   REFERENCES tag(id);

COMMIT;
