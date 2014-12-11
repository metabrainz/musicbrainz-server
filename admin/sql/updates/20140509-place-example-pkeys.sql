-- commented lines are created by other scripts running this schema change
ALTER TABLE documentation.l_area_place_example ADD CONSTRAINT l_area_place_example_pkey PRIMARY KEY (id);
ALTER TABLE documentation.l_artist_place_example ADD CONSTRAINT l_artist_place_example_pkey PRIMARY KEY (id);
ALTER TABLE documentation.l_label_place_example ADD CONSTRAINT l_label_place_example_pkey PRIMARY KEY (id);
ALTER TABLE documentation.l_place_place_example ADD CONSTRAINT l_place_place_example_pkey PRIMARY KEY (id);
ALTER TABLE documentation.l_place_recording_example ADD CONSTRAINT l_place_recording_example_pkey PRIMARY KEY (id);
ALTER TABLE documentation.l_place_release_example ADD CONSTRAINT l_place_release_example_pkey PRIMARY KEY (id);
ALTER TABLE documentation.l_place_release_group_example ADD CONSTRAINT l_place_release_group_example_pkey PRIMARY KEY (id);
ALTER TABLE documentation.l_place_url_example ADD CONSTRAINT l_place_url_example_pkey PRIMARY KEY (id);
ALTER TABLE documentation.l_place_work_example ADD CONSTRAINT l_place_work_example_pkey PRIMARY KEY (id);
