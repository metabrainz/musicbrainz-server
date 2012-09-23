-- Automatically generated, do not edit.
\unset ON_ERROR_STOP

SET search_path = 'musicbrainz_statistics';

SELECT setval('statistic_id_seq', (SELECT MAX(id) FROM statistic));
