-- Automatically generated, do not edit.
\unset ON_ERROR_STOP

SET search_path = 'cover_art_archive';

SELECT setval('art_type_id_seq', (SELECT MAX(id) FROM art_type));
