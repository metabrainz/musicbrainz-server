BEGIN;

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

COMMIT;
