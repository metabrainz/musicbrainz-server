\set ON_ERROR_STOP 1

BEGIN;

CREATE OR REPLACE FUNCTION apply_artist_release_pending_updates()
RETURNS trigger AS $$
DECLARE
    release_ids INTEGER[];
    release_id INTEGER;
BEGIN
    -- DO NOT modify any replicated tables in this function; it's used
    -- by a trigger on slaves.
    WITH pending AS (
        DELETE FROM artist_release_pending_update
        RETURNING release
    )
    SELECT array_agg(DISTINCT release)
    INTO release_ids
    FROM pending;

    IF coalesce(array_length(release_ids, 1), 0) > 0 THEN
        -- If the user hasn't generated `artist_release`, then we
        -- shouldn't update or insert to it. MBS determines whether to
        -- use this table based on it being non-empty, so a partial
        -- table would manifest as partial data on the website and
        -- webservice.
        PERFORM 1 FROM artist_release LIMIT 1;
        IF FOUND THEN
            DELETE FROM artist_release WHERE release = any(release_ids);

            FOREACH release_id IN ARRAY release_ids LOOP
                -- We handle each release ID separately because the
                -- `get_artist_release_rows` query can be planned much
                -- more efficiently that way.
                INSERT INTO artist_release
                SELECT * FROM get_artist_release_rows(release_id);
            END LOOP;
        END IF;
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION apply_artist_release_group_pending_updates()
RETURNS trigger AS $$
DECLARE
    release_group_ids INTEGER[];
    release_group_id INTEGER;
BEGIN
    -- DO NOT modify any replicated tables in this function; it's used
    -- by a trigger on slaves.
    WITH pending AS (
        DELETE FROM artist_release_group_pending_update
        RETURNING release_group
    )
    SELECT array_agg(DISTINCT release_group)
    INTO release_group_ids
    FROM pending;

    IF coalesce(array_length(release_group_ids, 1), 0) > 0 THEN
        -- If the user hasn't generated `artist_release_group`, then we
        -- shouldn't update or insert to it. MBS determines whether to
        -- use this table based on it being non-empty, so a partial
        -- table would manifest as partial data on the website and
        -- webservice.
        PERFORM 1 FROM artist_release_group LIMIT 1;
        IF FOUND THEN
            DELETE FROM artist_release_group WHERE release_group = any(release_group_ids);

            FOREACH release_group_id IN ARRAY release_group_ids LOOP
                -- We handle each release group ID separately because
                -- the `get_artist_release_group_rows` query can be
                -- planned much more efficiently that way.
                INSERT INTO artist_release_group
                SELECT * FROM get_artist_release_group_rows(release_group_id);
            END LOOP;
        END IF;
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

COMMIT;
