\set ON_ERROR_STOP 1
BEGIN;

CREATE TABLE area_tag (
    area                INTEGER NOT NULL,
    tag                 INTEGER NOT NULL,
    count               INTEGER NOT NULL,
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE area_tag_raw (
    area                INTEGER NOT NULL,
    editor              INTEGER NOT NULL,
    tag                 INTEGER NOT NULL
);

CREATE TABLE instrument_tag (
    instrument          INTEGER NOT NULL,
    tag                 INTEGER NOT NULL,
    count               INTEGER NOT NULL,
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE instrument_tag_raw (
    instrument          INTEGER NOT NULL,
    editor              INTEGER NOT NULL,
    tag                 INTEGER NOT NULL
);

CREATE TABLE series_tag (
    series              INTEGER NOT NULL,
    tag                 INTEGER NOT NULL,
    count               INTEGER NOT NULL,
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE series_tag_raw (
    series              INTEGER NOT NULL,
    editor              INTEGER NOT NULL,
    tag                 INTEGER NOT NULL
);

ALTER TABLE area_tag ADD CONSTRAINT area_tag_pkey PRIMARY KEY (area, tag);
ALTER TABLE area_tag_raw ADD CONSTRAINT area_tag_raw_pkey PRIMARY KEY (area, editor, tag);

ALTER TABLE instrument_tag ADD CONSTRAINT instrument_tag_pkey PRIMARY KEY (instrument, tag);
ALTER TABLE instrument_tag_raw ADD CONSTRAINT instrument_tag_raw_pkey PRIMARY KEY (instrument, editor, tag);

ALTER TABLE series_tag ADD CONSTRAINT series_tag_pkey PRIMARY KEY (series, tag);
ALTER TABLE series_tag_raw ADD CONSTRAINT series_tag_raw_pkey PRIMARY KEY (series, editor, tag);

CREATE INDEX area_tag_idx_tag ON area_tag (tag);

CREATE INDEX area_tag_raw_idx_area ON area_tag_raw (area);
CREATE INDEX area_tag_raw_idx_tag ON area_tag_raw (tag);
CREATE INDEX area_tag_raw_idx_editor ON area_tag_raw (editor);

CREATE INDEX instrument_tag_idx_tag ON instrument_tag (tag);

CREATE INDEX instrument_tag_raw_idx_instrument ON instrument_tag_raw (instrument);
CREATE INDEX instrument_tag_raw_idx_tag ON instrument_tag_raw (tag);
CREATE INDEX instrument_tag_raw_idx_editor ON instrument_tag_raw (editor);

CREATE INDEX series_tag_idx_tag ON series_tag (tag);

CREATE INDEX series_tag_raw_idx_series ON series_tag_raw (series);
CREATE INDEX series_tag_raw_idx_tag ON series_tag_raw (tag);
CREATE INDEX series_tag_raw_idx_editor ON series_tag_raw (editor);

COMMIT;
