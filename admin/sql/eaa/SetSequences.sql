-- Automatically generated, do not edit.
\unset ON_ERROR_STOP

SET search_path = 'event_art_archive';

SELECT setval('art_type_id_seq', COALESCE((SELECT MAX(id) FROM art_type), 0) + 1, FALSE);
