\set ON_ERROR_STOP 1

BEGIN;

ALTER TABLE edit_instrument
   ADD CONSTRAINT edit_instrument_fk_edit
   FOREIGN KEY (edit)
   REFERENCES edit(id);

ALTER TABLE edit_instrument
   ADD CONSTRAINT edit_instrument_fk_instrument
   FOREIGN KEY (instrument)
   REFERENCES instrument(id)
   ON DELETE CASCADE;

ALTER TABLE instrument
   ADD CONSTRAINT instrument_fk_type
   FOREIGN KEY (type)
   REFERENCES instrument_type(id);

ALTER TABLE instrument_alias
   ADD CONSTRAINT instrument_alias_fk_instrument
   FOREIGN KEY (instrument)
   REFERENCES instrument(id);

ALTER TABLE instrument_alias
   ADD CONSTRAINT instrument_alias_fk_type
   FOREIGN KEY (type)
   REFERENCES instrument_alias_type(id);

ALTER TABLE instrument_annotation
   ADD CONSTRAINT instrument_annotation_fk_instrument
   FOREIGN KEY (instrument)
   REFERENCES instrument(id);

ALTER TABLE instrument_annotation
   ADD CONSTRAINT instrument_annotation_fk_annotation
   FOREIGN KEY (annotation)
   REFERENCES annotation(id);

ALTER TABLE instrument_gid_redirect
   ADD CONSTRAINT instrument_gid_redirect_fk_new_id
   FOREIGN KEY (new_id)
   REFERENCES instrument(id);

ALTER TABLE l_area_instrument
   ADD CONSTRAINT l_area_instrument_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_area_instrument
   ADD CONSTRAINT l_area_instrument_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES area(id);

ALTER TABLE l_area_instrument
   ADD CONSTRAINT l_area_instrument_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES instrument(id);

ALTER TABLE l_artist_instrument
   ADD CONSTRAINT l_artist_instrument_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_artist_instrument
   ADD CONSTRAINT l_artist_instrument_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES artist(id);

ALTER TABLE l_artist_instrument
   ADD CONSTRAINT l_artist_instrument_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES instrument(id);

ALTER TABLE l_instrument_instrument
   ADD CONSTRAINT l_instrument_instrument_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_instrument_instrument
   ADD CONSTRAINT l_instrument_instrument_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES instrument(id);

ALTER TABLE l_instrument_instrument
   ADD CONSTRAINT l_instrument_instrument_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES instrument(id);

ALTER TABLE l_instrument_label
   ADD CONSTRAINT l_instrument_label_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_instrument_label
   ADD CONSTRAINT l_instrument_label_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES instrument(id);

ALTER TABLE l_instrument_label
   ADD CONSTRAINT l_instrument_label_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES label(id);

ALTER TABLE l_instrument_place
   ADD CONSTRAINT l_instrument_place_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_instrument_place
   ADD CONSTRAINT l_instrument_place_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES instrument(id);

ALTER TABLE l_instrument_place
   ADD CONSTRAINT l_instrument_place_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES place(id);

ALTER TABLE l_instrument_recording
   ADD CONSTRAINT l_instrument_recording_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_instrument_recording
   ADD CONSTRAINT l_instrument_recording_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES instrument(id);

ALTER TABLE l_instrument_recording
   ADD CONSTRAINT l_instrument_recording_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES recording(id);

ALTER TABLE l_instrument_release
   ADD CONSTRAINT l_instrument_release_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_instrument_release
   ADD CONSTRAINT l_instrument_release_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES instrument(id);

ALTER TABLE l_instrument_release
   ADD CONSTRAINT l_instrument_release_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES release(id);

ALTER TABLE l_instrument_release_group
   ADD CONSTRAINT l_instrument_release_group_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_instrument_release_group
   ADD CONSTRAINT l_instrument_release_group_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES instrument(id);

ALTER TABLE l_instrument_release_group
   ADD CONSTRAINT l_instrument_release_group_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES release_group(id);

ALTER TABLE l_instrument_url
   ADD CONSTRAINT l_instrument_url_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_instrument_url
   ADD CONSTRAINT l_instrument_url_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES instrument(id);

ALTER TABLE l_instrument_url
   ADD CONSTRAINT l_instrument_url_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES url(id);

ALTER TABLE l_instrument_work
   ADD CONSTRAINT l_instrument_work_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_instrument_work
   ADD CONSTRAINT l_instrument_work_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES instrument(id);

ALTER TABLE l_instrument_work
   ADD CONSTRAINT l_instrument_work_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES work(id);

COMMIT;
