-- Abstract: make moderator.name unique

\set ON_ERROR_STOP 1

BEGIN;

DROP INDEX moderator_nameindex;
CREATE UNIQUE INDEX moderator_nameindex ON moderator (name);

COMMIT;

-- vi: set ts=4 sw=4 et :
