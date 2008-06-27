-- Abstract: Change permissions and update the schema number

\set ON_ERROR_STOP 1

BEGIN;

grant all on label to musicbrainz_user_ro;
grant all on labelwords to musicbrainz_user_ro;
grant all on l_album_label to musicbrainz_user_ro;
grant all on l_artist_label to musicbrainz_user_ro;
grant all on l_label_label to musicbrainz_user_ro;
grant all on l_label_track to musicbrainz_user_ro;
grant all on l_label_url to musicbrainz_user_ro;
grant all on lt_album_label to musicbrainz_user_ro;
grant all on lt_artist_label to musicbrainz_user_ro;
grant all on lt_label_label to musicbrainz_user_ro;
grant all on lt_label_track to musicbrainz_user_ro;
grant all on lt_label_url to musicbrainz_user_ro;
grant all on labelalias to musicbrainz_user_ro;
grant all on moderator_subscribe_label to musicbrainz_user_ro;
grant all on gid_redirect to musicbrainz_user_ro;

update replication_control set current_schema_sequence = 8;

COMMIT;

-- vi: set ts=4 sw=4 et :
