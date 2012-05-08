-- Automatically generated, do not edit.
\unset ON_ERROR_STOP

SELECT setval('art_type_id_seq', (SELECT MAX(id) FROM art_type));
