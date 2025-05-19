\set ON_ERROR_STOP 1

BEGIN;

DROP FUNCTION get_artist_release_rows(integer);

DROP TABLE artist_release_nonva;
DROP TABLE artist_release_va;
DROP TABLE artist_release;

CREATE TABLE artist_release (
    is_track_artist                     BOOLEAN NOT NULL,
    artist                              INTEGER NOT NULL,
    first_release_date                  INTEGER,
    catalog_numbers                     TEXT[],
    country_code                        CHAR(2),
    barcode                             BIGINT,
    name                                VARCHAR COLLATE musicbrainz NOT NULL,
    release                             INTEGER NOT NULL
) PARTITION BY LIST (is_track_artist);

CREATE TABLE artist_release_nonva
    PARTITION OF artist_release FOR VALUES IN (FALSE);

CREATE TABLE artist_release_va
    PARTITION OF artist_release FOR VALUES IN (TRUE);

CREATE OR REPLACE FUNCTION get_artist_release_rows(
    release_id INTEGER
) RETURNS SETOF artist_release AS $$
BEGIN
    -- PostgreSQL 12 generates a vastly more efficient plan when only
    -- one release ID is passed. A condition like `r.id = any(...)`
    -- can be over 200x slower, even with only one release ID in the
    -- array.
    RETURN QUERY EXECUTE $SQL$
        SELECT DISTINCT ON (ar.artist, r.id)
            ar.is_track_artist,
            ar.artist,
            integer_date(rfrd.year, rfrd.month, rfrd.day) AS first_release_date,
            array_agg(
                DISTINCT rl.catalog_number ORDER BY rl.catalog_number
            ) FILTER (WHERE rl.catalog_number IS NOT NULL)::TEXT[] AS catalog_numbers,
            min(iso.code ORDER BY iso.code)::CHAR(2) AS country_code,
            left(regexp_replace(
                (CASE r.barcode WHEN '' THEN '0' ELSE r.barcode END),
                '[^0-9]+', '', 'g'
            ), 18)::BIGINT AS barcode,
            r.name,
            r.id
        FROM (
            SELECT FALSE AS is_track_artist, racn.artist, r.id AS release
            FROM release r
            JOIN artist_credit_name racn ON racn.artist_credit = r.artist_credit
            UNION ALL
            SELECT TRUE AS is_track_artist, tacn.artist, m.release
            FROM medium m
            JOIN track t ON t.medium = m.id
            JOIN artist_credit_name tacn ON tacn.artist_credit = t.artist_credit
        ) ar
        JOIN release r ON r.id = ar.release
        LEFT JOIN release_first_release_date rfrd ON rfrd.release = r.id
        LEFT JOIN release_label rl ON rl.release = r.id
        LEFT JOIN release_country rc ON rc.release = r.id
        LEFT JOIN iso_3166_1 iso ON iso.area = rc.country
    $SQL$ || (CASE WHEN release_id IS NULL THEN '' ELSE 'WHERE r.id = $1' END) ||
    $SQL$
        GROUP BY ar.is_track_artist, ar.artist, rfrd.release, r.id
        ORDER BY ar.artist, r.id, ar.is_track_artist
    $SQL$
    USING release_id;
END;
$$ LANGUAGE plpgsql;

CREATE INDEX artist_release_nonva_idx_sort ON artist_release_nonva (artist, first_release_date NULLS LAST, catalog_numbers NULLS LAST, country_code NULLS LAST, barcode NULLS LAST, name, release);
CREATE INDEX artist_release_va_idx_sort ON artist_release_va (artist, first_release_date NULLS LAST, catalog_numbers NULLS LAST, country_code NULLS LAST, barcode NULLS LAST, name, release);

CREATE UNIQUE INDEX artist_release_nonva_idx_uniq ON artist_release_nonva (release, artist);
CREATE UNIQUE INDEX artist_release_va_idx_uniq ON artist_release_va (release, artist);

COMMIT;
