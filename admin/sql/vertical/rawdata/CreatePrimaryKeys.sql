-- Automatically generated, do not edit.
\set ON_ERROR_STOP 1

ALTER TABLE artist_rating_raw ADD CONSTRAINT artist_rating_raw_pkey PRIMARY KEY (artist, editor);
ALTER TABLE artist_tag_raw ADD CONSTRAINT artist_tag_raw_pkey PRIMARY KEY (artist, editor, tag);
ALTER TABLE cdtoc_raw ADD CONSTRAINT cdtoc_raw_pkey PRIMARY KEY (id);
ALTER TABLE edit ADD CONSTRAINT edit_pkey PRIMARY KEY (id);
ALTER TABLE edit_artist ADD CONSTRAINT edit_artist_pkey PRIMARY KEY (edit, artist);
ALTER TABLE edit_label ADD CONSTRAINT edit_label_pkey PRIMARY KEY (edit, label);
ALTER TABLE edit_note ADD CONSTRAINT edit_note_pkey PRIMARY KEY (id);
ALTER TABLE edit_recording ADD CONSTRAINT edit_recording_pkey PRIMARY KEY (edit, recording);
ALTER TABLE edit_release ADD CONSTRAINT edit_release_pkey PRIMARY KEY (edit, release);
ALTER TABLE edit_release_group ADD CONSTRAINT edit_release_group_pkey PRIMARY KEY (edit, release_group);
ALTER TABLE edit_url ADD CONSTRAINT edit_url_pkey PRIMARY KEY (edit, url);
ALTER TABLE edit_work ADD CONSTRAINT edit_work_pkey PRIMARY KEY (edit, work);
ALTER TABLE label_rating_raw ADD CONSTRAINT label_rating_raw_pkey PRIMARY KEY (label, editor);
ALTER TABLE label_tag_raw ADD CONSTRAINT label_tag_raw_pkey PRIMARY KEY (label, editor, tag);
ALTER TABLE recording_rating_raw ADD CONSTRAINT recording_rating_raw_pkey PRIMARY KEY (recording, editor);
ALTER TABLE recording_tag_raw ADD CONSTRAINT recording_tag_raw_pkey PRIMARY KEY (recording, editor, tag);
ALTER TABLE release_group_rating_raw ADD CONSTRAINT release_group_rating_raw_pkey PRIMARY KEY (release_group, editor);
ALTER TABLE release_group_tag_raw ADD CONSTRAINT release_group_tag_raw_pkey PRIMARY KEY (release_group, editor, tag);
ALTER TABLE release_raw ADD CONSTRAINT release_raw_pkey PRIMARY KEY (id);
ALTER TABLE release_tag_raw ADD CONSTRAINT release_tag_raw_pkey PRIMARY KEY (release, editor, tag);
ALTER TABLE track_raw ADD CONSTRAINT track_raw_pkey PRIMARY KEY (id);
ALTER TABLE vote ADD CONSTRAINT vote_pkey PRIMARY KEY (id);
ALTER TABLE work_rating_raw ADD CONSTRAINT work_rating_raw_pkey PRIMARY KEY (work, editor);
ALTER TABLE work_tag_raw ADD CONSTRAINT work_tag_raw_pkey PRIMARY KEY (work, editor, tag);
