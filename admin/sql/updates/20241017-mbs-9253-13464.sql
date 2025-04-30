\set ON_ERROR_STOP 1

BEGIN;

DROP TRIGGER IF EXISTS a_upd_release_group_primary_type ON release_group_primary_type;
DROP TRIGGER IF EXISTS a_upd_release_group_secondary_type ON release_group_secondary_type;

DROP TRIGGER IF EXISTS apply_artist_release_group_pending_updates ON release_group_primary_type;
DROP TRIGGER IF EXISTS apply_artist_release_group_pending_updates ON release_group_secondary_type;

DROP FUNCTION get_artist_release_group_rows(integer);

DROP INDEX artist_release_group_nonva_idx_sort;
DROP INDEX artist_release_group_va_idx_sort;

DROP TABLE artist_release_group_nonva;
DROP TABLE artist_release_group_va;
DROP TABLE artist_release_group;

CREATE TABLE artist_release_group (
    -- See comment for `artist_release.is_track_artist`.
    is_track_artist                     BOOLEAN NOT NULL,
    artist                              INTEGER NOT NULL, -- references artist.id, CASCADE
    unofficial                          BOOLEAN NOT NULL,
    primary_type_child_order            SMALLINT,
    primary_type                        SMALLINT,
    secondary_type_child_orders         SMALLINT[],
    secondary_types                     SMALLINT[],
    first_release_date                  INTEGER,
    name                                VARCHAR COLLATE musicbrainz NOT NULL,
    release_group                       INTEGER NOT NULL -- references release_group.id, CASCADE
) PARTITION BY LIST (is_track_artist);

CREATE TABLE artist_release_group_nonva
    PARTITION OF artist_release_group FOR VALUES IN (FALSE);

CREATE TABLE artist_release_group_va
    PARTITION OF artist_release_group FOR VALUES IN (TRUE);

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
            rgpt.child_order::SMALLINT,
            rg.type::SMALLINT,
            array_agg(
                DISTINCT rgst.child_order ORDER BY rgst.child_order)
                FILTER (WHERE rgst.child_order IS NOT NULL
            )::SMALLINT[],
            array_agg(
                DISTINCT st.secondary_type ORDER BY st.secondary_type)
                FILTER (WHERE st.secondary_type IS NOT NULL
            )::SMALLINT[],
            integer_date(
                rgm.first_release_date_year,
                rgm.first_release_date_month,
                rgm.first_release_date_day
            ),
            rg.name,
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
        LEFT JOIN release_group_primary_type rgpt ON rgpt.id = rg.type
        LEFT JOIN release_group_secondary_type_join st ON st.release_group = rg.id
        LEFT JOIN release_group_secondary_type rgst ON rgst.id = st.secondary_type
    $SQL$ || (CASE WHEN release_group_id IS NULL THEN '' ELSE 'WHERE rg.id = $1' END) ||
    $SQL$
        GROUP BY a_rg.is_track_artist, a_rg.artist, rgm.id, rg.id, rgpt.child_order
        ORDER BY a_rg.artist, rg.id, a_rg.is_track_artist
    $SQL$
    USING release_group_id;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_upd_release_group_primary_type_mirror()
RETURNS trigger AS $$
BEGIN
    -- DO NOT modify any replicated tables in this function; it's used
    -- by a trigger on mirrors.
    IF (NEW.child_order IS DISTINCT FROM OLD.child_order)
    THEN
        INSERT INTO artist_release_group_pending_update (
            SELECT id FROM release_group
            WHERE release_group.type = OLD.id
        );
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_upd_release_group_secondary_type_mirror()
RETURNS trigger AS $$
BEGIN
    -- DO NOT modify any replicated tables in this function; it's used
    -- by a trigger on mirrors.
    IF (NEW.child_order IS DISTINCT FROM OLD.child_order)
    THEN
        INSERT INTO artist_release_group_pending_update (
            SELECT release_group
            FROM release_group_secondary_type_join
            WHERE secondary_type = OLD.id
        );
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE INDEX artist_release_group_nonva_idx_sort ON artist_release_group_nonva (artist, unofficial, primary_type_child_order NULLS FIRST, primary_type NULLS FIRST, secondary_type_child_orders NULLS FIRST, secondary_types NULLS FIRST, first_release_date NULLS LAST, name, release_group);
CREATE INDEX artist_release_group_va_idx_sort ON artist_release_group_va (artist, unofficial, primary_type_child_order NULLS FIRST, primary_type NULLS FIRST, secondary_type_child_orders NULLS FIRST, secondary_types NULLS FIRST, first_release_date NULLS LAST, name, release_group);

CREATE UNIQUE INDEX artist_release_group_nonva_idx_uniq ON artist_release_group_nonva (release_group, artist);
CREATE UNIQUE INDEX artist_release_group_va_idx_uniq ON artist_release_group_va (release_group, artist);

COMMIT;
