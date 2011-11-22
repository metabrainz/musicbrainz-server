BEGIN;

CREATE OR REPLACE FUNCTION empty_urls() RETURNS SETOF url AS
$BODY$
DECLARE
    url_row url%rowtype;
BEGIN
    FOR url_row IN
        SELECT * FROM url
        WHERE edits_pending = 0
          AND (last_updated < NOW() - '1 day'::INTERVAL OR
               last_updated IS NULL)
    LOOP
        CONTINUE WHEN
        (
            SELECT TRUE FROM l_artist_url
             WHERE entity1 = url_row.id
             LIMIT 1
        ) OR
        (
            SELECT TRUE FROM l_label_url
             WHERE entity1 = url_row.id
             LIMIT 1
        ) OR
        (
            SELECT TRUE FROM l_recording_url
             WHERE entity1 = url_row.id
             LIMIT 1
        ) OR
        (
            SELECT TRUE FROM l_release_url
             WHERE entity1 = url_row.id
             LIMIT 1
        ) OR
        (
            SELECT TRUE FROM l_release_group_url
             WHERE entity1 = url_row.id
             LIMIT 1
        ) OR
        (
            SELECT TRUE FROM l_url_url
             WHERE entity0 = url_row.id
                OR entity1 = url_row.id
             LIMIT 1
        ) OR
        (
            SELECT TRUE FROM l_url_work
             WHERE entity0 = url_row.id
             LIMIT 1
        );
        RETURN NEXT url_row;
    END LOOP;
END
$BODY$
LANGUAGE 'plpgsql' ;

DELETE FROM url WHERE id IN (SELECT id FROM empty_urls());

ROLLBACK;
