-- Abstract: add unique index to albumjoin on (album, track)

\set ON_ERROR_STOP 1

BEGIN;

CREATE UNIQUE INDEX albumjoin_albumtrack ON albumjoin (album, track);

COMMIT;
