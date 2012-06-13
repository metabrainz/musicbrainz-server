BEGIN;

-------------------------------------------------------------------
-- Find artists that are empty, and have not been updated within the
-- last 1 days
-------------------------------------------------------------------

CREATE OR REPLACE FUNCTION empty_artists() RETURNS SETOF artist AS
$BODY$
DECLARE
    artist_row artist%rowtype;
BEGIN
    FOR artist_row IN
        SELECT * FROM artist
        WHERE edits_pending = 0
          AND (last_updated < NOW() - '1 day'::INTERVAL OR
               last_updated IS NULL)
          AND NOT EXISTS (
            SELECT TRUE FROM edit_artist
            WHERE edit_artist.artist = artist.id
            AND edit_artist.status = 1
            LIMIT 1
          )
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

-------------------------------------------------------------------
-- Find labels that are empty, and have not been updated within the
-- last 1 day
-------------------------------------------------------------------

CREATE OR REPLACE FUNCTION empty_labels() RETURNS SETOF label AS
$BODY$
DECLARE
    label_row label%rowtype;
BEGIN
    FOR label_row IN
        SELECT * FROM label
        WHERE edits_pending = 0
          AND (last_updated < NOW() - '1 day'::INTERVAL OR
               last_updated IS NULL)
          AND NOT EXISTS (
            SELECT TRUE FROM edit_label
            WHERE edit_label.label = label.id
            AND edit_label.status = 1
            LIMIT 1
          )
    LOOP
        CONTINUE WHEN
        (
            SELECT TRUE FROM release_label
             WHERE label = label_row.id
             LIMIT 1
        ) OR
        (
            SELECT TRUE FROM l_artist_label
             WHERE entity1 = label_row.id
             LIMIT 1
        ) OR
        (
            SELECT TRUE FROM l_label_label
             WHERE entity0 = label_row.id OR entity1 = label_row.id
             LIMIT 1
        ) OR
        (
            SELECT TRUE FROM l_label_recording
             WHERE entity0 = label_row.id
             LIMIT 1
        ) OR
        (
            SELECT TRUE FROM l_label_release
             WHERE entity0 = label_row.id
             LIMIT 1
        ) OR
        (
            SELECT TRUE FROM l_label_release_group
             WHERE entity0 = label_row.id
             LIMIT 1
        ) OR
        (
            SELECT TRUE FROM l_label_url
             WHERE entity0 = label_row.id
             LIMIT 1
        ) OR
        (
            SELECT TRUE FROM l_label_work
             WHERE entity0 = label_row.id
             LIMIT 1
        );
        RETURN NEXT label_row;
    END LOOP;
END
$BODY$
LANGUAGE 'plpgsql' ;

-------------------------------------------------------------------
-- Find works that are empty, and have not been updated within the
-- last 1 day
-------------------------------------------------------------------

CREATE OR REPLACE FUNCTION empty_works() RETURNS SETOF work AS
$BODY$
DECLARE
    work_row work%rowtype;
BEGIN
    FOR work_row IN
        SELECT * FROM work
        WHERE edits_pending = 0
          AND (last_updated < NOW() - '1 day'::INTERVAL OR
               last_updated IS NULL)
          AND NOT EXISTS (
            SELECT TRUE FROM edit_work
            JOIN edit ON edit.id = edit_work.edit
            WHERE edit_work.work = work.id
            AND edit.status = 1
            LIMIT 1
          )
    LOOP
        CONTINUE WHEN
        (
            SELECT TRUE FROM l_artist_work
             WHERE entity1 = work_row.id
             LIMIT 1
        ) OR
        (
            SELECT TRUE FROM l_label_work
             WHERE entity1 = work_row.id
             LIMIT 1
        ) OR
        (
            SELECT TRUE FROM l_recording_work
             WHERE entity1 = work_row.id
             LIMIT 1
        ) OR
        (
            SELECT TRUE FROM l_release_work
             WHERE entity1 = work_row.id
             LIMIT 1
        ) OR
        (
            SELECT TRUE FROM l_release_group_work
             WHERE entity1 = work_row.id
             LIMIT 1
        ) OR
        (
            SELECT TRUE FROM l_url_work
             WHERE entity1 = work_row.id
             LIMIT 1
        ) OR
        (
            SELECT TRUE FROM l_work_work
             WHERE entity0 = work_row.id OR entity1 = work_row.id
             LIMIT 1
        );
        RETURN NEXT work_row;
    END LOOP;
END
$BODY$
LANGUAGE 'plpgsql' ;

COMMIT;
