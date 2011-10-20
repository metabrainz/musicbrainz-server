BEGIN;

ALTER TABLE autoeditor_election
   ADD CONSTRAINT autoeditor_election_fk_candidate
   FOREIGN KEY (candidate)
   REFERENCES editor(id);

ALTER TABLE autoeditor_election
   ADD CONSTRAINT autoeditor_election_fk_proposer
   FOREIGN KEY (proposer)
   REFERENCES editor(id);

ALTER TABLE autoeditor_election
   ADD CONSTRAINT autoeditor_election_fk_seconder_1
   FOREIGN KEY (seconder_1)
   REFERENCES editor(id);

ALTER TABLE autoeditor_election
   ADD CONSTRAINT autoeditor_election_fk_seconder_2
   FOREIGN KEY (seconder_2)
   REFERENCES editor(id);

ALTER TABLE autoeditor_election_vote
   ADD CONSTRAINT autoeditor_election_vote_fk_autoeditor_election
   FOREIGN KEY (autoeditor_election)
   REFERENCES autoeditor_election(id);

ALTER TABLE autoeditor_election_vote
   ADD CONSTRAINT autoeditor_election_vote_fk_voter
   FOREIGN KEY (voter)
   REFERENCES editor(id);

COMMIT;

