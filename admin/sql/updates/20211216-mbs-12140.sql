\set ON_ERROR_STOP 1

BEGIN;

DO $$
DECLARE
  empty_tag_ids INTEGER[];
BEGIN
  SELECT array_agg(id) FROM tag WHERE name ~ E'^\\s*$' INTO empty_tag_ids;

  DELETE FROM area_tag_raw WHERE tag = any(empty_tag_ids);
  DELETE FROM artist_tag_raw WHERE tag = any(empty_tag_ids);
  DELETE FROM event_tag_raw WHERE tag = any(empty_tag_ids);
  DELETE FROM instrument_tag_raw WHERE tag = any(empty_tag_ids);
  DELETE FROM label_tag_raw WHERE tag = any(empty_tag_ids);
  DELETE FROM place_tag_raw WHERE tag = any(empty_tag_ids);
  DELETE FROM recording_tag_raw WHERE tag = any(empty_tag_ids);
  DELETE FROM release_group_tag_raw WHERE tag = any(empty_tag_ids);
  DELETE FROM release_tag_raw WHERE tag = any(empty_tag_ids);
  DELETE FROM series_tag_raw WHERE tag = any(empty_tag_ids);
  DELETE FROM work_tag_raw WHERE tag = any(empty_tag_ids);

  DELETE FROM area_tag WHERE tag = any(empty_tag_ids);
  DELETE FROM artist_tag WHERE tag = any(empty_tag_ids);
  DELETE FROM event_tag WHERE tag = any(empty_tag_ids);
  DELETE FROM instrument_tag WHERE tag = any(empty_tag_ids);
  DELETE FROM label_tag WHERE tag = any(empty_tag_ids);
  DELETE FROM place_tag WHERE tag = any(empty_tag_ids);
  DELETE FROM recording_tag WHERE tag = any(empty_tag_ids);
  DELETE FROM release_group_tag WHERE tag = any(empty_tag_ids);
  DELETE FROM release_tag WHERE tag = any(empty_tag_ids);
  DELETE FROM series_tag WHERE tag = any(empty_tag_ids);
  DELETE FROM work_tag WHERE tag = any(empty_tag_ids);
END
$$;

COMMIT;
