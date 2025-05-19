\set ON_ERROR_STOP 1

BEGIN;

SET search_path = 'cover_art_archive';

CREATE OR REPLACE VIEW index_listing AS
SELECT cover_art.*,
  (edit.close_time IS NOT NULL) AS approved,
  coalesce(cover_art.id = (SELECT id FROM cover_art_archive.cover_art_type
                   JOIN cover_art_archive.cover_art ca_front USING (id)
                   WHERE ca_front.release = cover_art.release
                   AND type_id = 1
                   ORDER BY ca_front.ordering
                   LIMIT 1), FALSE) AS is_front,
  coalesce(cover_art.id = (SELECT id FROM cover_art_archive.cover_art_type
                   JOIN cover_art_archive.cover_art ca_front USING (id)
                   WHERE ca_front.release = cover_art.release
                   AND type_id = 2
                   ORDER BY ca_front.ordering
                   LIMIT 1), FALSE) AS is_back,
  array(SELECT art_type.name
        FROM cover_art_archive.cover_art_type
        JOIN cover_art_archive.art_type ON cover_art_type.type_id = art_type.id
        WHERE cover_art_type.id = cover_art.id) AS types
FROM cover_art_archive.cover_art
LEFT JOIN musicbrainz.edit ON edit.id = cover_art.edit;

COMMIT;
