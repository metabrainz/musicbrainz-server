BEGIN;

CREATE TABLE echoprint
(
    id                  SERIAL,
    echoprint           CHAR(18) NOT NULL,
    version             INTEGER NOT NULL -- references clientversion.id
);

CREATE TABLE recording_echoprint
(
    id                  SERIAL,
    echoprint           INTEGER NOT NULL, -- references echoprint.id
    recording           INTEGER NOT NULL, -- references recording.id
    edits_pending       INTEGER NOT NULL DEFAULT 0,
    created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE echoprint ADD CONSTRAINT echoprint_pkey PRIMARY KEY (id);
ALTER TABLE recording_echoprint ADD CONSTRAINT recording_echoprint_pkey PRIMARY KEY (id);

ALTER TABLE echoprint
   ADD CONSTRAINT echoprint_fk_version
   FOREIGN KEY (version)
   REFERENCES clientversion(id);

ALTER TABLE recording_echoprint
   ADD CONSTRAINT recording_echoprint_fk_echoprint
   FOREIGN KEY (echoprint)
   REFERENCES echoprint(id);

ALTER TABLE recording_echoprint
   ADD CONSTRAINT recording_echoprint_fk_recording
   FOREIGN KEY (recording)
   REFERENCES recording(id);

CREATE UNIQUE INDEX echoprint_idx_echoprint ON echoprint (echoprint);
CREATE UNIQUE INDEX recording_echoprint_idx_uniq ON recording_echoprint (recording, echoprint);
CREATE INDEX recording_echoprint_idx_echoprint ON recording_echoprint (echoprint);

SELECT setval('echoprint_id_seq', (SELECT MAX(id) FROM echoprint));
SELECT setval('recording_echoprint_id_seq', (SELECT MAX(id) FROM recording_echoprint));

COMMIT;
