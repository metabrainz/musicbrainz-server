\set ON_ERROR_STOP 1

BEGIN;

ALTER TABLE edit_instrument ADD CONSTRAINT edit_instrument_pkey PRIMARY KEY (edit, instrument);
ALTER TABLE instrument ADD CONSTRAINT instrument_pkey PRIMARY KEY (id);
ALTER TABLE instrument_alias ADD CONSTRAINT instrument_alias_pkey PRIMARY KEY (id);
ALTER TABLE instrument_alias_type ADD CONSTRAINT instrument_alias_type_pkey PRIMARY KEY (id);
ALTER TABLE instrument_annotation ADD CONSTRAINT instrument_annotation_pkey PRIMARY KEY (instrument, annotation);
ALTER TABLE instrument_gid_redirect ADD CONSTRAINT instrument_gid_redirect_pkey PRIMARY KEY (gid);
ALTER TABLE instrument_type ADD CONSTRAINT instrument_type_pkey PRIMARY KEY (id);
ALTER TABLE l_area_instrument ADD CONSTRAINT l_area_instrument_pkey PRIMARY KEY (id);
ALTER TABLE l_artist_instrument ADD CONSTRAINT l_artist_instrument_pkey PRIMARY KEY (id);
ALTER TABLE l_instrument_instrument ADD CONSTRAINT l_instrument_instrument_pkey PRIMARY KEY (id);
ALTER TABLE l_instrument_label ADD CONSTRAINT l_instrument_label_pkey PRIMARY KEY (id);
ALTER TABLE l_instrument_place ADD CONSTRAINT l_instrument_place_pkey PRIMARY KEY (id);
ALTER TABLE l_instrument_recording ADD CONSTRAINT l_instrument_recording_pkey PRIMARY KEY (id);
ALTER TABLE l_instrument_release ADD CONSTRAINT l_instrument_release_pkey PRIMARY KEY (id);
ALTER TABLE l_instrument_release_group ADD CONSTRAINT l_instrument_release_group_pkey PRIMARY KEY (id);
ALTER TABLE l_instrument_url ADD CONSTRAINT l_instrument_url_pkey PRIMARY KEY (id);
ALTER TABLE l_instrument_work ADD CONSTRAINT l_instrument_work_pkey PRIMARY KEY (id);

--ROLLBACK;
COMMIT;
