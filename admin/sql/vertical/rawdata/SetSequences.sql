-- Automatically generated, do not edit.
\unset ON_ERROR_STOP

SELECT setval('edit_id_seq', (SELECT MAX(id) FROM edit));
SELECT setval('edit_note_id_seq', (SELECT MAX(id) FROM edit_note));
SELECT setval('vote_id_seq', (SELECT MAX(id) FROM vote));
SELECT setval('cdtoc_raw_id_seq', (SELECT MAX(id) FROM cdtoc_raw));
SELECT setval('release_raw_id_seq', (SELECT MAX(id) FROM release_raw));
SELECT setval('track_raw_id_seq', (SELECT MAX(id) FROM track_raw));
