
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
