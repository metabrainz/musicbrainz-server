\set ON_ERROR_STOP 1
BEGIN;

-- Generate new tables
------------------------
-- artist
CREATE TABLE artist2013 AS
  SELECT artist.id, artist.gid, name.name AS name, sort_name.name AS sort_name,
         begin_date_year, begin_date_month, begin_date_day,
         end_date_year, end_date_month, end_date_day,
         type, area, gender, comment, edits_pending, last_updated, ended,
         begin_area, end_area
    FROM artist
    JOIN artist_name name ON artist.name = name.id
    JOIN artist_name sort_name ON artist.sort_name = sort_name.id;

ALTER TABLE artist2013
  ADD CONSTRAINT artist_edits_pending_check CHECK (edits_pending >= 0),
  ADD CONSTRAINT artist_ended_check CHECK (
        (
          (end_date_year IS NOT NULL OR
           end_date_month IS NOT NULL OR
           end_date_day IS NOT NULL) AND
          ended = TRUE
        ) OR (
          (end_date_year IS NULL AND
           end_date_month IS NULL AND
           end_date_day IS NULL)
        )
      ),
  ALTER COLUMN id SET DEFAULT nextval('artist_id_seq'),
  ALTER COLUMN id SET NOT NULL,
  ALTER COLUMN gid SET NOT NULL,
  ALTER COLUMN name SET NOT NULL,
  ALTER COLUMN sort_name SET NOT NULL,
  ALTER COLUMN comment SET DEFAULT '',
  ALTER COLUMN comment SET NOT NULL,
  ALTER COLUMN edits_pending SET DEFAULT 0,
  ALTER COLUMN edits_pending SET NOT NULL,
  ALTER COLUMN last_updated SET DEFAULT NOW(),
  ALTER COLUMN ended SET DEFAULT FALSE,
  ALTER COLUMN ended SET NOT NULL;

ALTER SEQUENCE artist_id_seq OWNED BY artist2013.id;

-- artist_alias
CREATE TABLE artist_alias2013 AS
  SELECT artist_alias.id, artist_alias.artist, name.name AS name,
         artist_alias.locale, artist_alias.edits_pending,
         artist_alias.last_updated, artist_alias.type,
         sort_name.name AS sort_name,
         begin_date_year, begin_date_month, begin_date_day,
         end_date_year, end_date_month, end_date_day,
         primary_for_locale
    FROM artist_alias
    JOIN artist_name name ON artist_alias.name = name.id
    JOIN artist_name sort_name ON artist_alias.sort_name = sort_name.id;

ALTER TABLE artist_alias2013
  ADD CONSTRAINT artist_alias_edits_pending_check CHECK (edits_pending >= 0),
  ADD CONSTRAINT primary_check CHECK ((locale IS NULL AND primary_for_locale IS FALSE) OR (locale IS NOT NULL)),
  ADD CONSTRAINT search_hints_are_empty CHECK (
      (type <> 3) OR (
        type = 3 AND sort_name = name AND
        begin_date_year IS NULL AND begin_date_month IS NULL AND begin_date_day IS NULL AND
        end_date_year IS NULL AND end_date_month IS NULL AND end_date_day IS NULL AND
        primary_for_locale IS FALSE AND locale IS NULL
      )),
  ALTER COLUMN id SET DEFAULT nextval('artist_alias_id_seq'),
  ALTER COLUMN id SET NOT NULL,
  ALTER COLUMN artist SET NOT NULL,
  ALTER COLUMN name SET NOT NULL,
  ALTER COLUMN sort_name SET NOT NULL,
  ALTER COLUMN edits_pending SET DEFAULT 0,
  ALTER COLUMN edits_pending SET NOT NULL,
  ALTER COLUMN last_updated SET DEFAULT NOW(),
  ALTER COLUMN primary_for_locale SET DEFAULT FALSE,
  ALTER COLUMN primary_for_locale SET NOT NULL;

ALTER SEQUENCE artist_alias_id_seq OWNED BY artist_alias2013.id;

-- artist_credit
CREATE TABLE artist_credit2013 AS
  SELECT artist_credit.id, name.name AS name, artist_count, ref_count, artist_credit.created
    FROM artist_credit
    JOIN artist_name name ON artist_credit.name = name.id;

ALTER TABLE artist_credit2013
  ALTER COLUMN id SET DEFAULT nextval('artist_credit_id_seq'),
  ALTER COLUMN id SET NOT NULL,
  ALTER COLUMN name SET NOT NULL,
  ALTER COLUMN artist_count SET NOT NULL,
  ALTER COLUMN ref_count SET DEFAULT 0,
  ALTER COLUMN created SET DEFAULT NOW();

ALTER SEQUENCE artist_credit_id_seq OWNED BY artist_credit2013.id;

-- artist_credit_name
CREATE TABLE artist_credit_name2013 AS
  SELECT artist_credit_name.artist_credit, artist_credit_name.position,
         artist_credit_name.artist, name.name AS name, join_phrase
    FROM artist_credit_name
    JOIN artist_name name ON artist_credit_name.name = name.id;

ALTER TABLE artist_credit_name2013
  ALTER COLUMN artist_credit SET NOT NULL,
  ALTER COLUMN position SET NOT NULL,
  ALTER COLUMN artist SET NOT NULL,
  ALTER COLUMN name SET NOT NULL,
  ALTER COLUMN join_phrase SET DEFAULT '',
  ALTER COLUMN join_phrase SET NOT NULL;

-- label
CREATE TABLE label2013 AS
  SELECT label.id, label.gid, name.name AS name, sort_name.name AS sort_name,
         begin_date_year, begin_date_month, begin_date_day,
         end_date_year, end_date_month, end_date_day,
         label_code, type, area, comment, edits_pending, last_updated, ended
    FROM label
    JOIN label_name name ON label.name = name.id
    JOIN label_name sort_name ON label.sort_name = sort_name.id;

ALTER TABLE label2013
  ADD CONSTRAINT label_edits_pending_check CHECK (edits_pending >= 0),
  ADD CONSTRAINT label_ended_check CHECK (
        (
          (end_date_year IS NOT NULL OR
           end_date_month IS NOT NULL OR
           end_date_day IS NOT NULL) AND
          ended = TRUE
        ) OR (
          (end_date_year IS NULL AND
           end_date_month IS NULL AND
           end_date_day IS NULL)
        )
      ),
  ADD CONSTRAINT label_label_code_check CHECK (
      label_code > 0 AND label_code < 100000
  ),
  ALTER COLUMN id SET DEFAULT nextval('label_id_seq'),
  ALTER COLUMN id SET NOT NULL,
  ALTER COLUMN gid SET NOT NULL,
  ALTER COLUMN name SET NOT NULL,
  ALTER COLUMN sort_name SET NOT NULL,
  ALTER COLUMN comment SET DEFAULT '',
  ALTER COLUMN comment SET NOT NULL,
  ALTER COLUMN edits_pending SET DEFAULT 0,
  ALTER COLUMN edits_pending SET NOT NULL,
  ALTER COLUMN last_updated SET DEFAULT NOW(),
  ALTER COLUMN ended SET DEFAULT FALSE,
  ALTER COLUMN ended SET NOT NULL;

ALTER SEQUENCE label_id_seq OWNED BY label2013.id;

-- label_alias
CREATE TABLE label_alias2013 AS
  SELECT label_alias.id, label_alias.label, name.name AS name,
         label_alias.locale, label_alias.edits_pending,
         label_alias.last_updated, label_alias.type,
         sort_name.name AS sort_name,
         begin_date_year, begin_date_month, begin_date_day,
         end_date_year, end_date_month, end_date_day,
         primary_for_locale
    FROM label_alias
    JOIN label_name name ON label_alias.name = name.id
    JOIN label_name sort_name ON label_alias.sort_name = sort_name.id;

ALTER TABLE label_alias2013
  ADD CONSTRAINT label_alias_edits_pending_check CHECK (edits_pending >= 0),
  ADD CONSTRAINT primary_check CHECK ((locale IS NULL AND primary_for_locale IS FALSE) OR (locale IS NOT NULL)),
  ADD CONSTRAINT search_hints_are_empty CHECK (
      (type <> 2) OR (
        type = 2 AND sort_name = name AND
        begin_date_year IS NULL AND begin_date_month IS NULL AND begin_date_day IS NULL AND
        end_date_year IS NULL AND end_date_month IS NULL AND end_date_day IS NULL AND
        primary_for_locale IS FALSE AND locale IS NULL
      )),
  ALTER COLUMN id SET DEFAULT nextval('label_alias_id_seq'),
  ALTER COLUMN id SET NOT NULL,
  ALTER COLUMN label SET NOT NULL,
  ALTER COLUMN name SET NOT NULL,
  ALTER COLUMN sort_name SET NOT NULL,
  ALTER COLUMN edits_pending SET DEFAULT 0,
  ALTER COLUMN edits_pending SET NOT NULL,
  ALTER COLUMN last_updated SET DEFAULT NOW(),
  ALTER COLUMN primary_for_locale SET DEFAULT FALSE,
  ALTER COLUMN primary_for_locale SET NOT NULL;

ALTER SEQUENCE label_alias_id_seq OWNED BY label_alias2013.id;

-- release
CREATE TABLE release2013 AS
  SELECT release.id, release.gid, name.name, artist_credit,
         release_group, status, packaging, language, script,
         barcode, comment, edits_pending, quality, last_updated
    FROM release
    JOIN release_name name ON release.name = name.id;

ALTER TABLE release2013
  ADD CONSTRAINT release_edits_pending_check CHECK (edits_pending >= 0),
  ALTER COLUMN id SET DEFAULT nextval('release_id_seq'),
  ALTER COLUMN id SET NOT NULL,
  ALTER COLUMN gid SET NOT NULL,
  ALTER COLUMN artist_credit SET NOT NULL,
  ALTER COLUMN release_group SET NOT NULL,
  ALTER COLUMN name SET NOT NULL,
  ALTER COLUMN comment SET DEFAULT '',
  ALTER COLUMN comment SET NOT NULL,
  ALTER COLUMN edits_pending SET DEFAULT 0,
  ALTER COLUMN edits_pending SET NOT NULL,
  ALTER COLUMN quality SET DEFAULT -1,
  ALTER COLUMN quality SET NOT NULL,
  ALTER COLUMN last_updated SET DEFAULT NOW();

ALTER SEQUENCE release_id_seq OWNED BY release2013.id;

-- release_group
CREATE TABLE release_group2013 AS
  SELECT rg.id, rg.gid, name.name, artist_credit,
         type, comment, edits_pending, last_updated
    FROM release_group rg
    JOIN release_name name ON rg.name = name.id;

ALTER TABLE release_group2013
  ADD CONSTRAINT release_group_edits_pending_check CHECK (edits_pending >= 0),
  ALTER COLUMN id SET DEFAULT nextval('release_group_id_seq'),
  ALTER COLUMN id SET NOT NULL,
  ALTER COLUMN gid SET NOT NULL,
  ALTER COLUMN artist_credit SET NOT NULL,
  ALTER COLUMN name SET NOT NULL,
  ALTER COLUMN comment SET DEFAULT '',
  ALTER COLUMN comment SET NOT NULL,
  ALTER COLUMN edits_pending SET DEFAULT 0,
  ALTER COLUMN edits_pending SET NOT NULL,
  ALTER COLUMN last_updated SET DEFAULT NOW();

ALTER SEQUENCE release_group_id_seq OWNED BY release_group2013.id;

-- recording
CREATE TABLE recording2013 AS
  SELECT recording.id, recording.gid, name.name, artist_credit,
         length, comment, edits_pending, last_updated, FALSE as video
    FROM recording
    JOIN track_name name ON recording.name = name.id;

ALTER TABLE recording2013
  ADD CONSTRAINT recording_edits_pending_check CHECK (edits_pending >= 0),
  ADD CONSTRAINT recording_length_check CHECK (length IS NULL OR length > 0),
  ALTER COLUMN id SET DEFAULT nextval('recording_id_seq'),
  ALTER COLUMN id SET NOT NULL,
  ALTER COLUMN gid SET NOT NULL,
  ALTER COLUMN artist_credit SET NOT NULL,
  ALTER COLUMN name SET NOT NULL,
  ALTER COLUMN comment SET DEFAULT '',
  ALTER COLUMN comment SET NOT NULL,
  ALTER COLUMN edits_pending SET DEFAULT 0,
  ALTER COLUMN edits_pending SET NOT NULL,
  ALTER COLUMN last_updated SET DEFAULT NOW(),
  ALTER COLUMN video SET DEFAULT FALSE,
  ALTER COLUMN video SET NOT NULL;

ALTER SEQUENCE recording_id_seq OWNED BY recording2013.id;

-- track
CREATE TABLE track2013 AS
  SELECT track.id, track.gid, recording, medium, position,
         number, name.name, artist_credit, length,
         edits_pending, last_updated
    FROM track
    JOIN track_name name ON track.name = name.id;

ALTER TABLE track2013
  ADD CONSTRAINT track_edits_pending_check CHECK (edits_pending >= 0),
  ADD CONSTRAINT track_length_check CHECK (length IS NULL OR length > 0),
  ALTER COLUMN id SET DEFAULT nextval('track_id_seq'),
  ALTER COLUMN id SET NOT NULL,
  ALTER COLUMN gid SET NOT NULL,
  ALTER COLUMN recording SET NOT NULL,
  ALTER COLUMN medium SET NOT NULL,
  ALTER COLUMN position SET NOT NULL,
  ALTER COLUMN number SET NOT NULL,
  ALTER COLUMN name SET NOT NULL,
  ALTER COLUMN artist_credit SET NOT NULL,
  ALTER COLUMN edits_pending SET DEFAULT 0,
  ALTER COLUMN edits_pending SET NOT NULL,
  ALTER COLUMN last_updated SET DEFAULT NOW();

ALTER SEQUENCE track_id_seq OWNED BY track2013.id;

-- work
CREATE TABLE work2013 AS
  SELECT work.id, work.gid, name.name AS name,
         type, comment, edits_pending, last_updated, language
    FROM work
    JOIN work_name name ON work.name = name.id;

ALTER TABLE work2013
  ADD CONSTRAINT work_edits_pending_check CHECK (edits_pending >= 0),
  ALTER COLUMN id SET DEFAULT nextval('work_id_seq'),
  ALTER COLUMN id SET NOT NULL,
  ALTER COLUMN gid SET NOT NULL,
  ALTER COLUMN name SET NOT NULL,
  ALTER COLUMN comment SET DEFAULT '',
  ALTER COLUMN comment SET NOT NULL,
  ALTER COLUMN edits_pending SET DEFAULT 0,
  ALTER COLUMN edits_pending SET NOT NULL,
  ALTER COLUMN last_updated SET DEFAULT NOW();

ALTER SEQUENCE work_id_seq OWNED BY work2013.id;

-- work_alias
CREATE TABLE work_alias2013 AS
  SELECT work_alias.id, work_alias.work, name.name AS name,
         work_alias.locale, work_alias.edits_pending,
         work_alias.last_updated, work_alias.type,
         sort_name.name AS sort_name,
         begin_date_year, begin_date_month, begin_date_day,
         end_date_year, end_date_month, end_date_day,
         primary_for_locale
    FROM work_alias
    JOIN work_name name ON work_alias.name = name.id
    JOIN work_name sort_name ON work_alias.sort_name = sort_name.id;

ALTER TABLE work_alias2013
  ADD CONSTRAINT work_alias_edits_pending_check CHECK (edits_pending >= 0),
  ADD CONSTRAINT primary_check CHECK ((locale IS NULL AND primary_for_locale IS FALSE) OR (locale IS NOT NULL)),
  ADD CONSTRAINT search_hints_are_empty CHECK (
      (type <> 2) OR (
        type = 2 AND sort_name = name AND
        begin_date_year IS NULL AND begin_date_month IS NULL AND begin_date_day IS NULL AND
        end_date_year IS NULL AND end_date_month IS NULL AND end_date_day IS NULL AND
        primary_for_locale IS FALSE AND locale IS NULL
      )),
  ALTER COLUMN id SET DEFAULT nextval('work_alias_id_seq'),
  ALTER COLUMN id SET NOT NULL,
  ALTER COLUMN work SET NOT NULL,
  ALTER COLUMN name SET NOT NULL,
  ALTER COLUMN sort_name SET NOT NULL,
  ALTER COLUMN edits_pending SET DEFAULT 0,
  ALTER COLUMN edits_pending SET NOT NULL,
  ALTER COLUMN last_updated SET DEFAULT NOW(),
  ALTER COLUMN primary_for_locale SET DEFAULT FALSE,
  ALTER COLUMN primary_for_locale SET NOT NULL;

ALTER SEQUENCE work_alias_id_seq OWNED BY work_alias2013.id;

-- Some slaves don't have these tables, so we'll just create empty stubs for now
CREATE TABLE IF NOT EXISTS artist_deletion
(
    gid UUID,
    last_known_name INT,
    last_known_comment TEXT,
    deleted_at timestamptz
);

CREATE TABLE IF NOT EXISTS label_deletion
(
    gid UUID,
    last_known_name INT,
    last_known_comment TEXT,
    deleted_at timestamptz
);

-- artist_deletion
CREATE TABLE artist_deletion2013 AS
  SELECT artist_deletion.gid, name.name AS last_known_name,
         artist_deletion.last_known_comment, deleted_at
    FROM artist_deletion
    JOIN artist_name name ON artist_deletion.last_known_name = name.id;

ALTER TABLE artist_deletion2013
  ALTER COLUMN gid SET NOT NULL,
  ALTER COLUMN last_known_name SET NOT NULL,
  ALTER COLUMN last_known_comment SET NOT NULL,
  ALTER COLUMN deleted_at SET DEFAULT now(),
  ALTER COLUMN deleted_at SET NOT NULL;

-- label_deletion
CREATE TABLE label_deletion2013 AS
  SELECT label_deletion.gid, name.name AS last_known_name,
         label_deletion.last_known_comment, deleted_at
    FROM label_deletion
    JOIN label_name name ON label_deletion.last_known_name = name.id;

ALTER TABLE label_deletion2013
  ALTER COLUMN gid SET NOT NULL,
  ALTER COLUMN last_known_name SET NOT NULL,
  ALTER COLUMN last_known_comment SET NOT NULL,
  ALTER COLUMN deleted_at SET DEFAULT now(),
  ALTER COLUMN deleted_at SET NOT NULL;

-- Drop FKs
------------------------
ALTER TABLE artist_alias
  DROP CONSTRAINT IF EXISTS artist_alias_fk_artist;
ALTER TABLE artist_annotation
  DROP CONSTRAINT IF EXISTS artist_annotation_fk_artist;
ALTER TABLE artist_ipi
  DROP CONSTRAINT IF EXISTS artist_ipi_fk_artist;
ALTER TABLE artist_isni
  DROP CONSTRAINT IF EXISTS artist_isni_fk_artist;
ALTER TABLE artist_meta
  DROP CONSTRAINT IF EXISTS artist_meta_fk_id;
ALTER TABLE artist_tag
  DROP CONSTRAINT IF EXISTS artist_tag_fk_artist;
ALTER TABLE artist_rating_raw
  DROP CONSTRAINT IF EXISTS artist_rating_raw_fk_artist;
ALTER TABLE artist_tag_raw
  DROP CONSTRAINT IF EXISTS artist_tag_raw_fk_artist;
ALTER TABLE artist_credit_name
  DROP CONSTRAINT IF EXISTS artist_credit_name_fk_artist;
ALTER TABLE artist_gid_redirect
  DROP CONSTRAINT IF EXISTS artist_gid_redirect_fk_new_id;
ALTER TABLE edit_artist
  DROP CONSTRAINT IF EXISTS edit_artist_fk_artist;
ALTER TABLE editor_subscribe_artist
  DROP CONSTRAINT IF EXISTS editor_subscribe_artist_fk_artist;
ALTER TABLE editor_watch_artist
  DROP CONSTRAINT IF EXISTS editor_watch_artist_fk_artist;

ALTER TABLE l_area_artist
  DROP CONSTRAINT IF EXISTS l_area_artist_fk_entity1;
ALTER TABLE l_artist_artist
  DROP CONSTRAINT IF EXISTS l_artist_artist_fk_entity0;
ALTER TABLE l_artist_artist
  DROP CONSTRAINT IF EXISTS l_artist_artist_fk_entity1;
ALTER TABLE l_artist_label
  DROP CONSTRAINT IF EXISTS l_artist_label_fk_entity0;
ALTER TABLE l_artist_recording
  DROP CONSTRAINT IF EXISTS l_artist_recording_fk_entity0;
ALTER TABLE l_artist_release
  DROP CONSTRAINT IF EXISTS l_artist_release_fk_entity0;
ALTER TABLE l_artist_release_group
  DROP CONSTRAINT IF EXISTS l_artist_release_group_fk_entity0;
ALTER TABLE l_artist_url
  DROP CONSTRAINT IF EXISTS l_artist_url_fk_entity0;
ALTER TABLE l_artist_work
  DROP CONSTRAINT IF EXISTS l_artist_work_fk_entity0;

ALTER TABLE artist_credit_name
  DROP CONSTRAINT IF EXISTS artist_credit_name_fk_artist_credit;
ALTER TABLE recording
  DROP CONSTRAINT IF EXISTS recording_fk_artist_credit;
ALTER TABLE track
  DROP CONSTRAINT IF EXISTS track_fk_artist_credit;
ALTER TABLE release
  DROP CONSTRAINT IF EXISTS release_fk_artist_credit;
ALTER TABLE release_group
  DROP CONSTRAINT IF EXISTS release_group_fk_artist_credit;

ALTER TABLE label_alias
  DROP CONSTRAINT IF EXISTS label_alias_fk_label;
ALTER TABLE label_annotation
  DROP CONSTRAINT IF EXISTS label_annotation_fk_label;
ALTER TABLE label_ipi
  DROP CONSTRAINT IF EXISTS label_ipi_fk_label;
ALTER TABLE label_isni
  DROP CONSTRAINT IF EXISTS label_isni_fk_label;
ALTER TABLE label_meta
  DROP CONSTRAINT IF EXISTS label_meta_fk_id;
ALTER TABLE label_tag
  DROP CONSTRAINT IF EXISTS label_tag_fk_label;
ALTER TABLE label_rating_raw
  DROP CONSTRAINT IF EXISTS label_rating_raw_fk_label;
ALTER TABLE label_tag_raw
  DROP CONSTRAINT IF EXISTS label_tag_raw_fk_label;
ALTER TABLE label_gid_redirect
  DROP CONSTRAINT IF EXISTS label_gid_redirect_fk_new_id;
ALTER TABLE edit_label
  DROP CONSTRAINT IF EXISTS edit_label_fk_label;
ALTER TABLE editor_subscribe_label
  DROP CONSTRAINT IF EXISTS editor_subscribe_label_fk_label;
ALTER TABLE release_label
  DROP CONSTRAINT IF EXISTS release_label_fk_label;

ALTER TABLE l_area_label
  DROP CONSTRAINT IF EXISTS l_area_label_fk_entity1;
ALTER TABLE l_artist_label
  DROP CONSTRAINT IF EXISTS l_artist_label_fk_entity1;
ALTER TABLE l_label_label
  DROP CONSTRAINT IF EXISTS l_label_label_fk_entity1;
ALTER TABLE l_label_label
  DROP CONSTRAINT IF EXISTS l_label_label_fk_entity0;
ALTER TABLE l_label_recording
  DROP CONSTRAINT IF EXISTS l_label_recording_fk_entity0;
ALTER TABLE l_label_release
  DROP CONSTRAINT IF EXISTS l_label_release_fk_entity0;
ALTER TABLE l_label_release_group
  DROP CONSTRAINT IF EXISTS l_label_release_group_fk_entity0;
ALTER TABLE l_label_url
  DROP CONSTRAINT IF EXISTS l_label_url_fk_entity0;
ALTER TABLE l_label_work
  DROP CONSTRAINT IF EXISTS l_label_work_fk_entity0;

ALTER TABLE release_annotation
  DROP CONSTRAINT IF EXISTS release_annotation_fk_release;
ALTER TABLE release_meta
  DROP CONSTRAINT IF EXISTS release_meta_fk_id;
ALTER TABLE release_tag
  DROP CONSTRAINT IF EXISTS release_tag_fk_release;
ALTER TABLE release_tag_raw
  DROP CONSTRAINT IF EXISTS release_tag_raw_fk_release;
ALTER TABLE release_country
  DROP CONSTRAINT IF EXISTS release_country_fk_release;
ALTER TABLE release_unknown_country
  DROP CONSTRAINT IF EXISTS release_unknown_country_fk_release;
ALTER TABLE release_label
  DROP CONSTRAINT IF EXISTS release_label_fk_release;
ALTER TABLE release_gid_redirect
  DROP CONSTRAINT IF EXISTS release_gid_redirect_fk_new_id;
ALTER TABLE medium
  DROP CONSTRAINT IF EXISTS medium_fk_release;
ALTER TABLE edit_release
  DROP CONSTRAINT IF EXISTS edit_release_fk_release;
ALTER TABLE editor_collection_release
  DROP CONSTRAINT IF EXISTS editor_collection_release_fk_release;
ALTER TABLE release_coverart
  DROP CONSTRAINT IF EXISTS release_coverart_fk_id;
ALTER TABLE cover_art_archive.cover_art
  DROP CONSTRAINT IF EXISTS cover_art_fk_release;
ALTER TABLE cover_art_archive.release_group_cover_art
  DROP CONSTRAINT IF EXISTS release_group_cover_art_fk_release;

ALTER TABLE l_area_release
  DROP CONSTRAINT IF EXISTS l_area_release_fk_entity1;
ALTER TABLE l_artist_release
  DROP CONSTRAINT IF EXISTS l_artist_release_fk_entity1;
ALTER TABLE l_label_release
  DROP CONSTRAINT IF EXISTS l_label_release_fk_entity1;
ALTER TABLE l_recording_release
  DROP CONSTRAINT IF EXISTS l_recording_release_fk_entity1;
ALTER TABLE l_release_release
  DROP CONSTRAINT IF EXISTS l_release_release_fk_entity1;
ALTER TABLE l_release_release
  DROP CONSTRAINT IF EXISTS l_release_release_fk_entity0;
ALTER TABLE l_release_release_group
  DROP CONSTRAINT IF EXISTS l_release_release_group_fk_entity0;
ALTER TABLE l_release_url
  DROP CONSTRAINT IF EXISTS l_release_url_fk_entity0;
ALTER TABLE l_release_work
  DROP CONSTRAINT IF EXISTS l_release_work_fk_entity0;

ALTER TABLE release_group_annotation
  DROP CONSTRAINT IF EXISTS release_group_annotation_fk_release_group;
ALTER TABLE release_group_meta
  DROP CONSTRAINT IF EXISTS release_group_meta_fk_id;
ALTER TABLE release_group_tag
  DROP CONSTRAINT IF EXISTS release_group_tag_fk_release_group;
ALTER TABLE release_group_rating_raw
  DROP CONSTRAINT IF EXISTS release_group_rating_raw_fk_release_group;
ALTER TABLE release_group_tag_raw
  DROP CONSTRAINT IF EXISTS release_group_tag_raw_fk_release_group;
ALTER TABLE release_group_gid_redirect
  DROP CONSTRAINT IF EXISTS release_group_gid_redirect_fk_new_id;
ALTER TABLE edit_release_group
  DROP CONSTRAINT IF EXISTS edit_release_group_fk_release_group;
ALTER TABLE release
  DROP CONSTRAINT IF EXISTS release_fk_release_group;
ALTER TABLE release_group_secondary_type_join
  DROP CONSTRAINT IF EXISTS release_group_secondary_type_join_fk_release_group;
ALTER TABLE cover_art_archive.release_group_cover_art
  DROP CONSTRAINT IF EXISTS release_group_cover_art_fk_release_group;

ALTER TABLE l_area_release_group
  DROP CONSTRAINT IF EXISTS l_area_release_group_fk_entity1;
ALTER TABLE l_artist_release_group
  DROP CONSTRAINT IF EXISTS l_artist_release_group_fk_entity1;
ALTER TABLE l_label_release_group
  DROP CONSTRAINT IF EXISTS l_label_release_group_fk_entity1;
ALTER TABLE l_recording_release_group
  DROP CONSTRAINT IF EXISTS l_recording_release_group_fk_entity1;
ALTER TABLE l_release_release_group
  DROP CONSTRAINT IF EXISTS l_release_release_group_fk_entity1;
ALTER TABLE l_release_group_release_group
  DROP CONSTRAINT IF EXISTS l_release_group_release_group_fk_entity1;
ALTER TABLE l_release_group_release_group
  DROP CONSTRAINT IF EXISTS l_release_group_release_group_fk_entity0;
ALTER TABLE l_release_group_url
  DROP CONSTRAINT IF EXISTS l_release_group_url_fk_entity0;
ALTER TABLE l_release_group_work
  DROP CONSTRAINT IF EXISTS l_release_group_work_fk_entity0;

ALTER TABLE edit_recording
  DROP CONSTRAINT IF EXISTS edit_recording_fk_recording;
ALTER TABLE isrc
  DROP CONSTRAINT IF EXISTS isrc_fk_recording;
ALTER TABLE recording_annotation
  DROP CONSTRAINT IF EXISTS recording_annotation_fk_recording;
ALTER TABLE recording_meta
  DROP CONSTRAINT IF EXISTS recording_meta_fk_id;
ALTER TABLE recording_tag
  DROP CONSTRAINT IF EXISTS recording_tag_fk_recording;
ALTER TABLE recording_rating_raw
  DROP CONSTRAINT IF EXISTS recording_rating_raw_fk_recording;
ALTER TABLE recording_tag_raw
  DROP CONSTRAINT IF EXISTS recording_tag_raw_fk_recording;
ALTER TABLE track
  DROP CONSTRAINT IF EXISTS track_fk_recording;
ALTER TABLE recording_gid_redirect
  DROP CONSTRAINT IF EXISTS recording_gid_redirect_fk_new_id;

ALTER TABLE l_area_recording
  DROP CONSTRAINT IF EXISTS l_area_recording_fk_entity1;
ALTER TABLE l_artist_recording
  DROP CONSTRAINT IF EXISTS l_artist_recording_fk_entity1;
ALTER TABLE l_label_recording
  DROP CONSTRAINT IF EXISTS l_label_recording_fk_entity1;
ALTER TABLE l_recording_recording
  DROP CONSTRAINT IF EXISTS l_recording_recording_fk_entity1;
ALTER TABLE l_recording_recording
  DROP CONSTRAINT IF EXISTS l_recording_recording_fk_entity0;
ALTER TABLE l_recording_release_group
  DROP CONSTRAINT IF EXISTS l_recording_release_group_fk_entity0;
ALTER TABLE l_recording_release
  DROP CONSTRAINT IF EXISTS l_recording_release_fk_entity0;
ALTER TABLE l_recording_url
  DROP CONSTRAINT IF EXISTS l_recording_url_fk_entity0;
ALTER TABLE l_recording_work
  DROP CONSTRAINT IF EXISTS l_recording_work_fk_entity0;

ALTER TABLE track_gid_redirect
  DROP CONSTRAINT IF EXISTS track_gid_redirect_fk_new_id;

ALTER TABLE work_alias
  DROP CONSTRAINT IF EXISTS work_alias_fk_work;
ALTER TABLE iswc
  DROP CONSTRAINT IF EXISTS iswc_fk_work;
ALTER TABLE work_annotation
  DROP CONSTRAINT IF EXISTS work_annotation_fk_work;
ALTER TABLE work_meta
  DROP CONSTRAINT IF EXISTS work_meta_fk_id;
ALTER TABLE work_tag
  DROP CONSTRAINT IF EXISTS work_tag_fk_work;
ALTER TABLE work_rating_raw
  DROP CONSTRAINT IF EXISTS work_rating_raw_fk_work;
ALTER TABLE work_tag_raw
  DROP CONSTRAINT IF EXISTS work_tag_raw_fk_work;
ALTER TABLE work_gid_redirect
  DROP CONSTRAINT IF EXISTS work_gid_redirect_fk_new_id;
ALTER TABLE edit_work
  DROP CONSTRAINT IF EXISTS edit_work_fk_work;
ALTER TABLE work_attribute
  DROP CONSTRAINT IF EXISTS work_attribute_fk_work;

ALTER TABLE l_area_work
  DROP CONSTRAINT IF EXISTS l_area_work_fk_entity1;
ALTER TABLE l_artist_work
  DROP CONSTRAINT IF EXISTS l_artist_work_fk_entity1;
ALTER TABLE l_label_work
  DROP CONSTRAINT IF EXISTS l_label_work_fk_entity1;
ALTER TABLE l_recording_work
  DROP CONSTRAINT IF EXISTS l_recording_work_fk_entity1;
ALTER TABLE l_release_work
  DROP CONSTRAINT IF EXISTS l_release_work_fk_entity1;
ALTER TABLE l_release_group_work
  DROP CONSTRAINT IF EXISTS l_release_group_work_fk_entity1;
ALTER TABLE l_url_work
  DROP CONSTRAINT IF EXISTS l_url_work_fk_entity1;
ALTER TABLE l_work_work
  DROP CONSTRAINT IF EXISTS l_work_work_fk_entity1;
ALTER TABLE l_work_work
  DROP CONSTRAINT IF EXISTS l_work_work_fk_entity0;

-- Some slaves don't have these tables, so we'll just create empty stubs for now
CREATE TABLE IF NOT EXISTS editor_subscribe_artist_deleted
(
    editor INTEGER,
    gid UUID,
    deleted_by INTEGER
);

CREATE TABLE IF NOT EXISTS editor_subscribe_label_deleted
(
    editor INTEGER,
    gid UUID,
    deleted_by INTEGER
);

ALTER TABLE editor_subscribe_artist_deleted
  DROP CONSTRAINT IF EXISTS editor_subscribe_artist_deleted_fk_gid;

ALTER TABLE editor_subscribe_label_deleted
  DROP CONSTRAINT IF EXISTS editor_subscribe_label_deleted_fk_gid;

-- Drop views
------------------------

DROP VIEW IF EXISTS s_artist;
DROP VIEW IF EXISTS s_artist_credit;
DROP VIEW IF EXISTS s_artist_credit_name;
DROP VIEW IF EXISTS s_label;
DROP VIEW IF EXISTS s_recording;
DROP VIEW IF EXISTS s_release;
DROP VIEW IF EXISTS s_release_group;
DROP VIEW IF EXISTS s_track;
DROP VIEW IF EXISTS s_work;

DROP VIEW IF EXISTS s_release_event;

-- Drop dependent functions
------------------------
DROP FUNCTION IF EXISTS empty_artists();
DROP FUNCTION IF EXISTS empty_labels();
DROP FUNCTION IF EXISTS empty_release_groups();
DROP FUNCTION IF EXISTS empty_works();

-- Drop and rename tables
------------------------
DROP TABLE artist;
ALTER TABLE artist2013 RENAME TO artist;

DROP TABLE artist_alias;
ALTER TABLE artist_alias2013 RENAME TO artist_alias;

DROP TABLE artist_credit;
ALTER TABLE artist_credit2013 RENAME TO artist_credit;

DROP TABLE artist_credit_name;
ALTER TABLE artist_credit_name2013 RENAME TO artist_credit_name;

DROP TABLE label;
ALTER TABLE label2013 RENAME TO label;

DROP TABLE label_alias;
ALTER TABLE label_alias2013 RENAME TO label_alias;

DROP TABLE release;
ALTER TABLE release2013 RENAME TO release;

DROP TABLE release_group;
ALTER TABLE release_group2013 RENAME TO release_group;

DROP TABLE recording;
ALTER TABLE recording2013 RENAME TO recording;

DROP TABLE track;
ALTER TABLE track2013 RENAME TO track;

DROP TABLE work;
ALTER TABLE work2013 RENAME TO work;

DROP TABLE work_alias;
ALTER TABLE work_alias2013 RENAME TO work_alias;

DROP TABLE artist_deletion;
ALTER TABLE artist_deletion2013 RENAME TO artist_deletion;

DROP TABLE label_deletion;
ALTER TABLE label_deletion2013 RENAME TO label_deletion;

-- Add primary keys
------------------------
ALTER TABLE artist
  ADD PRIMARY KEY (id);
ALTER TABLE artist_alias
  ADD PRIMARY KEY (id);
ALTER TABLE artist_credit
  ADD PRIMARY KEY (id);
ALTER TABLE artist_credit_name
  ADD PRIMARY KEY (artist_credit, position);
ALTER TABLE label
  ADD PRIMARY KEY (id);
ALTER TABLE label_alias
  ADD PRIMARY KEY (id);
ALTER TABLE release
  ADD PRIMARY KEY (id);
ALTER TABLE release_group
  ADD PRIMARY KEY (id);
ALTER TABLE recording
  ADD PRIMARY KEY (id);
ALTER TABLE track
  ADD PRIMARY KEY (id);
ALTER TABLE work
  ADD PRIMARY KEY (id);
ALTER TABLE work_alias
  ADD PRIMARY KEY (id);
ALTER TABLE artist_deletion
  ADD PRIMARY KEY (gid);
ALTER TABLE label_deletion
  ADD PRIMARY KEY (gid);

-- Create indexes
------------------------
CREATE UNIQUE INDEX artist_idx_gid ON artist (gid);
CREATE INDEX artist_idx_name ON artist (name);
CREATE INDEX artist_idx_sort_name ON artist (sort_name);
CREATE INDEX artist_idx_page ON artist (page_index(name));
CREATE INDEX artist_idx_area ON artist (area);
CREATE INDEX artist_idx_begin_area ON artist (begin_area);
CREATE INDEX artist_idx_end_area ON artist (end_area);
CREATE UNIQUE INDEX artist_idx_null_comment ON artist (name) WHERE comment IS NULL;
CREATE UNIQUE INDEX artist_idx_uniq_name_comment ON artist (name, comment) WHERE comment IS NOT NULL;
CREATE INDEX artist_idx_lower_name ON artist (lower(name));
CREATE INDEX artist_idx_musicbrainz_collate ON artist (musicbrainz_collate(name));

CREATE INDEX artist_alias_idx_artist ON artist_alias (artist);
CREATE UNIQUE INDEX artist_alias_idx_primary ON artist_alias (artist, locale) WHERE primary_for_locale = TRUE AND locale IS NOT NULL;

CREATE INDEX artist_credit_idx_musicbrainz_collate ON artist_credit (musicbrainz_collate(name));

CREATE INDEX artist_credit_name_idx_artist ON artist_credit_name (artist);
CREATE INDEX artist_credit_name_idx_musicbrainz_collate ON artist_credit_name (musicbrainz_collate(name));

CREATE UNIQUE INDEX label_idx_gid ON label (gid);
CREATE INDEX label_idx_name ON label (name);
CREATE INDEX label_idx_sort_name ON label (sort_name);
CREATE INDEX label_idx_page ON label (page_index(name));
CREATE INDEX label_idx_area ON label (area);
CREATE UNIQUE INDEX label_idx_null_comment ON label (name) WHERE comment IS NULL;
CREATE UNIQUE INDEX label_idx_uniq_name_comment ON label (name, comment) WHERE comment IS NOT NULL;
CREATE INDEX label_idx_lower_name ON label (lower(name));
CREATE INDEX label_idx_musicbrainz_collate ON label (musicbrainz_collate(name));

CREATE INDEX label_alias_idx_label ON label_alias (label);
CREATE UNIQUE INDEX label_alias_idx_primary ON label_alias (label, locale) WHERE primary_for_locale = TRUE AND locale IS NOT NULL;

CREATE UNIQUE INDEX release_idx_gid ON release (gid);
CREATE INDEX release_idx_name ON release (name);
CREATE INDEX release_idx_page ON release (page_index(name));
CREATE INDEX release_idx_release_group ON release (release_group);
CREATE INDEX release_idx_artist_credit ON release (artist_credit);
CREATE INDEX release_idx_musicbrainz_collate ON release (musicbrainz_collate(name));

CREATE UNIQUE INDEX release_group_idx_gid ON release_group (gid);
CREATE INDEX release_group_idx_name ON release_group (name);
CREATE INDEX release_group_idx_page ON release_group (page_index(name));
CREATE INDEX release_group_idx_artist_credit ON release_group (artist_credit);
CREATE INDEX release_group_idx_musicbrainz_collate ON release_group (musicbrainz_collate(name));

CREATE UNIQUE INDEX recording_idx_gid ON recording (gid);
CREATE INDEX recording_idx_name ON recording (name);
CREATE INDEX recording_idx_artist_credit ON recording (artist_credit);
CREATE INDEX recording_idx_musicbrainz_collate ON recording (musicbrainz_collate(name));

CREATE UNIQUE INDEX track_idx_gid ON track (gid);
CREATE INDEX track_idx_recording ON track (recording);
CREATE INDEX track_idx_medium ON track (medium, position);
CREATE INDEX track_idx_name ON track (name);
CREATE INDEX track_idx_artist_credit ON track (artist_credit);
CREATE INDEX track_idx_musicbrainz_collate ON track (musicbrainz_collate(name));

CREATE UNIQUE INDEX work_idx_gid ON work (gid);
CREATE INDEX work_idx_name ON work (name);
CREATE INDEX work_idx_page ON work (page_index(name));
CREATE INDEX work_idx_musicbrainz_collate ON work (musicbrainz_collate(name));

CREATE INDEX work_alias_idx_work ON work_alias (work);
CREATE UNIQUE INDEX work_alias_idx_primary ON work_alias (work, locale) WHERE primary_for_locale = TRUE AND locale IS NOT NULL;

-- Create search indexes
------------------------
CREATE INDEX artist_idx_txt ON artist USING gin(to_tsvector('mb_simple', name));
CREATE INDEX artist_credit_idx_txt ON artist_credit USING gin(to_tsvector('mb_simple', name));
CREATE INDEX artist_credit_name_idx_txt ON artist_credit_name USING gin(to_tsvector('mb_simple', name));
CREATE INDEX label_idx_txt ON label USING gin(to_tsvector('mb_simple', name));
CREATE INDEX release_idx_txt ON release USING gin(to_tsvector('mb_simple', name));
CREATE INDEX release_group_idx_txt ON release_group USING gin(to_tsvector('mb_simple', name));
CREATE INDEX track_idx_txt ON track USING gin(to_tsvector('mb_simple', name));
CREATE INDEX recording_idx_txt ON recording USING gin(to_tsvector('mb_simple', name));
CREATE INDEX work_idx_txt ON work USING gin(to_tsvector('mb_simple', name));

-- Create functions
------------------------
CREATE OR REPLACE FUNCTION empty_artists() RETURNS SETOF int AS
$BODY$
  SELECT id FROM artist
  WHERE
    id > 2 AND
    edits_pending = 0 AND
    (
      last_updated < now() - '1 day'::interval OR last_updated is NULL
    )
  EXCEPT
  SELECT artist FROM edit_artist WHERE edit_artist.status = 1
  EXCEPT
  SELECT artist FROM artist_credit_name
  EXCEPT
  SELECT entity1 FROM l_area_artist
  EXCEPT
  SELECT entity0 FROM l_artist_artist
  EXCEPT
  SELECT entity1 FROM l_artist_artist
  EXCEPT
  SELECT entity0 FROM l_artist_label
  EXCEPT
  SELECT entity0 FROM l_artist_recording
  EXCEPT
  SELECT entity0 FROM l_artist_release
  EXCEPT
  SELECT entity0 FROM l_artist_release_group
  EXCEPT
  SELECT entity0 FROM l_artist_url
  EXCEPT
  SELECT entity0 FROM l_artist_work;
$BODY$
LANGUAGE 'sql';

CREATE OR REPLACE FUNCTION empty_labels() RETURNS SETOF int AS
$BODY$
  SELECT id FROM label
  WHERE
    id > 1 AND
    edits_pending = 0 AND
    (
      last_updated < now() - '1 day'::interval OR last_updated is NULL
    )
  EXCEPT
  SELECT label FROM edit_label WHERE edit_label.status = 1
  EXCEPT
  SELECT label FROM release_label
  EXCEPT
  SELECT entity1 FROM l_area_label
  EXCEPT
  SELECT entity1 FROM l_artist_label
  EXCEPT
  SELECT entity1 FROM l_label_label
  EXCEPT
  SELECT entity0 FROM l_label_label
  EXCEPT
  SELECT entity0 FROM l_label_recording
  EXCEPT
  SELECT entity0 FROM l_label_release
  EXCEPT
  SELECT entity0 FROM l_label_release_group
  EXCEPT
  SELECT entity0 FROM l_label_url
  EXCEPT
  SELECT entity0 FROM l_label_work;
$BODY$
LANGUAGE 'sql';

CREATE OR REPLACE FUNCTION empty_release_groups() RETURNS SETOF int AS
$BODY$
  SELECT id FROM release_group
  WHERE
    edits_pending = 0 AND
    (
      last_updated < now() - '1 day'::interval OR last_updated is NULL
    )
  EXCEPT
  SELECT release_group
  FROM edit_release_group
  JOIN edit ON (edit.id = edit_release_group.edit)
  WHERE edit.status = 1
  EXCEPT
  SELECT release_group FROM release
  EXCEPT
  SELECT entity1 FROM l_area_release_group
  EXCEPT
  SELECT entity1 FROM l_artist_release_group
  EXCEPT
  SELECT entity1 FROM l_label_release_group
  EXCEPT
  SELECT entity1 FROM l_recording_release_group
  EXCEPT
  SELECT entity1 FROM l_release_release_group
  EXCEPT
  SELECT entity1 FROM l_release_group_release_group
  EXCEPT
  SELECT entity0 FROM l_release_group_release_group
  EXCEPT
  SELECT entity0 FROM l_release_group_url
  EXCEPT
  SELECT entity0 FROM l_release_group_work;
$BODY$
LANGUAGE 'sql';

CREATE OR REPLACE FUNCTION empty_works() RETURNS SETOF int AS
$BODY$
  SELECT id FROM work
  WHERE
    edits_pending = 0 AND
    (
      last_updated < now() - '1 day'::interval OR last_updated is NULL
    )
  EXCEPT
  SELECT work
  FROM edit_work
  JOIN edit ON (edit.id = edit_work.edit)
  WHERE edit.status = 1
  EXCEPT
  SELECT entity1 FROM l_area_work
  EXCEPT
  SELECT entity1 FROM l_artist_work
  EXCEPT
  SELECT entity1 FROM l_label_work
  EXCEPT
  SELECT entity1 FROM l_recording_work
  EXCEPT
  SELECT entity1 FROM l_release_work
  EXCEPT
  SELECT entity1 FROM l_release_group_work
  EXCEPT
  SELECT entity1 FROM l_url_work
  EXCEPT
  SELECT entity1 FROM l_work_work
  EXCEPT
  SELECT entity0 FROM l_work_work;
$BODY$
LANGUAGE 'sql';

-- Actually drop the _name tables themselves
------------------------
DROP TABLE artist_name;
DROP TABLE label_name;
DROP TABLE release_name;
DROP TABLE track_name;
DROP TABLE work_name;

COMMIT;
