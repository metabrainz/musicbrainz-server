-- Automatically generated, do not edit.
\set ON_ERROR_STOP 1

SET search_path = 'documentation', musicbrainz, public;

BEGIN;

CREATE TRIGGER "reptg_l_area_area_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_area_area_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_area_artist_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_area_artist_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_area_event_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_area_event_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_area_genre_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_area_genre_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_area_instrument_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_area_instrument_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_area_label_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_area_label_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_area_place_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_area_place_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_area_recording_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_area_recording_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_area_release_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_area_release_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_area_release_group_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_area_release_group_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_area_series_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_area_series_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_area_url_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_area_url_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_area_work_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_area_work_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_artist_artist_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_artist_artist_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_artist_event_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_artist_event_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_artist_genre_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_artist_genre_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_artist_instrument_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_artist_instrument_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_artist_label_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_artist_label_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_artist_place_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_artist_place_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_artist_recording_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_artist_recording_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_artist_release_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_artist_release_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_artist_release_group_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_artist_release_group_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_artist_series_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_artist_series_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_artist_url_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_artist_url_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_artist_work_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_artist_work_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_event_event_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_event_event_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_event_genre_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_event_genre_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_event_instrument_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_event_instrument_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_event_label_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_event_label_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_event_place_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_event_place_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_event_recording_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_event_recording_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_event_release_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_event_release_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_event_release_group_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_event_release_group_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_event_series_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_event_series_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_event_url_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_event_url_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_event_work_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_event_work_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_genre_genre_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_genre_genre_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_genre_instrument_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_genre_instrument_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_genre_label_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_genre_label_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_genre_place_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_genre_place_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_genre_recording_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_genre_recording_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_genre_release_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_genre_release_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_genre_release_group_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_genre_release_group_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_genre_series_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_genre_series_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_genre_url_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_genre_url_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_genre_work_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_genre_work_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_instrument_instrument_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_instrument_instrument_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_instrument_label_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_instrument_label_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_instrument_place_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_instrument_place_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_instrument_recording_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_instrument_recording_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_instrument_release_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_instrument_release_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_instrument_release_group_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_instrument_release_group_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_instrument_series_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_instrument_series_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_instrument_url_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_instrument_url_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_instrument_work_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_instrument_work_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_label_label_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_label_label_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_label_place_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_label_place_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_label_recording_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_label_recording_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_label_release_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_label_release_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_label_release_group_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_label_release_group_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_label_series_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_label_series_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_label_url_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_label_url_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_label_work_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_label_work_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_place_place_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_place_place_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_place_recording_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_place_recording_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_place_release_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_place_release_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_place_release_group_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_place_release_group_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_place_series_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_place_series_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_place_url_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_place_url_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_place_work_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_place_work_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_recording_recording_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_recording_recording_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_recording_release_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_recording_release_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_recording_release_group_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_recording_release_group_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_recording_series_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_recording_series_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_recording_url_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_recording_url_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_recording_work_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_recording_work_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_release_group_release_group_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_release_group_release_group_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_release_group_series_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_release_group_series_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_release_group_url_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_release_group_url_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_release_group_work_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_release_group_work_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_release_release_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_release_release_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_release_release_group_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_release_release_group_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_release_series_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_release_series_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_release_url_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_release_url_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_release_work_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_release_work_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_series_series_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_series_series_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_series_url_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_series_url_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_series_work_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_series_work_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_url_url_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_url_url_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_url_work_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_url_work_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_work_work_example"
AFTER INSERT OR DELETE OR UPDATE ON "l_work_work_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_link_type_documentation"
AFTER INSERT OR DELETE OR UPDATE ON "link_type_documentation"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

COMMIT;
