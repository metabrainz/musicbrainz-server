BEGIN;

DROP TABLE tracklist_index;

CREATE TABLE tracklist_index
(
    tracklist           INTEGER, -- PK
    toc                 CUBE
);

COMMIT;
