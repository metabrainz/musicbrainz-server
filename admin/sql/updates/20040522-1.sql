-- Abstract: create automod vote tables

\set ON_ERROR_STOP 1

BEGIN;

CREATE TABLE automod_election
(
    id                  SERIAL,
    candidate           INTEGER NOT NULL,
    proposer            INTEGER NOT NULL,
    seconder_1          INTEGER,
    seconder_2          INTEGER,
    status              INTEGER NOT NULL DEFAULT 1
        CONSTRAINT automod_election_chk1 CHECK (status IN (1,2,3,4,5,6)),
        -- 1 : has proposer
        -- 2 : has seconder_1
        -- 3 : has seconder_2 (voting open)
        -- 4 : accepted!
        -- 5 : rejected
        -- 6 : cancelled (by proposer)
    yesvotes            INTEGER NOT NULL DEFAULT 0,
    novotes             INTEGER NOT NULL DEFAULT 0,
    proposetime         TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    opentime            TIMESTAMP WITH TIME ZONE,
    closetime           TIMESTAMP WITH TIME ZONE
);

ALTER TABLE automod_election
    ADD CONSTRAINT automod_election_fk_candidate
    FOREIGN KEY (candidate)
    REFERENCES moderator(id);

ALTER TABLE automod_election
    ADD CONSTRAINT automod_election_fk_proposer
    FOREIGN KEY (proposer)
    REFERENCES moderator(id);

ALTER TABLE automod_election
    ADD CONSTRAINT automod_election_fk_seconder_1
    FOREIGN KEY (seconder_1)
    REFERENCES moderator(id);

ALTER TABLE automod_election
    ADD CONSTRAINT automod_election_fk_seconder_2
    FOREIGN KEY (seconder_2)
    REFERENCES moderator(id);

ALTER TABLE automod_election ADD CONSTRAINT automod_election_pkey PRIMARY KEY (id);

CREATE TABLE automod_election_vote
(
    id                  SERIAL,
    automod_election    INTEGER NOT NULL,
    voter               INTEGER NOT NULL,
    vote                INTEGER NOT NULL,
        CONSTRAINT automod_election_vote_chk1 CHECK (vote IN (-1,0,1)),
    votetime            TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

ALTER TABLE automod_election_vote
    ADD CONSTRAINT automod_election_vote_fk_automod_election
    FOREIGN KEY (automod_election)
    REFERENCES automod_election(id);

ALTER TABLE automod_election_vote
    ADD CONSTRAINT automod_election_vote_fk_voter
    FOREIGN KEY (voter)
    REFERENCES moderator(id);

ALTER TABLE automod_election_vote ADD CONSTRAINT automod_election_vote_pkey PRIMARY KEY (id);

COMMIT;

-- vi: set ts=4 sw=4 et :
