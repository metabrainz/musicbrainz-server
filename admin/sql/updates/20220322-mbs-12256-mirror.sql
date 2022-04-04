\set ON_ERROR_STOP 1

BEGIN;

UPDATE artist_meta
   SET rating = agg.rating
  FROM (
      SELECT artist,
             trunc((sum(rating)::REAL /
                    count(rating)::REAL) +
                   0.5::REAL)::SMALLINT AS rating
        FROM artist_rating_raw
    GROUP BY artist
  ) agg
 WHERE id = agg.artist;

UPDATE event_meta
   SET rating = agg.rating
  FROM (
      SELECT event,
             trunc((sum(rating)::REAL /
                    count(rating)::REAL) +
                   0.5::REAL)::SMALLINT AS rating
        FROM event_rating_raw
    GROUP BY event
  ) agg
 WHERE id = agg.event;

UPDATE label_meta
   SET rating = agg.rating
  FROM (
      SELECT label,
             trunc((sum(rating)::REAL /
                    count(rating)::REAL) +
                   0.5::REAL)::SMALLINT AS rating
        FROM label_rating_raw
    GROUP BY label
  ) agg
 WHERE id = agg.label;

UPDATE place_meta
   SET rating = agg.rating
  FROM (
      SELECT place,
             trunc((sum(rating)::REAL /
                    count(rating)::REAL) +
                   0.5::REAL)::SMALLINT AS rating
        FROM place_rating_raw
    GROUP BY place
  ) agg
 WHERE id = agg.place;

UPDATE recording_meta
   SET rating = agg.rating
  FROM (
      SELECT recording,
             trunc((sum(rating)::REAL /
                    count(rating)::REAL) +
                   0.5::REAL)::SMALLINT AS rating
        FROM recording_rating_raw
    GROUP BY recording
  ) agg
 WHERE id = agg.recording;

UPDATE release_group_meta
   SET rating = agg.rating
  FROM (
      SELECT release_group,
             trunc((sum(rating)::REAL /
                    count(rating)::REAL) +
                   0.5::REAL)::SMALLINT AS rating
        FROM release_group_rating_raw
    GROUP BY release_group
  ) agg
 WHERE id = agg.release_group;

UPDATE work_meta
   SET rating = agg.rating
  FROM (
      SELECT work,
             trunc((sum(rating)::REAL /
                    count(rating)::REAL) +
                   0.5::REAL)::SMALLINT AS rating
        FROM work_rating_raw
    GROUP BY work
  ) agg
 WHERE id = agg.work;

CREATE TYPE ratable_entity_type AS ENUM (
    'artist',
    'event',
    'label',
    'place',
    'recording',
    'release_group',
    'work'
);

CREATE OR REPLACE FUNCTION update_aggregate_rating(entity_type ratable_entity_type, entity_id INTEGER)
RETURNS VOID AS $$
BEGIN
  -- update the aggregate rating for the given entity_id.
  EXECUTE format(
    $SQL$
      UPDATE %2$I
         SET rating = agg.rating,
             rating_count = nullif(agg.rating_count, 0)
        FROM (
          SELECT count(rating)::INTEGER AS rating_count,
                 -- trunc(x + 0.5) is used because round() on REAL values
                 -- rounds to the nearest even number.
                 trunc((sum(rating)::REAL /
                        count(rating)::REAL) +
                       0.5::REAL)::SMALLINT AS rating
            FROM %3$I
           WHERE %1$I = $1
        ) agg
       WHERE id = $1
    $SQL$,
    entity_type::TEXT,
    entity_type::TEXT || '_meta',
    entity_type::TEXT || '_rating_raw'
  ) USING entity_id;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION update_aggregate_rating_for_raw_insert()
RETURNS trigger AS $$
DECLARE
  entity_type ratable_entity_type;
  new_entity_id INTEGER;
BEGIN
  entity_type := TG_ARGV[0]::ratable_entity_type;
  EXECUTE format('SELECT ($1).%s', entity_type::TEXT) INTO new_entity_id USING NEW;
  PERFORM update_aggregate_rating(entity_type, new_entity_id);
  RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION update_aggregate_rating_for_raw_update()
RETURNS trigger AS $$
DECLARE
  entity_type ratable_entity_type;
  new_entity_id INTEGER;
  old_entity_id INTEGER;
BEGIN
  entity_type := TG_ARGV[0]::ratable_entity_type;
  EXECUTE format('SELECT ($1).%s', entity_type) INTO new_entity_id USING NEW;
  EXECUTE format('SELECT ($1).%s', entity_type) INTO old_entity_id USING OLD;
  IF (old_entity_id = new_entity_id AND OLD.rating != NEW.rating) THEN
    -- Case 1: only the rating changed.
    PERFORM update_aggregate_rating(entity_type, old_entity_id);
  ELSIF (old_entity_id != new_entity_id OR OLD.rating != NEW.rating) THEN
    -- Case 2: the entity or rating changed.
    PERFORM update_aggregate_rating(entity_type, old_entity_id);
    PERFORM update_aggregate_rating(entity_type, new_entity_id);
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION update_aggregate_rating_for_raw_delete()
RETURNS trigger AS $$
DECLARE
  entity_type ratable_entity_type;
  old_entity_id INTEGER;
BEGIN
  entity_type := TG_ARGV[0]::ratable_entity_type;
  EXECUTE format('SELECT ($1).%s', entity_type::TEXT) INTO old_entity_id USING OLD;
  PERFORM update_aggregate_rating(entity_type, old_entity_id);
  RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

COMMIT;
