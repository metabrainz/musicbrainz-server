\set ON_ERROR_STOP 1

BEGIN;

CREATE TABLE artist_isni
(
    artist              INTEGER NOT NULL, -- PK, references artist.id
    isni                CHAR(16) NOT NULL CHECK (isni ~ E'^\\d{15}[\\dX]$'), -- PK
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE artist_isni ADD CONSTRAINT artist_isni_pkey PRIMARY KEY (artist, isni);

CREATE TABLE label_isni
(
    label              INTEGER NOT NULL, -- PK, references label.id
    isni                CHAR(16) NOT NULL CHECK (isni ~ E'^\\d{15}[\\dX]$'), -- PK
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE label_isni ADD CONSTRAINT label_isni_pkey PRIMARY KEY (label, isni);

COMMIT;
