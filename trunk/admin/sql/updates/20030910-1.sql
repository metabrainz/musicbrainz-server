-- Abstract: add moderator_preference.id and moderator_subscribe_artist.id

\set ON_ERROR_STOP 1

BEGIN;

-- moderator_preference

ALTER TABLE moderator_preference
    DROP CONSTRAINT moderator_preference_pkey;
ALTER TABLE moderator_preference
    DROP CONSTRAINT moderator_preference_fk_moderator;
ALTER TABLE moderator_preference
    RENAME TO moderator_preference_old;
    
CREATE TABLE moderator_preference
(
        id              SERIAL PRIMARY KEY,
        moderator       INTEGER NOT NULL, -- references moderator
        name            VARCHAR(50) NOT NULL,
        value           VARCHAR(100) NOT NULL,
        UNIQUE (moderator, name)
);

INSERT INTO moderator_preference (moderator, name, value)
    SELECT * FROM moderator_preference_old;
DROP TABLE moderator_preference_old;

ALTER TABLE moderator_preference
    ADD CONSTRAINT moderator_preference_fk_moderator
    FOREIGN KEY (moderator)
    REFERENCES moderator(id);

-- moderator_subscribe_artist

ALTER TABLE moderator_subscribe_artist
    DROP CONSTRAINT moderator_subscribe_artist_pkey;
ALTER TABLE moderator_subscribe_artist
    DROP CONSTRAINT modsubartist_fk_moderator;
ALTER TABLE moderator_subscribe_artist
    RENAME TO moderator_subscribe_artist_old;
    
CREATE TABLE moderator_subscribe_artist
(
        id              SERIAL PRIMARY KEY,
        moderator       INTEGER NOT NULL, -- references moderator
        artist          INTEGER NOT NULL, -- weakly references artist
        lastmodsent     INTEGER NOT NULL DEFAULT NEXTVAL('moderation_id_seq'), -- weakly references moderation
        deletedbymod    INTEGER NOT NULL DEFAULT 0, -- weakly references moderation
        mergedbymod     INTEGER NOT NULL DEFAULT 0, -- weakly references moderation
        UNIQUE (moderator, artist)
);

INSERT INTO moderator_subscribe_artist (moderator, artist, lastmodsent, deletedbymod, mergedbymod)
    SELECT * FROM moderator_subscribe_artist_old;
DROP TABLE moderator_subscribe_artist_old;

ALTER TABLE moderator_subscribe_artist
    ADD CONSTRAINT modsubartist_fk_moderator
    FOREIGN KEY (moderator)
    REFERENCES moderator(id);

COMMIT;

-- vi: set ts=4 sw=4 et :
