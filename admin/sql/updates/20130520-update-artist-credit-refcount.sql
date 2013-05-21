BEGIN;

UPDATE artist_credit SET ref_count = (SELECT
       (SELECT count(*) AS ref_count FROM recording WHERE recording.artist_credit = artist_credit.id) +
       (SELECT count(*) AS ref_count FROM release WHERE release.artist_credit = artist_credit.id) +
       (SELECT count(*) AS ref_count FROM release_group WHERE release_group.artist_credit = artist_credit.id) +
       (SELECT count(*) AS ref_count FROM track WHERE track.artist_credit = artist_credit.id));

COMMIT;
