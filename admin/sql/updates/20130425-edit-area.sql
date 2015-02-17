BEGIN;

CREATE TABLE edit_area
(
    edit                INTEGER NOT NULL, -- PK, references edit.id
    area                INTEGER NOT NULL  -- PK, references area.id CASCADE
);

ALTER TABLE edit_area ADD CONSTRAINT edit_area_pkey PRIMARY KEY (edit, area);
CREATE INDEX edit_area_idx ON edit_area (area);

COMMIT;
