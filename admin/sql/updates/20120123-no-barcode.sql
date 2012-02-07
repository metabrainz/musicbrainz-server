-- MBS-2799, convert releases with barcode set to all zeroes to the
-- empty string, to indicate the release has no barcode.

BEGIN;

UPDATE release SET barcode = '' WHERE barcode SIMILAR TO '00+';

COMMIT;
