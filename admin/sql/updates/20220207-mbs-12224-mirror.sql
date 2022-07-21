\set ON_ERROR_STOP 1

BEGIN;

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
