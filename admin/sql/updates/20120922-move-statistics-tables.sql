BEGIN;
  CREATE SCHEMA musicbrainz_statistics;
  ALTER TABLE statistic SET SCHEMA musicbrainz_statistics;
  ALTER TABLE statistic_event SET SCHEMA musicbrainz_statistics;
COMMIT;
