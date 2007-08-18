-- Abstract:
--    - tagging (coming soon)
--    - keeping options for TOCs open
--    - change columns begindate and enddate in AR tables to DEFAULT NULL

\set ON_ERROR_STOP 1

BEGIN;

ALTER TABLE cdtoc ADD COLUMN degraded BOOLEAN NOT NULL DEFAULT FALSE;

ALTER TABLE l_album_album
	ALTER begindate DROP NOT NULL, ALTER begindate SET DEFAULT NULL,
	ALTER enddate DROP NOT NULL, ALTER enddate SET DEFAULT NULL;

ALTER TABLE l_album_artist
	ALTER begindate DROP NOT NULL, ALTER begindate SET DEFAULT NULL,
	ALTER enddate DROP NOT NULL, ALTER enddate SET DEFAULT NULL;

ALTER TABLE l_album_label
	ALTER begindate DROP NOT NULL, ALTER begindate SET DEFAULT NULL,
	ALTER enddate DROP NOT NULL, ALTER enddate SET DEFAULT NULL;

ALTER TABLE l_album_track
	ALTER begindate DROP NOT NULL, ALTER begindate SET DEFAULT NULL,
	ALTER enddate DROP NOT NULL, ALTER enddate SET DEFAULT NULL;

ALTER TABLE l_album_url
	ALTER begindate DROP NOT NULL, ALTER begindate SET DEFAULT NULL,
	ALTER enddate DROP NOT NULL, ALTER enddate SET DEFAULT NULL;

ALTER TABLE l_artist_artist
	ALTER begindate DROP NOT NULL, ALTER begindate SET DEFAULT NULL,
	ALTER enddate DROP NOT NULL, ALTER enddate SET DEFAULT NULL;

ALTER TABLE l_artist_label
	ALTER begindate DROP NOT NULL, ALTER begindate SET DEFAULT NULL,
	ALTER enddate DROP NOT NULL, ALTER enddate SET DEFAULT NULL;

ALTER TABLE l_artist_track
	ALTER begindate DROP NOT NULL, ALTER begindate SET DEFAULT NULL,
	ALTER enddate DROP NOT NULL, ALTER enddate SET DEFAULT NULL;

ALTER TABLE l_artist_url
	ALTER begindate DROP NOT NULL, ALTER begindate SET DEFAULT NULL,
	ALTER enddate DROP NOT NULL, ALTER enddate SET DEFAULT NULL;

ALTER TABLE l_label_label
	ALTER begindate DROP NOT NULL, ALTER begindate SET DEFAULT NULL,
	ALTER enddate DROP NOT NULL, ALTER enddate SET DEFAULT NULL;

ALTER TABLE l_label_track
	ALTER begindate DROP NOT NULL, ALTER begindate SET DEFAULT NULL,
	ALTER enddate DROP NOT NULL, ALTER enddate SET DEFAULT NULL;

ALTER TABLE l_label_url
	ALTER begindate DROP NOT NULL, ALTER begindate SET DEFAULT NULL,
	ALTER enddate DROP NOT NULL, ALTER enddate SET DEFAULT NULL;

ALTER TABLE l_track_track
	ALTER begindate DROP NOT NULL, ALTER begindate SET DEFAULT NULL,
	ALTER enddate DROP NOT NULL, ALTER enddate SET DEFAULT NULL;

ALTER TABLE l_track_url
	ALTER begindate DROP NOT NULL, ALTER begindate SET DEFAULT NULL,
	ALTER enddate DROP NOT NULL, ALTER enddate SET DEFAULT NULL;

ALTER TABLE l_url_url
	ALTER begindate DROP NOT NULL, ALTER begindate SET DEFAULT NULL,
	ALTER enddate DROP NOT NULL, ALTER enddate SET DEFAULT NULL;

UPDATE l_album_album SET begindate = NULL WHERE begindate = '';
UPDATE l_album_album SET enddate = NULL WHERE enddate = '';
UPDATE l_album_artist SET begindate = NULL WHERE begindate = '';
UPDATE l_album_artist SET enddate = NULL WHERE enddate = '';
UPDATE l_album_label SET begindate = NULL WHERE begindate = '';
UPDATE l_album_label SET enddate = NULL WHERE enddate = '';
UPDATE l_album_track SET begindate = NULL WHERE begindate = '';
UPDATE l_album_track SET enddate = NULL WHERE enddate = '';
UPDATE l_album_url SET begindate = NULL WHERE begindate = '';
UPDATE l_album_url SET enddate = NULL WHERE enddate = '';
UPDATE l_artist_artist SET begindate = NULL WHERE begindate = '';
UPDATE l_artist_artist SET enddate = NULL WHERE enddate = '';
UPDATE l_artist_label SET begindate = NULL WHERE begindate = '';
UPDATE l_artist_label SET enddate = NULL WHERE enddate = '';
UPDATE l_artist_track SET begindate = NULL WHERE begindate = '';
UPDATE l_artist_track SET enddate = NULL WHERE enddate = '';
UPDATE l_artist_url SET begindate = NULL WHERE begindate = '';
UPDATE l_artist_url SET enddate = NULL WHERE enddate = '';
UPDATE l_label_label SET begindate = NULL WHERE begindate = '';
UPDATE l_label_label SET enddate = NULL WHERE enddate = '';
UPDATE l_label_track SET begindate = NULL WHERE begindate = '';
UPDATE l_label_track SET enddate = NULL WHERE enddate = '';
UPDATE l_label_url SET begindate = NULL WHERE begindate = '';
UPDATE l_label_url SET enddate = NULL WHERE enddate = '';
UPDATE l_track_track SET begindate = NULL WHERE begindate = '';
UPDATE l_track_track SET enddate = NULL WHERE enddate = '';
UPDATE l_track_url SET begindate = NULL WHERE begindate = '';
UPDATE l_track_url SET enddate = NULL WHERE enddate = '';
UPDATE l_url_url SET begindate = NULL WHERE begindate = '';
UPDATE l_url_url SET enddate = NULL WHERE enddate = '';

COMMIT;

-- vi: set ts=4 sw=4 et :
