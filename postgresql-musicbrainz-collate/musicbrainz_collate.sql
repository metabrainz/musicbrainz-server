
-- This line is used by admin/InitDb.pl to set the schema. Don't remove.
SET search_path = public;

CREATE OR REPLACE FUNCTION
  musicbrainz_collate(TEXT)
RETURNS
  BYTEA
AS
  'musicbrainz_collate.so', 'musicbrainz_collate'
LANGUAGE
  C
STRICT
IMMUTABLE;
