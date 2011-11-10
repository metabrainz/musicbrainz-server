BEGIN;

CREATE TABLE autoeditor_election
(
    id                  SERIAL,
    candidate           INTEGER NOT NULL, -- references editor.id
    proposer            INTEGER NOT NULL, -- references editor.id
    seconder_1          INTEGER, -- references editor.id
    seconder_2          INTEGER, -- references editor.id
    status              INTEGER NOT NULL DEFAULT 1
                            CHECK (status IN (1,2,3,4,5,6)),
                            -- 1 : has proposer
                            -- 2 : has seconder_1
                            -- 3 : has seconder_2 (voting open)
                            -- 4 : accepted!
                            -- 5 : rejected
                            -- 6 : cancelled (by proposer)
    yes_votes           INTEGER NOT NULL DEFAULT 0,
    no_votes            INTEGER NOT NULL DEFAULT 0,
    propose_time        TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    open_time           TIMESTAMP WITH TIME ZONE,
    close_time          TIMESTAMP WITH TIME ZONE
);

CREATE TABLE autoeditor_election_vote
(
    id                  SERIAL,
    autoeditor_election INTEGER NOT NULL, -- references autoeditor_election.id
    voter               INTEGER NOT NULL, -- references editor.id
    vote                INTEGER NOT NULL CHECK (vote IN (-1,0,1)),
    vote_time           TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

ALTER TABLE autoeditor_election ADD CONSTRAINT autoeditor_election_pkey PRIMARY KEY (id);
ALTER TABLE autoeditor_election_vote ADD CONSTRAINT autoeditor_election_vote_pkey PRIMARY KEY (id);

COMMIT;

