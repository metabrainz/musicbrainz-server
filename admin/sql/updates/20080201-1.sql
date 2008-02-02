\set ON_ERROR_STOP 1

BEGIN;

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
