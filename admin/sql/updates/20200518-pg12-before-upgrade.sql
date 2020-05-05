\set ON_ERROR_STOP 1

SET search_path = musicbrainz, public;
SET statement_timeout = 0;

BEGIN;

-- Unused indexes
DROP INDEX IF EXISTS cdtoc_raw_track_offset;
DROP INDEX IF EXISTS dbmirror_pending_xid_index;
DROP INDEX IF EXISTS edit_note_idx_post_time;
DROP INDEX IF EXISTS edit_note_idx_post_time_edit;
DROP INDEX IF EXISTS editor_collection_idx_name;
DROP INDEX IF EXISTS release_raw_idx_last_modified;
DROP INDEX IF EXISTS release_raw_idx_lookup_count;
DROP INDEX IF EXISTS release_raw_idx_modify_count;
DROP INDEX IF EXISTS track_idx_musicbrainz_collate;
DROP INDEX IF EXISTS track_idx_name;
DROP INDEX IF EXISTS track_idx_txt;
DROP INDEX IF EXISTS vote_idx_vote_time;

-- Ancient page_index stuff from admin/sql/updates/20140130-remove-page-index.sql
DROP INDEX IF EXISTS area_idx_page;
DROP INDEX IF EXISTS artist_idx_page;
DROP INDEX IF EXISTS label_idx_page;
DROP INDEX IF EXISTS place_idx_page;
DROP INDEX IF EXISTS release_idx_page;
DROP INDEX IF EXISTS release_group_idx_page;
DROP INDEX IF EXISTS work_idx_page;
DROP FUNCTION IF EXISTS page_index(txt varchar);
DROP FUNCTION IF EXISTS page_index_max(txt varchar);

-- Indexes using musicbrainz_unaccent (via the mb_simple search configuration)
DROP INDEX IF EXISTS area_alias_idx_txt;
DROP INDEX IF EXISTS area_alias_idx_txt_sort;
DROP INDEX IF EXISTS area_idx_name_txt;
DROP INDEX IF EXISTS artist_alias_idx_txt;
DROP INDEX IF EXISTS artist_alias_idx_txt_sort;
DROP INDEX IF EXISTS artist_credit_idx_txt;
DROP INDEX IF EXISTS artist_credit_name_idx_txt;
DROP INDEX IF EXISTS artist_idx_txt;
DROP INDEX IF EXISTS artist_idx_txt_sort;
DROP INDEX IF EXISTS event_alias_idx_txt;
DROP INDEX IF EXISTS event_alias_idx_txt_sort;
DROP INDEX IF EXISTS event_idx_txt;
DROP INDEX IF EXISTS instrument_idx_txt;
DROP INDEX IF EXISTS label_alias_idx_txt;
DROP INDEX IF EXISTS label_alias_idx_txt_sort;
DROP INDEX IF EXISTS label_idx_txt;
DROP INDEX IF EXISTS place_alias_idx_txt;
DROP INDEX IF EXISTS place_alias_idx_txt_sort;
DROP INDEX IF EXISTS place_idx_name_txt;
DROP INDEX IF EXISTS recording_alias_idx_txt;
DROP INDEX IF EXISTS recording_alias_idx_txt_sort;
DROP INDEX IF EXISTS recording_idx_txt;
DROP INDEX IF EXISTS release_alias_idx_txt;
DROP INDEX IF EXISTS release_alias_idx_txt_sort;
DROP INDEX IF EXISTS release_group_alias_idx_txt;
DROP INDEX IF EXISTS release_group_alias_idx_txt_sort;
DROP INDEX IF EXISTS release_group_idx_txt;
DROP INDEX IF EXISTS release_idx_txt;
DROP INDEX IF EXISTS series_alias_idx_txt;
DROP INDEX IF EXISTS series_alias_idx_txt_sort;
DROP INDEX IF EXISTS series_idx_txt;
DROP INDEX IF EXISTS tag_idx_name_txt;
DROP INDEX IF EXISTS track_idx_txt;
DROP INDEX IF EXISTS work_alias_idx_txt;
DROP INDEX IF EXISTS work_alias_idx_txt_sort;
DROP INDEX IF EXISTS work_idx_txt;

-- Indexes using musicbrainz_collate
DROP INDEX IF EXISTS release_idx_musicbrainz_collate;
DROP INDEX IF EXISTS release_group_idx_musicbrainz_collate;
DROP INDEX IF EXISTS artist_idx_musicbrainz_collate;
DROP INDEX IF EXISTS artist_credit_idx_musicbrainz_collate;
DROP INDEX IF EXISTS artist_credit_name_idx_musicbrainz_collate;
DROP INDEX IF EXISTS label_idx_musicbrainz_collate;
DROP INDEX IF EXISTS track_idx_musicbrainz_collate;
DROP INDEX IF EXISTS recording_idx_musicbrainz_collate;
DROP INDEX IF EXISTS work_idx_musicbrainz_collate;

DROP TEXT SEARCH CONFIGURATION IF EXISTS mb_simple;

DROP EXTENSION IF EXISTS musicbrainz_collate;
DROP FUNCTION IF EXISTS musicbrainz_collate(text);

DROP EXTENSION IF EXISTS musicbrainz_unaccent;
DROP TEXT SEARCH DICTIONARY IF EXISTS musicbrainz_unaccentdict;
DROP TEXT SEARCH TEMPLATE IF EXISTS musicbrainz_unaccentdict_template;
DROP FUNCTION IF EXISTS musicbrainz_dunaccentdict_init(internal);
DROP FUNCTION IF EXISTS musicbrainz_dunaccentdict_lexize(internal, internal, internal, internal);
DROP FUNCTION IF EXISTS musicbrainz_unaccent(text);

DROP FUNCTION IF EXISTS normalize_url(text);
    -- normalize_url existed in the prod DB, but probably not elsewhere. It
    -- used plperl and basically just called URI::canonical on its input. I
    -- couldn't find any reference to it in any commit or chat log, so I
    -- assume it was a one-off function created by a developer for testing at
    -- some point in history.
DROP FUNCTION IF EXISTS plperlu_call_handler();
DROP FUNCTION IF EXISTS plperlu_inline_handler(internal);
DROP FUNCTION IF EXISTS plperlu_validator(oid);
DROP LANGUAGE IF EXISTS plperlu;

-- Index using broken public.ll_to_earth
DROP INDEX IF EXISTS place_idx_geo;

COMMIT;
