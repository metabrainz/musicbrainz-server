-- Automatically generated, do not edit.
\set ON_ERROR_STOP 1

SET search_path = 'documentation';

ALTER TABLE l_area_area_example ADD CONSTRAINT l_area_area_example_pkey PRIMARY KEY (id);
ALTER TABLE l_area_artist_example ADD CONSTRAINT l_area_artist_example_pkey PRIMARY KEY (id);
ALTER TABLE l_area_label_example ADD CONSTRAINT l_area_label_example_pkey PRIMARY KEY (id);
ALTER TABLE l_area_recording_example ADD CONSTRAINT l_area_recording_example_pkey PRIMARY KEY (id);
ALTER TABLE l_area_release_example ADD CONSTRAINT l_area_release_example_pkey PRIMARY KEY (id);
ALTER TABLE l_area_release_group_example ADD CONSTRAINT l_area_release_group_example_pkey PRIMARY KEY (id);
ALTER TABLE l_area_url_example ADD CONSTRAINT l_area_url_example_pkey PRIMARY KEY (id);
ALTER TABLE l_area_work_example ADD CONSTRAINT l_area_work_example_pkey PRIMARY KEY (id);
ALTER TABLE l_artist_artist_example ADD CONSTRAINT l_artist_artist_example_pkey PRIMARY KEY (id);
ALTER TABLE l_artist_label_example ADD CONSTRAINT l_artist_label_example_pkey PRIMARY KEY (id);
ALTER TABLE l_artist_recording_example ADD CONSTRAINT l_artist_recording_example_pkey PRIMARY KEY (id);
ALTER TABLE l_artist_release_example ADD CONSTRAINT l_artist_release_example_pkey PRIMARY KEY (id);
ALTER TABLE l_artist_release_group_example ADD CONSTRAINT l_artist_release_group_example_pkey PRIMARY KEY (id);
ALTER TABLE l_artist_url_example ADD CONSTRAINT l_artist_url_example_pkey PRIMARY KEY (id);
ALTER TABLE l_artist_work_example ADD CONSTRAINT l_artist_work_example_pkey PRIMARY KEY (id);
ALTER TABLE l_label_label_example ADD CONSTRAINT l_label_label_example_pkey PRIMARY KEY (id);
ALTER TABLE l_label_recording_example ADD CONSTRAINT l_label_recording_example_pkey PRIMARY KEY (id);
ALTER TABLE l_label_release_example ADD CONSTRAINT l_label_release_example_pkey PRIMARY KEY (id);
ALTER TABLE l_label_release_group_example ADD CONSTRAINT l_label_release_group_example_pkey PRIMARY KEY (id);
ALTER TABLE l_label_url_example ADD CONSTRAINT l_label_url_example_pkey PRIMARY KEY (id);
ALTER TABLE l_label_work_example ADD CONSTRAINT l_label_work_example_pkey PRIMARY KEY (id);
ALTER TABLE l_recording_recording_example ADD CONSTRAINT l_recording_recording_example_pkey PRIMARY KEY (id);
ALTER TABLE l_recording_release_example ADD CONSTRAINT l_recording_release_example_pkey PRIMARY KEY (id);
ALTER TABLE l_recording_release_group_example ADD CONSTRAINT l_recording_release_group_example_pkey PRIMARY KEY (id);
ALTER TABLE l_recording_url_example ADD CONSTRAINT l_recording_url_example_pkey PRIMARY KEY (id);
ALTER TABLE l_recording_work_example ADD CONSTRAINT l_recording_work_example_pkey PRIMARY KEY (id);
ALTER TABLE l_release_group_release_group_example ADD CONSTRAINT l_release_group_release_group_example_pkey PRIMARY KEY (id);
ALTER TABLE l_release_group_url_example ADD CONSTRAINT l_release_group_url_example_pkey PRIMARY KEY (id);
ALTER TABLE l_release_group_work_example ADD CONSTRAINT l_release_group_work_example_pkey PRIMARY KEY (id);
ALTER TABLE l_release_release_example ADD CONSTRAINT l_release_release_example_pkey PRIMARY KEY (id);
ALTER TABLE l_release_release_group_example ADD CONSTRAINT l_release_release_group_example_pkey PRIMARY KEY (id);
ALTER TABLE l_release_url_example ADD CONSTRAINT l_release_url_example_pkey PRIMARY KEY (id);
ALTER TABLE l_release_work_example ADD CONSTRAINT l_release_work_example_pkey PRIMARY KEY (id);
ALTER TABLE l_url_url_example ADD CONSTRAINT l_url_url_example_pkey PRIMARY KEY (id);
ALTER TABLE l_url_work_example ADD CONSTRAINT l_url_work_example_pkey PRIMARY KEY (id);
ALTER TABLE l_work_work_example ADD CONSTRAINT l_work_work_example_pkey PRIMARY KEY (id);
ALTER TABLE link_type_documentation ADD CONSTRAINT link_type_documentation_pkey PRIMARY KEY (id);
