BEGIN;

INSERT INTO autoeditor_election SELECT * FROM public.automod_election;
INSERT INTO autoeditor_election_vote SELECT * FROM public.automod_election_vote;

SELECT setval('autoeditor_election_id_seq', (SELECT MAX(id) FROM autoeditor_election));
SELECT setval('autoeditor_election_vote_id_seq', (SELECT MAX(id) FROM autoeditor_election_vote));

COMMIT;

