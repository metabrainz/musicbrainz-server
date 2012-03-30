BEGIN;

CREATE OR REPLACE FUNCTION orphaned_recordings() RETURNS SETOF recording AS
$$
DECLARE
    recording_row recording%rowtype;
BEGIN
    FOR recording_row IN
        SELECT recording.* FROM recording
        LEFT JOIN track ON track.recording = recording.id
        WHERE track.id IS NULL AND recording.edits_pending = 0
    LOOP
        CONTINUE WHEN
        ( SELECT TRUE
          FROM edit
          JOIN edit_recording ON edit.id = edit_recording.edit
          WHERE edit_recording.recording = recording_row.id
          AND edit.type IN (71, 207, 218) -- "Add recording", "add track" and "add track KV", respectively
          LIMIT 1 ) OR
        ( SELECT TRUE
          FROM recording_puid
          WHERE recording = recording_row.id
          LIMIT 1 ) OR
        ( SELECT TRUE FROM l_artist_recording        WHERE entity1 = recording_row.id LIMIT 1) OR
        ( SELECT TRUE FROM l_label_recording         WHERE entity1 = recording_row.id LIMIT 1) OR
        ( SELECT TRUE FROM l_recording_recording     WHERE entity0 = recording_row.id
                                                        OR entity1 = recording_row.id LIMIT 1) OR
        ( SELECT TRUE FROM l_recording_release       WHERE entity0 = recording_row.id LIMIT 1) OR
        ( SELECT TRUE FROM l_recording_release_group WHERE entity0 = recording_row.id LIMIT 1) OR
        ( SELECT TRUE FROM l_recording_work          WHERE entity0 = recording_row.id LIMIT 1) OR
        ( SELECT TRUE FROM l_recording_url           WHERE entity0 = recording_row.id LIMIT 1) OR
        ( SELECT TRUE FROM recording_tag             WHERE recording = recording_row.id LIMIT 1) OR
        ( SELECT TRUE FROM isrc                      WHERE recording = recording_row.id LIMIT 1) OR
        ( SELECT TRUE FROM recording_annotation      WHERE recording = recording_row.id LIMIT 1) OR
        ( SELECT TRUE FROM recording_rating_raw      WHERE recording = recording_row.id LIMIT 1) OR
        ( SELECT TRUE FROM recording_puid            WHERE recording = recording_row.id LIMIT 1);
        RETURN NEXT recording_row;
    END LOOP;
END;
$$ LANGUAGE 'plpgsql';

SELECT * INTO TEMPORARY tmp_orphans FROM orphaned_recordings();

DELETE FROM recording_gid_redirect USING tmp_orphans s WHERE new_id = s.id;
DELETE FROM recording_meta USING tmp_orphans s WHERE recording_meta.id = s.id;
DELETE FROM recording USING tmp_orphans s WHERE recording.id = s.id;

DROP FUNCTION orphaned_recordings();

COMMIT;
