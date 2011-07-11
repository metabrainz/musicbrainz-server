BEGIN;

SELECT edit_artist.edit, edit_artist.artist, edit.status
INTO tmp_edit_artist
FROM edit_artist
JOIN edit ON edit_artist.edit = edit.id;

DROP TABLE edit_artist;
ALTER TABLE tmp_edit_artist RENAME TO edit_artist;

ALTER TABLE edit_artist ADD CONSTRAINT edit_artist_pkey PRIMARY KEY (edit, artist);
CREATE INDEX edit_artist_idx ON edit_artist (artist);
CREATE INDEX edit_artist_idx_status ON edit_artist (status);


SELECT edit_label.edit, edit_label.label, edit.status
INTO tmp_edit_label
FROM edit_label
JOIN edit ON edit_label.edit = edit.id;

DROP TABLE edit_label;
ALTER TABLE tmp_edit_label RENAME TO edit_label;

ALTER TABLE edit_label ADD CONSTRAINT edit_label_pkey PRIMARY KEY (edit, label);
CREATE INDEX edit_label_idx ON edit_label (label);
CREATE INDEX edit_label_idx_status ON edit_label (status);

ALTER TABLE edit_artist
   ADD CONSTRAINT edit_artist_fk_edit
   FOREIGN KEY (edit)
   REFERENCES edit(id);

ALTER TABLE edit_artist
   ADD CONSTRAINT edit_artist_fk_artist
   FOREIGN KEY (artist)
   REFERENCES artist(id)
   ON DELETE CASCADE;

ALTER TABLE edit_label
   ADD CONSTRAINT edit_label_fk_edit
   FOREIGN KEY (edit)
   REFERENCES edit(id);

ALTER TABLE edit_label
   ADD CONSTRAINT edit_label_fk_label
   FOREIGN KEY (label)
   REFERENCES label(id)
   ON DELETE CASCADE;

CREATE OR REPLACE FUNCTION a_upd_edit() RETURNS trigger AS $$
BEGIN
    IF NEW.status != OLD.status THEN
       UPDATE edit_artist SET status = NEW.status WHERE edit = NEW.id;
       UPDATE edit_label  SET status = NEW.status WHERE edit = NEW.id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER a_upd_edit AFTER UPDATE ON edit
    FOR EACH ROW EXECUTE PROCEDURE a_upd_edit();

COMMIT;
