\set ON_ERROR_STOP 1

BEGIN;

-- Updated rating functions
CREATE OR REPLACE FUNCTION update_aggregate_rating_for_raw_insert()
RETURNS trigger AS $$
DECLARE
  entity_type ratable_entity_type;
  new_entity_id INTEGER;
  is_spammer BOOLEAN;
BEGIN
  is_spammer := (SELECT (privs & 4096) > 0 FROM editor WHERE id = NEW.editor);
  IF NOT is_spammer THEN
    entity_type := TG_ARGV[0]::ratable_entity_type;
    EXECUTE format('SELECT ($1).%s', entity_type::TEXT) INTO new_entity_id USING NEW;
    PERFORM update_aggregate_rating(entity_type, new_entity_id);
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION update_aggregate_rating_for_raw_update()
RETURNS trigger AS $$
DECLARE
  entity_type ratable_entity_type;
  new_entity_id INTEGER;
  old_entity_id INTEGER;
  is_spammer BOOLEAN;
BEGIN
  is_spammer := (SELECT (privs & 4096) > 0 FROM editor WHERE id = NEW.editor);
  IF NOT is_spammer THEN
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
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION update_aggregate_rating_for_raw_delete()
RETURNS trigger AS $$
DECLARE
  entity_type ratable_entity_type;
  old_entity_id INTEGER;
  is_spammer BOOLEAN;
BEGIN
  is_spammer := (SELECT (privs & 4096) > 0 FROM editor WHERE id = NEW.editor);
  IF NOT is_spammer THEN
    entity_type := TG_ARGV[0]::ratable_entity_type;
    EXECUTE format('SELECT ($1).%s', entity_type::TEXT) INTO old_entity_id USING OLD;
    PERFORM update_aggregate_rating(entity_type, old_entity_id);
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

-- Updated tag functions
CREATE OR REPLACE FUNCTION update_tag_counts_for_raw_insert()
RETURNS trigger AS $$
DECLARE
  entity_type taggable_entity_type;
  new_entity_id INTEGER;
  is_spammer BOOLEAN;
BEGIN
  is_spammer := (SELECT (privs & 4096) > 0 FROM editor WHERE id = NEW.editor);
  IF NOT is_spammer THEN
    entity_type := TG_ARGV[0]::taggable_entity_type;
    EXECUTE format('SELECT ($1).%s', entity_type::TEXT) INTO new_entity_id USING NEW;
    PERFORM update_aggregate_tag_count(entity_type, new_entity_id, NEW.tag, (CASE WHEN NEW.is_upvote THEN 1 ELSE -1 END)::SMALLINT);
    UPDATE tag SET ref_count = ref_count + 1 WHERE id = NEW.tag;
  END IF
  RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION update_tag_counts_for_raw_update()
RETURNS trigger AS $$
DECLARE
  entity_type taggable_entity_type;
  new_entity_id INTEGER;
  old_entity_id INTEGER;
  is_spammer BOOLEAN;
BEGIN
  is_spammer := (SELECT (privs & 4096) > 0 FROM editor WHERE id = NEW.editor);
  IF NOT is_spammer THEN
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
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION update_tag_counts_for_raw_delete()
RETURNS trigger AS $$
DECLARE
  entity_type taggable_entity_type;
  old_entity_id INTEGER;
  is_spammer BOOLEAN;
BEGIN
  is_spammer := (SELECT (privs & 4096) > 0 FROM editor WHERE id = NEW.editor);
  IF NOT is_spammer THEN
    entity_type := TG_ARGV[0]::taggable_entity_type;
    EXECUTE format('SELECT ($1).%s', entity_type::TEXT) INTO old_entity_id USING OLD;
    PERFORM update_aggregate_tag_count(entity_type, old_entity_id, OLD.tag, (CASE WHEN OLD.is_upvote THEN -1 ELSE 1 END)::SMALLINT);
    PERFORM delete_unused_aggregate_tag(entity_type, old_entity_id, OLD.tag);
    UPDATE tag SET ref_count = ref_count - 1 WHERE id = OLD.tag;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

-- Editor function
CREATE OR REPLACE FUNCTION update_tags_and_ratings_for_spammer()
RETURNS trigger AS $$
DECLARE
  ratable_type ratable_entity_type;
  taggable_type taggable_entity_type;
  changes_to_spammer BOOLEAN;
  changes_from_spammer BOOLEAN;
  r RECORD;
BEGIN
  changes_to_spammer := ((OLD.privs & 4096) = 0 AND (NEW.privs & 4096) > 0);
  changes_from_spammer := ((OLD.privs & 4096) > 0 AND (NEW.privs & 4096) = 0);
  IF (changes_to_spammer || changes_from_spammer) THEN
    -- Recalculate ratings for all their rated entities
    FOR ratable_type IN EXECUTE 'SELECT enum_range(NULL::ratable_entity_type)' LOOP
      FOR r IN EXECUTE format(
        $SQL$
          SELECT %1$I AS id
            FROM %2$I
           WHERE editor = $1
        $SQL$,
        ratable_type::TEXT,
        ratable_type::TEXT || '_rating_raw'
      ) USING NEW.id LOOP 
        PERFORM update_aggregate_rating(ratable_type, r.id);
      END LOOP;
    END LOOP;

    -- Recalculate tags for all their tagged entities
    FOR taggable_type IN EXECUTE 'SELECT enum_range(NULL::taggable_entity_type)' LOOP
    -- For each _tag_raw table:
      -- Select into ids_to_update all ids that the editor *has* tagged
      FOR r IN EXECUTE format(
        $SQL$
          SELECT %1$I AS id,
                 tag,
                 is_upvote
            FROM %2$I
           WHERE editor = $1
        $SQL$,
        ratable_type::TEXT,
        ratable_type::TEXT || '_rating_raw'
      ) USING NEW.id LOOP  
        IF (changes_to_spammer) THEN
          -- We want to "un-apply" their tag, so we do the opposite
          PERFORM update_aggregate_tag_count(taggable_type, r.id, r.tag, (CASE WHEN r.is_upvote THEN -1 ELSE 1 END)::SMALLINT);
          UPDATE tag SET ref_count = ref_count - 1 WHERE id = r.tag;
        ELSIF (changes_from_spammer) THEN
          -- We want to "re-apply" their tag
          PERFORM update_aggregate_tag_count(taggable_type, r.id, r.tag, (CASE WHEN r.is_upvote THEN 1 ELSE -1 END)::SMALLINT);
          UPDATE tag SET ref_count = ref_count + 1 WHERE id = r.tag;
        END IF;
      END LOOP;
    END LOOP;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

COMMIT;
