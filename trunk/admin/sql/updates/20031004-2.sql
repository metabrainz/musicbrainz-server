-- Abstract: add unique index to albumjoin on (album, track)
-- Abstract: add unique index to trmjoin on (trm, track)

\set ON_ERROR_STOP 1

BEGIN;

CREATE UNIQUE INDEX albumjoin_albumtrack ON albumjoin (album, track);
CREATE UNIQUE INDEX trmjoin_trmtrack ON trmjoin (trm, track);

COMMIT;
