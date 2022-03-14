\set ON_ERROR_STOP 1

BEGIN;

-- NOTE: Make sure this script runs *before* any that recalculates
-- count/ref_count for the schema change.

DO $$
DECLARE
  empty_tag_ids INTEGER[];
  -- An "uncontrolled for whitespace" tag.
  ufw_tag RECORD;
  -- An existing "controlled for whitespace" tag ID that would conflict with
  -- ufw_tag if it were cleaned.
  existing_cfw_tag_id INTEGER;
  tag_cursor REFCURSOR;
BEGIN
  SELECT array_agg(id)
    FROM tag
   WHERE name ~ E'^\\s*$'
    INTO empty_tag_ids;

  RAISE NOTICE 'Deleting empty tag IDs: %', empty_tag_ids;

  DELETE FROM area_tag_raw WHERE tag = any(empty_tag_ids);
  DELETE FROM artist_tag_raw WHERE tag = any(empty_tag_ids);
  DELETE FROM event_tag_raw WHERE tag = any(empty_tag_ids);
  DELETE FROM instrument_tag_raw WHERE tag = any(empty_tag_ids);
  DELETE FROM label_tag_raw WHERE tag = any(empty_tag_ids);
  DELETE FROM place_tag_raw WHERE tag = any(empty_tag_ids);
  DELETE FROM recording_tag_raw WHERE tag = any(empty_tag_ids);
  DELETE FROM release_tag_raw WHERE tag = any(empty_tag_ids);
  DELETE FROM release_group_tag_raw WHERE tag = any(empty_tag_ids);
  DELETE FROM series_tag_raw WHERE tag = any(empty_tag_ids);
  DELETE FROM work_tag_raw WHERE tag = any(empty_tag_ids);

  DELETE FROM area_tag WHERE tag = any(empty_tag_ids);
  DELETE FROM artist_tag WHERE tag = any(empty_tag_ids);
  DELETE FROM event_tag WHERE tag = any(empty_tag_ids);
  DELETE FROM instrument_tag WHERE tag = any(empty_tag_ids);
  DELETE FROM label_tag WHERE tag = any(empty_tag_ids);
  DELETE FROM place_tag WHERE tag = any(empty_tag_ids);
  DELETE FROM recording_tag WHERE tag = any(empty_tag_ids);
  DELETE FROM release_tag WHERE tag = any(empty_tag_ids);
  DELETE FROM release_group_tag WHERE tag = any(empty_tag_ids);
  DELETE FROM series_tag WHERE tag = any(empty_tag_ids);
  DELETE FROM work_tag WHERE tag = any(empty_tag_ids);

  -- delete_unused_tag would normally kick in to delete these, but not if
  -- they were completely unreferenced prior to running this script.
  DELETE FROM tag WHERE id = any(empty_tag_ids);

  -- Find tags with uncontrolled whitespace and clean them up.
  --
  -- We may find that for any unclean tag, an existing tag with the
  -- "cleaned up" name already exists.  In that case, we update all
  -- *_tag_raw and *_tag rows to use the existing clean tag, and delete
  -- the unclean one.
  FOR ufw_tag IN (
    SELECT * FROM tag WHERE NOT controlled_for_whitespace(name)
  ) LOOP
    RAISE NOTICE 'Tag with uncontrolled whitespace found: id=%, name=%',
      ufw_tag.id, to_json(ufw_tag.name);

    SELECT t2.id
      FROM tag t1
      JOIN tag t2
        ON (t1.id = ufw_tag.id
            AND t2.id != ufw_tag.id
            AND t2.name = regexp_replace(btrim(t1.name), E'\\s{2,}', ' ', 'g'))
      INTO existing_cfw_tag_id;

    IF existing_cfw_tag_id IS NULL THEN
      UPDATE tag
         SET name = regexp_replace(btrim(name), E'\\s{2,}', ' ', 'g')
       WHERE id = ufw_tag.id;
    ELSE
      RAISE NOTICE 'Conflicting tag with controlled whitespace found: id=%',
        existing_cfw_tag_id;

      OPEN tag_cursor NO SCROLL FOR SELECT * FROM area_tag_raw WHERE tag = ufw_tag.id FOR UPDATE;
      LOOP
        MOVE tag_cursor;
        IF FOUND THEN
          BEGIN
            UPDATE area_tag_raw SET tag = existing_cfw_tag_id WHERE CURRENT OF tag_cursor;
          EXCEPTION WHEN unique_violation THEN
            DELETE FROM area_tag_raw WHERE CURRENT OF tag_cursor;
          END;
        ELSE
          CLOSE tag_cursor;
          EXIT;
        END IF;
      END LOOP;

      OPEN tag_cursor NO SCROLL FOR SELECT * FROM area_tag WHERE tag = ufw_tag.id FOR UPDATE;
      LOOP
        MOVE tag_cursor;
        IF FOUND THEN
          BEGIN
            UPDATE area_tag SET tag = existing_cfw_tag_id WHERE CURRENT OF tag_cursor;
          EXCEPTION WHEN unique_violation THEN
            DELETE FROM area_tag WHERE CURRENT OF tag_cursor;
          END;
        ELSE
          CLOSE tag_cursor;
          EXIT;
        END IF;
      END LOOP;

      OPEN tag_cursor NO SCROLL FOR SELECT * FROM artist_tag_raw WHERE tag = ufw_tag.id FOR UPDATE;
      LOOP
        MOVE tag_cursor;
        IF FOUND THEN
          BEGIN
            UPDATE artist_tag_raw SET tag = existing_cfw_tag_id WHERE CURRENT OF tag_cursor;
          EXCEPTION WHEN unique_violation THEN
            DELETE FROM artist_tag_raw WHERE CURRENT OF tag_cursor;
          END;
        ELSE
          CLOSE tag_cursor;
          EXIT;
        END IF;
      END LOOP;

      OPEN tag_cursor NO SCROLL FOR SELECT * FROM artist_tag WHERE tag = ufw_tag.id FOR UPDATE;
      LOOP
        MOVE tag_cursor;
        IF FOUND THEN
          BEGIN
            UPDATE artist_tag SET tag = existing_cfw_tag_id WHERE CURRENT OF tag_cursor;
          EXCEPTION WHEN unique_violation THEN
            DELETE FROM artist_tag WHERE CURRENT OF tag_cursor;
          END;
        ELSE
          CLOSE tag_cursor;
          EXIT;
        END IF;
      END LOOP;

      OPEN tag_cursor NO SCROLL FOR SELECT * FROM event_tag_raw WHERE tag = ufw_tag.id FOR UPDATE;
      LOOP
        MOVE tag_cursor;
        IF FOUND THEN
          BEGIN
            UPDATE event_tag_raw SET tag = existing_cfw_tag_id WHERE CURRENT OF tag_cursor;
          EXCEPTION WHEN unique_violation THEN
            DELETE FROM event_tag_raw WHERE CURRENT OF tag_cursor;
          END;
        ELSE
          CLOSE tag_cursor;
          EXIT;
        END IF;
      END LOOP;

      OPEN tag_cursor NO SCROLL FOR SELECT * FROM event_tag WHERE tag = ufw_tag.id FOR UPDATE;
      LOOP
        MOVE tag_cursor;
        IF FOUND THEN
          BEGIN
            UPDATE event_tag SET tag = existing_cfw_tag_id WHERE CURRENT OF tag_cursor;
          EXCEPTION WHEN unique_violation THEN
            DELETE FROM event_tag WHERE CURRENT OF tag_cursor;
          END;
        ELSE
          CLOSE tag_cursor;
          EXIT;
        END IF;
      END LOOP;

      OPEN tag_cursor NO SCROLL FOR SELECT * FROM instrument_tag_raw WHERE tag = ufw_tag.id FOR UPDATE;
      LOOP
        MOVE tag_cursor;
        IF FOUND THEN
          BEGIN
            UPDATE instrument_tag_raw SET tag = existing_cfw_tag_id WHERE CURRENT OF tag_cursor;
          EXCEPTION WHEN unique_violation THEN
            DELETE FROM instrument_tag_raw WHERE CURRENT OF tag_cursor;
          END;
        ELSE
          CLOSE tag_cursor;
          EXIT;
        END IF;
      END LOOP;

      OPEN tag_cursor NO SCROLL FOR SELECT * FROM instrument_tag WHERE tag = ufw_tag.id FOR UPDATE;
      LOOP
        MOVE tag_cursor;
        IF FOUND THEN
          BEGIN
            UPDATE instrument_tag SET tag = existing_cfw_tag_id WHERE CURRENT OF tag_cursor;
          EXCEPTION WHEN unique_violation THEN
            DELETE FROM instrument_tag WHERE CURRENT OF tag_cursor;
          END;
        ELSE
          CLOSE tag_cursor;
          EXIT;
        END IF;
      END LOOP;

      OPEN tag_cursor NO SCROLL FOR SELECT * FROM label_tag_raw WHERE tag = ufw_tag.id FOR UPDATE;
      LOOP
        MOVE tag_cursor;
        IF FOUND THEN
          BEGIN
            UPDATE label_tag_raw SET tag = existing_cfw_tag_id WHERE CURRENT OF tag_cursor;
          EXCEPTION WHEN unique_violation THEN
            DELETE FROM label_tag_raw WHERE CURRENT OF tag_cursor;
          END;
        ELSE
          CLOSE tag_cursor;
          EXIT;
        END IF;
      END LOOP;

      OPEN tag_cursor NO SCROLL FOR SELECT * FROM label_tag WHERE tag = ufw_tag.id FOR UPDATE;
      LOOP
        MOVE tag_cursor;
        IF FOUND THEN
          BEGIN
            UPDATE label_tag SET tag = existing_cfw_tag_id WHERE CURRENT OF tag_cursor;
          EXCEPTION WHEN unique_violation THEN
            DELETE FROM label_tag WHERE CURRENT OF tag_cursor;
          END;
        ELSE
          CLOSE tag_cursor;
          EXIT;
        END IF;
      END LOOP;

      OPEN tag_cursor NO SCROLL FOR SELECT * FROM place_tag_raw WHERE tag = ufw_tag.id FOR UPDATE;
      LOOP
        MOVE tag_cursor;
        IF FOUND THEN
          BEGIN
            UPDATE place_tag_raw SET tag = existing_cfw_tag_id WHERE CURRENT OF tag_cursor;
          EXCEPTION WHEN unique_violation THEN
            DELETE FROM place_tag_raw WHERE CURRENT OF tag_cursor;
          END;
        ELSE
          CLOSE tag_cursor;
          EXIT;
        END IF;
      END LOOP;

      OPEN tag_cursor NO SCROLL FOR SELECT * FROM place_tag WHERE tag = ufw_tag.id FOR UPDATE;
      LOOP
        MOVE tag_cursor;
        IF FOUND THEN
          BEGIN
            UPDATE place_tag SET tag = existing_cfw_tag_id WHERE CURRENT OF tag_cursor;
          EXCEPTION WHEN unique_violation THEN
            DELETE FROM place_tag WHERE CURRENT OF tag_cursor;
          END;
        ELSE
          CLOSE tag_cursor;
          EXIT;
        END IF;
      END LOOP;

      OPEN tag_cursor NO SCROLL FOR SELECT * FROM recording_tag_raw WHERE tag = ufw_tag.id FOR UPDATE;
      LOOP
        MOVE tag_cursor;
        IF FOUND THEN
          BEGIN
            UPDATE recording_tag_raw SET tag = existing_cfw_tag_id WHERE CURRENT OF tag_cursor;
          EXCEPTION WHEN unique_violation THEN
            DELETE FROM recording_tag_raw WHERE CURRENT OF tag_cursor;
          END;
        ELSE
          CLOSE tag_cursor;
          EXIT;
        END IF;
      END LOOP;

      OPEN tag_cursor NO SCROLL FOR SELECT * FROM recording_tag WHERE tag = ufw_tag.id FOR UPDATE;
      LOOP
        MOVE tag_cursor;
        IF FOUND THEN
          BEGIN
            UPDATE recording_tag SET tag = existing_cfw_tag_id WHERE CURRENT OF tag_cursor;
          EXCEPTION WHEN unique_violation THEN
            DELETE FROM recording_tag WHERE CURRENT OF tag_cursor;
          END;
        ELSE
          CLOSE tag_cursor;
          EXIT;
        END IF;
      END LOOP;

      OPEN tag_cursor NO SCROLL FOR SELECT * FROM release_tag_raw WHERE tag = ufw_tag.id FOR UPDATE;
      LOOP
        MOVE tag_cursor;
        IF FOUND THEN
          BEGIN
            UPDATE release_tag_raw SET tag = existing_cfw_tag_id WHERE CURRENT OF tag_cursor;
          EXCEPTION WHEN unique_violation THEN
            DELETE FROM release_tag_raw WHERE CURRENT OF tag_cursor;
          END;
        ELSE
          CLOSE tag_cursor;
          EXIT;
        END IF;
      END LOOP;

      OPEN tag_cursor NO SCROLL FOR SELECT * FROM release_tag WHERE tag = ufw_tag.id FOR UPDATE;
      LOOP
        MOVE tag_cursor;
        IF FOUND THEN
          BEGIN
            UPDATE release_tag SET tag = existing_cfw_tag_id WHERE CURRENT OF tag_cursor;
          EXCEPTION WHEN unique_violation THEN
            DELETE FROM release_tag WHERE CURRENT OF tag_cursor;
          END;
        ELSE
          CLOSE tag_cursor;
          EXIT;
        END IF;
      END LOOP;

      OPEN tag_cursor NO SCROLL FOR SELECT * FROM release_group_tag_raw WHERE tag = ufw_tag.id FOR UPDATE;
      LOOP
        MOVE tag_cursor;
        IF FOUND THEN
          BEGIN
            UPDATE release_group_tag_raw SET tag = existing_cfw_tag_id WHERE CURRENT OF tag_cursor;
          EXCEPTION WHEN unique_violation THEN
            DELETE FROM release_group_tag_raw WHERE CURRENT OF tag_cursor;
          END;
        ELSE
          CLOSE tag_cursor;
          EXIT;
        END IF;
      END LOOP;

      OPEN tag_cursor NO SCROLL FOR SELECT * FROM release_group_tag WHERE tag = ufw_tag.id FOR UPDATE;
      LOOP
        MOVE tag_cursor;
        IF FOUND THEN
          BEGIN
            UPDATE release_group_tag SET tag = existing_cfw_tag_id WHERE CURRENT OF tag_cursor;
          EXCEPTION WHEN unique_violation THEN
            DELETE FROM release_group_tag WHERE CURRENT OF tag_cursor;
          END;
        ELSE
          CLOSE tag_cursor;
          EXIT;
        END IF;
      END LOOP;

      OPEN tag_cursor NO SCROLL FOR SELECT * FROM series_tag_raw WHERE tag = ufw_tag.id FOR UPDATE;
      LOOP
        MOVE tag_cursor;
        IF FOUND THEN
          BEGIN
            UPDATE series_tag_raw SET tag = existing_cfw_tag_id WHERE CURRENT OF tag_cursor;
          EXCEPTION WHEN unique_violation THEN
            DELETE FROM series_tag_raw WHERE CURRENT OF tag_cursor;
          END;
        ELSE
          CLOSE tag_cursor;
          EXIT;
        END IF;
      END LOOP;

      OPEN tag_cursor NO SCROLL FOR SELECT * FROM series_tag WHERE tag = ufw_tag.id FOR UPDATE;
      LOOP
        MOVE tag_cursor;
        IF FOUND THEN
          BEGIN
            UPDATE series_tag SET tag = existing_cfw_tag_id WHERE CURRENT OF tag_cursor;
          EXCEPTION WHEN unique_violation THEN
            DELETE FROM series_tag WHERE CURRENT OF tag_cursor;
          END;
        ELSE
          CLOSE tag_cursor;
          EXIT;
        END IF;
      END LOOP;

      OPEN tag_cursor NO SCROLL FOR SELECT * FROM work_tag_raw WHERE tag = ufw_tag.id FOR UPDATE;
      LOOP
        MOVE tag_cursor;
        IF FOUND THEN
          BEGIN
            UPDATE work_tag_raw SET tag = existing_cfw_tag_id WHERE CURRENT OF tag_cursor;
          EXCEPTION WHEN unique_violation THEN
            DELETE FROM work_tag_raw WHERE CURRENT OF tag_cursor;
          END;
        ELSE
          CLOSE tag_cursor;
          EXIT;
        END IF;
      END LOOP;

      OPEN tag_cursor NO SCROLL FOR SELECT * FROM work_tag WHERE tag = ufw_tag.id FOR UPDATE;
      LOOP
        MOVE tag_cursor;
        IF FOUND THEN
          BEGIN
            UPDATE work_tag SET tag = existing_cfw_tag_id WHERE CURRENT OF tag_cursor;
          EXCEPTION WHEN unique_violation THEN
            DELETE FROM work_tag WHERE CURRENT OF tag_cursor;
          END;
        ELSE
          CLOSE tag_cursor;
          EXIT;
        END IF;
      END LOOP;

      DELETE FROM tag WHERE id = ufw_tag.id;
    END IF;
  END LOOP;
END
$$;

ALTER TABLE tag DROP CONSTRAINT IF EXISTS control_for_whitespace;
ALTER TABLE tag DROP CONSTRAINT IF EXISTS only_non_empty;

ALTER TABLE tag
  ADD CONSTRAINT control_for_whitespace CHECK (controlled_for_whitespace(name)),
  ADD CONSTRAINT only_non_empty CHECK (name != '');

COMMIT;
