\set ON_ERROR_STOP 1

BEGIN;

SET search_path = 'event_art_archive';

CREATE OR REPLACE VIEW index_listing AS
SELECT event_art.*,
  (edit.close_time IS NOT NULL) AS approved,
  coalesce(event_art.id = (SELECT id FROM event_art_archive.event_art_type
                   JOIN event_art_archive.event_art ea_front USING (id)
                   WHERE ea_front.event = event_art.event
                   AND type_id = 1
                   AND mime_type != 'application/pdf'
                   ORDER BY ea_front.ordering
                   LIMIT 1), FALSE) AS is_front,
  array(SELECT art_type.name
        FROM event_art_archive.event_art_type
        JOIN event_art_archive.art_type ON event_art_type.type_id = art_type.id
        WHERE event_art_type.id = event_art.id) AS types
FROM event_art_archive.event_art
LEFT JOIN musicbrainz.edit ON edit.id = event_art.edit;

COMMIT;
