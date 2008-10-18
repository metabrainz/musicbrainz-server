\set ON_ERROR_STOP 1
BEGIN;

CREATE TABLE artist_rating_raw
(
    artist              INTEGER NOT NULL,
    editor              INTEGER NOT NULL,
    rating              INTEGER NOT NULL
);
   	
CREATE TABLE artist_tag_raw
(
    artist              INTEGER NOT NULL,
    tag                 INTEGER NOT NULL,
    moderator           INTEGER NOT NULL
);

CREATE TABLE release_rating_raw
(
    release             INTEGER NOT NULL,
    editor              INTEGER NOT NULL,
    rating              INTEGER NOT NULL
);
   	
CREATE TABLE release_tag_raw
(
    release             INTEGER NOT NULL,
    tag                 INTEGER NOT NULL,
    moderator           INTEGER NOT NULL
);

CREATE TABLE track_rating_raw
(
    track               INTEGER NOT NULL,
    editor              INTEGER NOT NULL,
    rating              INTEGER NOT NULL
);
   	
CREATE TABLE track_tag_raw
(
    track               INTEGER NOT NULL,
    tag                 INTEGER NOT NULL,
    moderator           INTEGER NOT NULL
);

CREATE TABLE label_rating_raw
(
    label               INTEGER NOT NULL,
    editor              INTEGER NOT NULL,
    rating              INTEGER NOT NULL
);
   	
CREATE TABLE label_tag_raw
(
    label               INTEGER NOT NULL,
    tag                 INTEGER NOT NULL,
    moderator           INTEGER NOT NULL
);

COMMIT;

-- vi: set ts=4 sw=4 et :
