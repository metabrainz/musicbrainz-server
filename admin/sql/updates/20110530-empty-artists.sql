BEGIN;

CREATE OR REPLACE FUNCTION empty_artists() RETURNS SETOF artist AS
$BODY$
DECLARE
    artist_row artist%rowtype;
BEGIN
    FOR artist_row IN
        SELECT * FROM artist
        WHERE edits_pending = 0
          AND last_updated < NOW() - '@ 1 day'::INTERVAL
    LOOP
        CONTINUE WHEN
        (
            SELECT TRUE FROM artist_credit_name
             WHERE artist = artist_row.id
             LIMIT 1
        ) OR
        (
            SELECT TRUE FROM l_artist_recording
             WHERE entity0 = artist_row.id
             LIMIT 1
        ) OR
        (
            SELECT TRUE FROM l_artist_work
             WHERE entity0 = artist_row.id
             LIMIT 1
        ) OR
        (
            SELECT TRUE FROM l_artist_url
             WHERE entity0 = artist_row.id
             LIMIT 1
        ) OR
        (
            SELECT TRUE FROM l_artist_artist
             WHERE entity0 = artist_row.id OR entity1 = artist_row.id
             LIMIT 1
        ) OR
        (
            SELECT TRUE FROM l_artist_label
             WHERE entity0 = artist_row.id
             LIMIT 1
        ) OR
        (
            SELECT TRUE FROM l_artist_release
             WHERE entity0 = artist_row.id
             LIMIT 1
        ) OR
        (
            SELECT TRUE FROM l_artist_release_group WHERE entity0 = artist_row.id
             LIMIT 1
        );
        RETURN NEXT artist_row;
    END LOOP;
END
$BODY$
LANGUAGE 'plpgsql' ;

COMMIT;
