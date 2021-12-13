\set ON_ERROR_STOP 1

BEGIN;

DELETE FROM area_tag a WHERE NOT EXISTS (
    SELECT 1
      FROM area_tag_raw r
     WHERE r.area = a.area AND r.tag = a.tag
);

UPDATE area_tag a SET count = (
    SELECT sum(CASE WHEN is_upvote THEN 1 ELSE -1 END)
      FROM area_tag_raw r
     WHERE r.area = a.area AND r.tag = a.tag
  GROUP BY r.area, r.tag
);

DELETE FROM artist_tag a WHERE NOT EXISTS (
    SELECT 1
      FROM artist_tag_raw r
     WHERE r.artist = a.artist AND r.tag = a.tag
);

UPDATE artist_tag a SET count = (
    SELECT sum(CASE WHEN is_upvote THEN 1 ELSE -1 END)
      FROM artist_tag_raw r
     WHERE r.artist = a.artist AND r.tag = a.tag
  GROUP BY r.artist, r.tag
);

DELETE FROM event_tag a WHERE NOT EXISTS (
    SELECT 1
      FROM event_tag_raw r
     WHERE r.event = a.event AND r.tag = a.tag
);

UPDATE event_tag a SET count = (
    SELECT sum(CASE WHEN is_upvote THEN 1 ELSE -1 END)
      FROM event_tag_raw r
     WHERE r.event = a.event AND r.tag = a.tag
  GROUP BY r.event, r.tag
);

DELETE FROM instrument_tag a WHERE NOT EXISTS (
    SELECT 1
      FROM instrument_tag_raw r
     WHERE r.instrument = a.instrument AND r.tag = a.tag
);

UPDATE instrument_tag a SET count = (
    SELECT sum(CASE WHEN is_upvote THEN 1 ELSE -1 END)
      FROM instrument_tag_raw r
     WHERE r.instrument = a.instrument AND r.tag = a.tag
  GROUP BY r.instrument, r.tag
);

DELETE FROM label_tag a WHERE NOT EXISTS (
    SELECT 1
      FROM label_tag_raw r
     WHERE r.label = a.label AND r.tag = a.tag
);

UPDATE label_tag a SET count = (
    SELECT sum(CASE WHEN is_upvote THEN 1 ELSE -1 END)
      FROM label_tag_raw r
     WHERE r.label = a.label AND r.tag = a.tag
  GROUP BY r.label, r.tag
);

DELETE FROM place_tag a WHERE NOT EXISTS (
    SELECT 1
      FROM place_tag_raw r
     WHERE r.place = a.place AND r.tag = a.tag
);

UPDATE place_tag a SET count = (
    SELECT sum(CASE WHEN is_upvote THEN 1 ELSE -1 END)
      FROM place_tag_raw r
     WHERE r.place = a.place AND r.tag = a.tag
  GROUP BY r.place, r.tag
);

DELETE FROM recording_tag a WHERE NOT EXISTS (
    SELECT 1
      FROM recording_tag_raw r
     WHERE r.recording = a.recording AND r.tag = a.tag
);

UPDATE recording_tag a SET count = (
    SELECT sum(CASE WHEN is_upvote THEN 1 ELSE -1 END)
      FROM recording_tag_raw r
     WHERE r.recording = a.recording AND r.tag = a.tag
  GROUP BY r.recording, r.tag
);

DELETE FROM release_tag a WHERE NOT EXISTS (
    SELECT 1
      FROM release_tag_raw r
     WHERE r.release = a.release AND r.tag = a.tag
);

UPDATE release_tag a SET count = (
    SELECT sum(CASE WHEN is_upvote THEN 1 ELSE -1 END)
      FROM release_tag_raw r
     WHERE r.release = a.release AND r.tag = a.tag
  GROUP BY r.release, r.tag
);

DELETE FROM release_group_tag a WHERE NOT EXISTS (
    SELECT 1
      FROM release_group_tag_raw r
     WHERE r.release_group = a.release_group AND r.tag = a.tag
);

UPDATE release_group_tag a SET count = (
    SELECT sum(CASE WHEN is_upvote THEN 1 ELSE -1 END)
      FROM release_group_tag_raw r
     WHERE r.release_group = a.release_group AND r.tag = a.tag
  GROUP BY r.release_group, r.tag
);

DELETE FROM series_tag a WHERE NOT EXISTS (
    SELECT 1
      FROM series_tag_raw r
     WHERE r.series = a.series AND r.tag = a.tag
);

UPDATE series_tag a SET count = (
    SELECT sum(CASE WHEN is_upvote THEN 1 ELSE -1 END)
      FROM series_tag_raw r
     WHERE r.series = a.series AND r.tag = a.tag
  GROUP BY r.series, r.tag
);

DELETE FROM work_tag a WHERE NOT EXISTS (
    SELECT 1
      FROM work_tag_raw r
     WHERE r.work = a.work AND r.tag = a.tag
);

UPDATE work_tag a SET count = (
    SELECT sum(CASE WHEN is_upvote THEN 1 ELSE -1 END)
      FROM work_tag_raw r
     WHERE r.work = a.work AND r.tag = a.tag
  GROUP BY r.work, r.tag
);

UPDATE tag t SET ref_count = (
  (SELECT count(*) FROM area_tag_raw r WHERE r.tag = t.id) +
  (SELECT count(*) FROM artist_tag_raw r WHERE r.tag = t.id) +
  (SELECT count(*) FROM event_tag_raw r WHERE r.tag = t.id) +
  (SELECT count(*) FROM instrument_tag_raw r WHERE r.tag = t.id) +
  (SELECT count(*) FROM label_tag_raw r WHERE r.tag = t.id) +
  (SELECT count(*) FROM place_tag_raw r WHERE r.tag = t.id) +
  (SELECT count(*) FROM recording_tag_raw r WHERE r.tag = t.id) +
  (SELECT count(*) FROM release_tag_raw r WHERE r.tag = t.id) +
  (SELECT count(*) FROM release_group_tag_raw r WHERE r.tag = t.id) +
  (SELECT count(*) FROM series_tag_raw r WHERE r.tag = t.id) +
  (SELECT count(*) FROM work_tag_raw r WHERE r.tag = t.id)
);

DELETE FROM tag WHERE ref_count = 0;

CREATE TYPE taggable_entity_type AS ENUM (
    'area',
    'artist',
    'event',
    'instrument',
    'label',
    'place',
    'recording',
    'release',
    'release_group',
    'series',
    'work'
);

CREATE OR REPLACE FUNCTION update_aggregate_tag_count(entity_type taggable_entity_type, entity_id INTEGER, tag_id INTEGER, count_change SMALLINT)
RETURNS VOID AS $$
BEGIN
  -- Insert-or-update the aggregate vote count for the given (entity_id, tag_id).
  EXECUTE format(
    $SQL$
      INSERT INTO %1$I AS agg (%2$I, tag, count)
           VALUES ($1, $2, $3)
      ON CONFLICT (%2$I, tag) DO UPDATE SET count = agg.count + $3
    $SQL$,
    entity_type::TEXT || '_tag',
    entity_type::TEXT
  ) USING entity_id, tag_id, count_change;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION delete_unused_aggregate_tag(entity_type taggable_entity_type, entity_id INTEGER, tag_id INTEGER)
RETURNS VOID AS $$
BEGIN
  -- Delete the aggregate tag row for (entity_id, tag_id) if no raw tag pair
  -- exists for the same.
  --
  -- Note that an aggregate vote count of 0 doesn't imply there are no raw
  -- tags; it's a sum of all the votes, so it can also mean that there's a
  -- downvote for every upvote.
  EXECUTE format(
    $SQL$
      DELETE FROM %1$I
            WHERE %2$I = $1
              AND tag = $2
              AND NOT EXISTS (SELECT 1 FROM %3$I WHERE %2$I = $1 AND tag = $2)
    $SQL$,
    entity_type::TEXT || '_tag',
    entity_type::TEXT,
    entity_type::TEXT || '_tag_raw'
  ) USING entity_id, tag_id;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION update_tag_counts_for_raw_insert()
RETURNS trigger AS $$
DECLARE
  entity_type taggable_entity_type;
  new_entity_id INTEGER;
BEGIN
  entity_type := TG_ARGV[0]::taggable_entity_type;
  EXECUTE format('SELECT ($1).%s', entity_type::TEXT) INTO new_entity_id USING NEW;
  PERFORM update_aggregate_tag_count(entity_type, new_entity_id, NEW.tag, (CASE WHEN NEW.is_upvote THEN 1 ELSE -1 END)::SMALLINT);
  UPDATE tag SET ref_count = ref_count + 1 WHERE id = NEW.tag;
  RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION update_tag_counts_for_raw_update()
RETURNS trigger AS $$
DECLARE
  entity_type taggable_entity_type;
  new_entity_id INTEGER;
  old_entity_id INTEGER;
BEGIN
  entity_type := TG_ARGV[0]::taggable_entity_type;
  EXECUTE format('SELECT ($1).%s', entity_type) INTO new_entity_id USING NEW;
  EXECUTE format('SELECT ($1).%s', entity_type) INTO old_entity_id USING OLD;
  IF (old_entity_id = new_entity_id AND OLD.tag = NEW.tag AND OLD.is_upvote != NEW.is_upvote) THEN
    -- Case 1: only the vote changed.
    PERFORM update_aggregate_tag_count(entity_type, old_entity_id, OLD.tag, (CASE WHEN OLD.is_upvote THEN -2 ELSE 2 END)::SMALLINT);
  ELSIF (old_entity_id != new_entity_id OR OLD.tag != NEW.tag OR OLD.is_upvote != NEW.is_upvote) THEN
    -- Case 2: the entity, tag, or vote changed.
    PERFORM update_aggregate_tag_count(entity_type, old_entity_id, OLD.tag, (CASE WHEN OLD.is_upvote THEN -1 ELSE 1 END)::SMALLINT);
    PERFORM update_aggregate_tag_count(entity_type, new_entity_id, NEW.tag, (CASE WHEN NEW.is_upvote THEN 1 ELSE -1 END)::SMALLINT);
    PERFORM delete_unused_aggregate_tag(entity_type, old_entity_id, OLD.tag);
  END IF;
  IF OLD.tag != NEW.tag THEN
    UPDATE tag SET ref_count = ref_count - 1 WHERE id = OLD.tag;
    UPDATE tag SET ref_count = ref_count + 1 WHERE id = NEW.tag;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION update_tag_counts_for_raw_delete()
RETURNS trigger AS $$
DECLARE
  entity_type taggable_entity_type;
  old_entity_id INTEGER;
BEGIN
  entity_type := TG_ARGV[0]::taggable_entity_type;
  EXECUTE format('SELECT ($1).%s', entity_type::TEXT) INTO old_entity_id USING OLD;
  PERFORM update_aggregate_tag_count(entity_type, old_entity_id, OLD.tag, (CASE WHEN OLD.is_upvote THEN -1 ELSE 1 END)::SMALLINT);
  PERFORM delete_unused_aggregate_tag(entity_type, old_entity_id, OLD.tag);
  UPDATE tag SET ref_count = ref_count - 1 WHERE id = OLD.tag;
  RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

COMMIT;
