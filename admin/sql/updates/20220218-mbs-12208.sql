\set ON_ERROR_STOP 1

BEGIN;

CREATE OR REPLACE FUNCTION get_artist_release_group_rows(
    release_group_id INTEGER
) RETURNS SETOF artist_release_group AS $$
BEGIN
    -- PostgreSQL 12 generates a vastly more efficient plan when only
    -- one release group ID is passed. A condition like
    -- `rg.id = any(...)` can be over 200x slower, even with only one
    -- release group ID in the array.
    RETURN QUERY EXECUTE $SQL$
        SELECT DISTINCT ON (a_rg.artist, rg.id)
            a_rg.is_track_artist,
            a_rg.artist,
            -- Withdrawn releases were once official by definition
            bool_and(r.status IS NOT NULL AND r.status != 1 AND r.status != 5),
            rg.type::SMALLINT,
            array_agg(
                DISTINCT st.secondary_type ORDER BY st.secondary_type)
                FILTER (WHERE st.secondary_type IS NOT NULL
            )::SMALLINT[],
            integer_date(
                rgm.first_release_date_year,
                rgm.first_release_date_month,
                rgm.first_release_date_day
            ),
            left(rg.name, 1)::CHAR(1),
            rg.id
        FROM (
            SELECT FALSE AS is_track_artist, rgacn.artist, rg.id AS release_group
            FROM release_group rg
            JOIN artist_credit_name rgacn ON rgacn.artist_credit = rg.artist_credit
            UNION ALL
            SELECT TRUE AS is_track_artist, tacn.artist, r.release_group
            FROM release r
            JOIN medium m ON m.release = r.id
            JOIN track t ON t.medium = m.id
            JOIN artist_credit_name tacn ON tacn.artist_credit = t.artist_credit
        ) a_rg
        JOIN release_group rg ON rg.id = a_rg.release_group
        LEFT JOIN release r ON r.release_group = rg.id
        JOIN release_group_meta rgm ON rgm.id = rg.id
        LEFT JOIN release_group_secondary_type_join st ON st.release_group = rg.id
    $SQL$ || (CASE WHEN release_group_id IS NULL THEN '' ELSE 'WHERE rg.id = $1' END) ||
    $SQL$
        GROUP BY a_rg.is_track_artist, a_rg.artist, rgm.id, rg.id
        ORDER BY a_rg.artist, rg.id, a_rg.is_track_artist
    $SQL$
    USING release_group_id;
END;
$$ LANGUAGE plpgsql;

-- We update the table for any existing RGs containing withdrawn releases
-- with this one-off script; the updated function will keep it up after this.
DO $$
DECLARE
    release_group_ids INTEGER[];
    release_group_id INTEGER;
BEGIN
    SELECT array_agg(DISTINCT rg.id)
    INTO release_group_ids
    FROM release_group rg
    JOIN release r ON rg.id = r.release_group
    WHERE r.status = 5; -- Withdrawn

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
END $$;

COMMIT;
