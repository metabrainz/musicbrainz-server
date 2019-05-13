-- Automatically generated, do not edit.
\set ON_ERROR_STOP 1

BEGIN;

CREATE TRIGGER "reptg_alternative_medium"
AFTER INSERT OR DELETE OR UPDATE ON "alternative_medium"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_alternative_medium_track"
AFTER INSERT OR DELETE OR UPDATE ON "alternative_medium_track"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_alternative_release"
AFTER INSERT OR DELETE OR UPDATE ON "alternative_release"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_alternative_release_type"
AFTER INSERT OR DELETE OR UPDATE ON "alternative_release_type"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_alternative_track"
AFTER INSERT OR DELETE OR UPDATE ON "alternative_track"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_annotation"
AFTER INSERT OR DELETE OR UPDATE ON "annotation"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_area"
AFTER INSERT OR DELETE OR UPDATE ON "area"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_area_alias"
AFTER INSERT OR DELETE OR UPDATE ON "area_alias"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_area_alias_type"
AFTER INSERT OR DELETE OR UPDATE ON "area_alias_type"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_area_annotation"
AFTER INSERT OR DELETE OR UPDATE ON "area_annotation"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_area_attribute"
AFTER INSERT OR DELETE OR UPDATE ON "area_attribute"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_area_attribute_type"
AFTER INSERT OR DELETE OR UPDATE ON "area_attribute_type"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_area_attribute_type_allowed_value"
AFTER INSERT OR DELETE OR UPDATE ON "area_attribute_type_allowed_value"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_area_gid_redirect"
AFTER INSERT OR DELETE OR UPDATE ON "area_gid_redirect"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_area_tag"
AFTER INSERT OR DELETE OR UPDATE ON "area_tag"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_area_type"
AFTER INSERT OR DELETE OR UPDATE ON "area_type"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_artist"
AFTER INSERT OR DELETE OR UPDATE ON "artist"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_artist_alias"
AFTER INSERT OR DELETE OR UPDATE ON "artist_alias"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_artist_alias_type"
AFTER INSERT OR DELETE OR UPDATE ON "artist_alias_type"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_artist_annotation"
AFTER INSERT OR DELETE OR UPDATE ON "artist_annotation"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_artist_attribute"
AFTER INSERT OR DELETE OR UPDATE ON "artist_attribute"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_artist_attribute_type"
AFTER INSERT OR DELETE OR UPDATE ON "artist_attribute_type"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_artist_attribute_type_allowed_value"
AFTER INSERT OR DELETE OR UPDATE ON "artist_attribute_type_allowed_value"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_artist_credit"
AFTER INSERT OR DELETE OR UPDATE ON "artist_credit"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_artist_credit_name"
AFTER INSERT OR DELETE OR UPDATE ON "artist_credit_name"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_artist_gid_redirect"
AFTER INSERT OR DELETE OR UPDATE ON "artist_gid_redirect"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_artist_ipi"
AFTER INSERT OR DELETE OR UPDATE ON "artist_ipi"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_artist_isni"
AFTER INSERT OR DELETE OR UPDATE ON "artist_isni"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_artist_meta"
AFTER INSERT OR DELETE OR UPDATE ON "artist_meta"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_artist_tag"
AFTER INSERT OR DELETE OR UPDATE ON "artist_tag"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_artist_type"
AFTER INSERT OR DELETE OR UPDATE ON "artist_type"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_cdtoc"
AFTER INSERT OR DELETE OR UPDATE ON "cdtoc"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_cdtoc_raw"
AFTER INSERT OR DELETE OR UPDATE ON "cdtoc_raw"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_country_area"
AFTER INSERT OR DELETE OR UPDATE ON "country_area"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_editor_collection_type"
AFTER INSERT OR DELETE OR UPDATE ON "editor_collection_type"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_event"
AFTER INSERT OR DELETE OR UPDATE ON "event"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_event_alias"
AFTER INSERT OR DELETE OR UPDATE ON "event_alias"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_event_alias_type"
AFTER INSERT OR DELETE OR UPDATE ON "event_alias_type"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_event_annotation"
AFTER INSERT OR DELETE OR UPDATE ON "event_annotation"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_event_attribute"
AFTER INSERT OR DELETE OR UPDATE ON "event_attribute"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_event_attribute_type"
AFTER INSERT OR DELETE OR UPDATE ON "event_attribute_type"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_event_attribute_type_allowed_value"
AFTER INSERT OR DELETE OR UPDATE ON "event_attribute_type_allowed_value"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_event_gid_redirect"
AFTER INSERT OR DELETE OR UPDATE ON "event_gid_redirect"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_event_meta"
AFTER INSERT OR DELETE OR UPDATE ON "event_meta"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_event_tag"
AFTER INSERT OR DELETE OR UPDATE ON "event_tag"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_event_type"
AFTER INSERT OR DELETE OR UPDATE ON "event_type"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_gender"
AFTER INSERT OR DELETE OR UPDATE ON "gender"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_genre"
AFTER INSERT OR DELETE OR UPDATE ON "genre"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_genre_alias"
AFTER INSERT OR DELETE OR UPDATE ON "genre_alias"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_instrument"
AFTER INSERT OR DELETE OR UPDATE ON "instrument"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_instrument_alias"
AFTER INSERT OR DELETE OR UPDATE ON "instrument_alias"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_instrument_alias_type"
AFTER INSERT OR DELETE OR UPDATE ON "instrument_alias_type"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_instrument_annotation"
AFTER INSERT OR DELETE OR UPDATE ON "instrument_annotation"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_instrument_attribute"
AFTER INSERT OR DELETE OR UPDATE ON "instrument_attribute"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_instrument_attribute_type"
AFTER INSERT OR DELETE OR UPDATE ON "instrument_attribute_type"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_instrument_attribute_type_allowed_value"
AFTER INSERT OR DELETE OR UPDATE ON "instrument_attribute_type_allowed_value"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_instrument_gid_redirect"
AFTER INSERT OR DELETE OR UPDATE ON "instrument_gid_redirect"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_instrument_tag"
AFTER INSERT OR DELETE OR UPDATE ON "instrument_tag"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_instrument_type"
AFTER INSERT OR DELETE OR UPDATE ON "instrument_type"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_iso_3166_1"
AFTER INSERT OR DELETE OR UPDATE ON "iso_3166_1"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_iso_3166_2"
AFTER INSERT OR DELETE OR UPDATE ON "iso_3166_2"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_iso_3166_3"
AFTER INSERT OR DELETE OR UPDATE ON "iso_3166_3"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_isrc"
AFTER INSERT OR DELETE OR UPDATE ON "isrc"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_iswc"
AFTER INSERT OR DELETE OR UPDATE ON "iswc"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_area_area"
AFTER INSERT OR DELETE OR UPDATE ON "l_area_area"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_area_artist"
AFTER INSERT OR DELETE OR UPDATE ON "l_area_artist"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_area_event"
AFTER INSERT OR DELETE OR UPDATE ON "l_area_event"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_area_instrument"
AFTER INSERT OR DELETE OR UPDATE ON "l_area_instrument"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_area_label"
AFTER INSERT OR DELETE OR UPDATE ON "l_area_label"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_area_place"
AFTER INSERT OR DELETE OR UPDATE ON "l_area_place"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_area_recording"
AFTER INSERT OR DELETE OR UPDATE ON "l_area_recording"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_area_release"
AFTER INSERT OR DELETE OR UPDATE ON "l_area_release"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_area_release_group"
AFTER INSERT OR DELETE OR UPDATE ON "l_area_release_group"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_area_series"
AFTER INSERT OR DELETE OR UPDATE ON "l_area_series"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_area_url"
AFTER INSERT OR DELETE OR UPDATE ON "l_area_url"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_area_work"
AFTER INSERT OR DELETE OR UPDATE ON "l_area_work"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_artist_artist"
AFTER INSERT OR DELETE OR UPDATE ON "l_artist_artist"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_artist_event"
AFTER INSERT OR DELETE OR UPDATE ON "l_artist_event"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_artist_instrument"
AFTER INSERT OR DELETE OR UPDATE ON "l_artist_instrument"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_artist_label"
AFTER INSERT OR DELETE OR UPDATE ON "l_artist_label"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_artist_place"
AFTER INSERT OR DELETE OR UPDATE ON "l_artist_place"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_artist_recording"
AFTER INSERT OR DELETE OR UPDATE ON "l_artist_recording"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_artist_release"
AFTER INSERT OR DELETE OR UPDATE ON "l_artist_release"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_artist_release_group"
AFTER INSERT OR DELETE OR UPDATE ON "l_artist_release_group"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_artist_series"
AFTER INSERT OR DELETE OR UPDATE ON "l_artist_series"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_artist_url"
AFTER INSERT OR DELETE OR UPDATE ON "l_artist_url"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_artist_work"
AFTER INSERT OR DELETE OR UPDATE ON "l_artist_work"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_l_event_event"
AFTER INSERT OR DELETE OR UPDATE ON "l_event_event"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_event_instrument"
AFTER INSERT OR DELETE OR UPDATE ON "l_event_instrument"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_event_label"
AFTER INSERT OR DELETE OR UPDATE ON "l_event_label"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_event_place"
AFTER INSERT OR DELETE OR UPDATE ON "l_event_place"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_event_recording"
AFTER INSERT OR DELETE OR UPDATE ON "l_event_recording"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_event_release"
AFTER INSERT OR DELETE OR UPDATE ON "l_event_release"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_event_release_group"
AFTER INSERT OR DELETE OR UPDATE ON "l_event_release_group"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_event_series"
AFTER INSERT OR DELETE OR UPDATE ON "l_event_series"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_event_url"
AFTER INSERT OR DELETE OR UPDATE ON "l_event_url"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_event_work"
AFTER INSERT OR DELETE OR UPDATE ON "l_event_work"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_instrument_instrument"
AFTER INSERT OR DELETE OR UPDATE ON "l_instrument_instrument"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_instrument_label"
AFTER INSERT OR DELETE OR UPDATE ON "l_instrument_label"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_instrument_place"
AFTER INSERT OR DELETE OR UPDATE ON "l_instrument_place"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_instrument_recording"
AFTER INSERT OR DELETE OR UPDATE ON "l_instrument_recording"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_instrument_release"
AFTER INSERT OR DELETE OR UPDATE ON "l_instrument_release"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_instrument_release_group"
AFTER INSERT OR DELETE OR UPDATE ON "l_instrument_release_group"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_instrument_series"
AFTER INSERT OR DELETE OR UPDATE ON "l_instrument_series"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_instrument_url"
AFTER INSERT OR DELETE OR UPDATE ON "l_instrument_url"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_instrument_work"
AFTER INSERT OR DELETE OR UPDATE ON "l_instrument_work"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_label_label"
AFTER INSERT OR DELETE OR UPDATE ON "l_label_label"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_label_place"
AFTER INSERT OR DELETE OR UPDATE ON "l_label_place"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_label_recording"
AFTER INSERT OR DELETE OR UPDATE ON "l_label_recording"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_label_release"
AFTER INSERT OR DELETE OR UPDATE ON "l_label_release"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_label_release_group"
AFTER INSERT OR DELETE OR UPDATE ON "l_label_release_group"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_label_series"
AFTER INSERT OR DELETE OR UPDATE ON "l_label_series"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_label_url"
AFTER INSERT OR DELETE OR UPDATE ON "l_label_url"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_label_work"
AFTER INSERT OR DELETE OR UPDATE ON "l_label_work"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_place_place"
AFTER INSERT OR DELETE OR UPDATE ON "l_place_place"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_place_recording"
AFTER INSERT OR DELETE OR UPDATE ON "l_place_recording"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_place_release"
AFTER INSERT OR DELETE OR UPDATE ON "l_place_release"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_place_release_group"
AFTER INSERT OR DELETE OR UPDATE ON "l_place_release_group"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_place_series"
AFTER INSERT OR DELETE OR UPDATE ON "l_place_series"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_place_url"
AFTER INSERT OR DELETE OR UPDATE ON "l_place_url"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_place_work"
AFTER INSERT OR DELETE OR UPDATE ON "l_place_work"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_recording_recording"
AFTER INSERT OR DELETE OR UPDATE ON "l_recording_recording"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_recording_release"
AFTER INSERT OR DELETE OR UPDATE ON "l_recording_release"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_recording_release_group"
AFTER INSERT OR DELETE OR UPDATE ON "l_recording_release_group"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_recording_series"
AFTER INSERT OR DELETE OR UPDATE ON "l_recording_series"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_recording_url"
AFTER INSERT OR DELETE OR UPDATE ON "l_recording_url"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_recording_work"
AFTER INSERT OR DELETE OR UPDATE ON "l_recording_work"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_release_group_release_group"
AFTER INSERT OR DELETE OR UPDATE ON "l_release_group_release_group"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_release_group_series"
AFTER INSERT OR DELETE OR UPDATE ON "l_release_group_series"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_release_group_url"
AFTER INSERT OR DELETE OR UPDATE ON "l_release_group_url"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_release_group_work"
AFTER INSERT OR DELETE OR UPDATE ON "l_release_group_work"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_release_release"
AFTER INSERT OR DELETE OR UPDATE ON "l_release_release"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_release_release_group"
AFTER INSERT OR DELETE OR UPDATE ON "l_release_release_group"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_release_series"
AFTER INSERT OR DELETE OR UPDATE ON "l_release_series"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_release_url"
AFTER INSERT OR DELETE OR UPDATE ON "l_release_url"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_release_work"
AFTER INSERT OR DELETE OR UPDATE ON "l_release_work"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_series_series"
AFTER INSERT OR DELETE OR UPDATE ON "l_series_series"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_series_url"
AFTER INSERT OR DELETE OR UPDATE ON "l_series_url"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_series_work"
AFTER INSERT OR DELETE OR UPDATE ON "l_series_work"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_url_url"
AFTER INSERT OR DELETE OR UPDATE ON "l_url_url"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_url_work"
AFTER INSERT OR DELETE OR UPDATE ON "l_url_work"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_work_work"
AFTER INSERT OR DELETE OR UPDATE ON "l_work_work"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_label"
AFTER INSERT OR DELETE OR UPDATE ON "label"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_label_alias"
AFTER INSERT OR DELETE OR UPDATE ON "label_alias"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_label_alias_type"
AFTER INSERT OR DELETE OR UPDATE ON "label_alias_type"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_label_annotation"
AFTER INSERT OR DELETE OR UPDATE ON "label_annotation"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_label_attribute"
AFTER INSERT OR DELETE OR UPDATE ON "label_attribute"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_label_attribute_type"
AFTER INSERT OR DELETE OR UPDATE ON "label_attribute_type"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_label_attribute_type_allowed_value"
AFTER INSERT OR DELETE OR UPDATE ON "label_attribute_type_allowed_value"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_label_gid_redirect"
AFTER INSERT OR DELETE OR UPDATE ON "label_gid_redirect"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_label_ipi"
AFTER INSERT OR DELETE OR UPDATE ON "label_ipi"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_label_isni"
AFTER INSERT OR DELETE OR UPDATE ON "label_isni"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_label_meta"
AFTER INSERT OR DELETE OR UPDATE ON "label_meta"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_label_tag"
AFTER INSERT OR DELETE OR UPDATE ON "label_tag"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_label_type"
AFTER INSERT OR DELETE OR UPDATE ON "label_type"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_language"
AFTER INSERT OR DELETE OR UPDATE ON "language"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_link"
AFTER INSERT OR DELETE OR UPDATE ON "link"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_link_attribute"
AFTER INSERT OR DELETE OR UPDATE ON "link_attribute"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_link_attribute_credit"
AFTER INSERT OR DELETE OR UPDATE ON "link_attribute_credit"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_link_attribute_text_value"
AFTER INSERT OR DELETE OR UPDATE ON "link_attribute_text_value"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_link_attribute_type"
AFTER INSERT OR DELETE OR UPDATE ON "link_attribute_type"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_link_creditable_attribute_type"
AFTER INSERT OR DELETE OR UPDATE ON "link_creditable_attribute_type"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_link_text_attribute_type"
AFTER INSERT OR DELETE OR UPDATE ON "link_text_attribute_type"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_link_type"
AFTER INSERT OR DELETE OR UPDATE ON "link_type"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_link_type_attribute_type"
AFTER INSERT OR DELETE OR UPDATE ON "link_type_attribute_type"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_medium"
AFTER INSERT OR DELETE OR UPDATE ON "medium"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_medium_attribute"
AFTER INSERT OR DELETE OR UPDATE ON "medium_attribute"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_medium_attribute_type"
AFTER INSERT OR DELETE OR UPDATE ON "medium_attribute_type"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_medium_attribute_type_allowed_format"
AFTER INSERT OR DELETE OR UPDATE ON "medium_attribute_type_allowed_format"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_medium_attribute_type_allowed_value"
AFTER INSERT OR DELETE OR UPDATE ON "medium_attribute_type_allowed_value"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_medium_attribute_type_allowed_value_allowed_format"
AFTER INSERT OR DELETE OR UPDATE ON "medium_attribute_type_allowed_value_allowed_format"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_medium_cdtoc"
AFTER INSERT OR DELETE OR UPDATE ON "medium_cdtoc"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_medium_format"
AFTER INSERT OR DELETE OR UPDATE ON "medium_format"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_medium_index"
AFTER INSERT OR DELETE OR UPDATE ON "medium_index"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_orderable_link_type"
AFTER INSERT OR DELETE OR UPDATE ON "orderable_link_type"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_place"
AFTER INSERT OR DELETE OR UPDATE ON "place"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_place_alias"
AFTER INSERT OR DELETE OR UPDATE ON "place_alias"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_place_alias_type"
AFTER INSERT OR DELETE OR UPDATE ON "place_alias_type"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_place_annotation"
AFTER INSERT OR DELETE OR UPDATE ON "place_annotation"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_place_attribute"
AFTER INSERT OR DELETE OR UPDATE ON "place_attribute"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_place_attribute_type"
AFTER INSERT OR DELETE OR UPDATE ON "place_attribute_type"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_place_attribute_type_allowed_value"
AFTER INSERT OR DELETE OR UPDATE ON "place_attribute_type_allowed_value"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_place_gid_redirect"
AFTER INSERT OR DELETE OR UPDATE ON "place_gid_redirect"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_place_tag"
AFTER INSERT OR DELETE OR UPDATE ON "place_tag"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_place_type"
AFTER INSERT OR DELETE OR UPDATE ON "place_type"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_recording"
AFTER INSERT OR DELETE OR UPDATE ON "recording"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_recording_alias"
AFTER INSERT OR DELETE OR UPDATE ON "recording_alias"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_recording_alias_type"
AFTER INSERT OR DELETE OR UPDATE ON "recording_alias_type"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_recording_annotation"
AFTER INSERT OR DELETE OR UPDATE ON "recording_annotation"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_recording_attribute"
AFTER INSERT OR DELETE OR UPDATE ON "recording_attribute"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_recording_attribute_type"
AFTER INSERT OR DELETE OR UPDATE ON "recording_attribute_type"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_recording_attribute_type_allowed_value"
AFTER INSERT OR DELETE OR UPDATE ON "recording_attribute_type_allowed_value"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_recording_gid_redirect"
AFTER INSERT OR DELETE OR UPDATE ON "recording_gid_redirect"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_recording_meta"
AFTER INSERT OR DELETE OR UPDATE ON "recording_meta"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_recording_tag"
AFTER INSERT OR DELETE OR UPDATE ON "recording_tag"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_release"
AFTER INSERT OR DELETE OR UPDATE ON "release"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_release_alias"
AFTER INSERT OR DELETE OR UPDATE ON "release_alias"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_release_alias_type"
AFTER INSERT OR DELETE OR UPDATE ON "release_alias_type"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_release_annotation"
AFTER INSERT OR DELETE OR UPDATE ON "release_annotation"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_release_attribute"
AFTER INSERT OR DELETE OR UPDATE ON "release_attribute"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_release_attribute_type"
AFTER INSERT OR DELETE OR UPDATE ON "release_attribute_type"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_release_attribute_type_allowed_value"
AFTER INSERT OR DELETE OR UPDATE ON "release_attribute_type_allowed_value"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_release_country"
AFTER INSERT OR DELETE OR UPDATE ON "release_country"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_release_gid_redirect"
AFTER INSERT OR DELETE OR UPDATE ON "release_gid_redirect"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_release_group"
AFTER INSERT OR DELETE OR UPDATE ON "release_group"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_release_group_alias"
AFTER INSERT OR DELETE OR UPDATE ON "release_group_alias"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_release_group_alias_type"
AFTER INSERT OR DELETE OR UPDATE ON "release_group_alias_type"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_release_group_annotation"
AFTER INSERT OR DELETE OR UPDATE ON "release_group_annotation"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_release_group_attribute"
AFTER INSERT OR DELETE OR UPDATE ON "release_group_attribute"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_release_group_attribute_type"
AFTER INSERT OR DELETE OR UPDATE ON "release_group_attribute_type"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_release_group_attribute_type_allowed_value"
AFTER INSERT OR DELETE OR UPDATE ON "release_group_attribute_type_allowed_value"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_release_group_gid_redirect"
AFTER INSERT OR DELETE OR UPDATE ON "release_group_gid_redirect"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_release_group_meta"
AFTER INSERT OR DELETE OR UPDATE ON "release_group_meta"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_release_group_primary_type"
AFTER INSERT OR DELETE OR UPDATE ON "release_group_primary_type"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_release_group_secondary_type"
AFTER INSERT OR DELETE OR UPDATE ON "release_group_secondary_type"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_release_group_secondary_type_join"
AFTER INSERT OR DELETE OR UPDATE ON "release_group_secondary_type_join"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_release_group_tag"
AFTER INSERT OR DELETE OR UPDATE ON "release_group_tag"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_release_label"
AFTER INSERT OR DELETE OR UPDATE ON "release_label"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_release_meta"
AFTER INSERT OR DELETE OR UPDATE ON "release_meta"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_release_packaging"
AFTER INSERT OR DELETE OR UPDATE ON "release_packaging"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_release_raw"
AFTER INSERT OR DELETE OR UPDATE ON "release_raw"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_release_status"
AFTER INSERT OR DELETE OR UPDATE ON "release_status"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_release_tag"
AFTER INSERT OR DELETE OR UPDATE ON "release_tag"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_release_unknown_country"
AFTER INSERT OR DELETE OR UPDATE ON "release_unknown_country"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_replication_control"
AFTER INSERT OR DELETE OR UPDATE ON "replication_control"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_script"
AFTER INSERT OR DELETE OR UPDATE ON "script"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_series"
AFTER INSERT OR DELETE OR UPDATE ON "series"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_series_alias"
AFTER INSERT OR DELETE OR UPDATE ON "series_alias"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_series_alias_type"
AFTER INSERT OR DELETE OR UPDATE ON "series_alias_type"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_series_annotation"
AFTER INSERT OR DELETE OR UPDATE ON "series_annotation"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_series_attribute"
AFTER INSERT OR DELETE OR UPDATE ON "series_attribute"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_series_attribute_type"
AFTER INSERT OR DELETE OR UPDATE ON "series_attribute_type"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_series_attribute_type_allowed_value"
AFTER INSERT OR DELETE OR UPDATE ON "series_attribute_type_allowed_value"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_series_gid_redirect"
AFTER INSERT OR DELETE OR UPDATE ON "series_gid_redirect"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_series_ordering_type"
AFTER INSERT OR DELETE OR UPDATE ON "series_ordering_type"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_series_tag"
AFTER INSERT OR DELETE OR UPDATE ON "series_tag"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_series_type"
AFTER INSERT OR DELETE OR UPDATE ON "series_type"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_tag"
AFTER INSERT OR DELETE OR UPDATE ON "tag"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_track"
AFTER INSERT OR DELETE OR UPDATE ON "track"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_track_gid_redirect"
AFTER INSERT OR DELETE OR UPDATE ON "track_gid_redirect"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_track_raw"
AFTER INSERT OR DELETE OR UPDATE ON "track_raw"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_url"
AFTER INSERT OR DELETE OR UPDATE ON "url"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_url_gid_redirect"
AFTER INSERT OR DELETE OR UPDATE ON "url_gid_redirect"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_work"
AFTER INSERT OR DELETE OR UPDATE ON "work"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_work_alias"
AFTER INSERT OR DELETE OR UPDATE ON "work_alias"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_work_alias_type"
AFTER INSERT OR DELETE OR UPDATE ON "work_alias_type"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_work_annotation"
AFTER INSERT OR DELETE OR UPDATE ON "work_annotation"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_work_attribute"
AFTER INSERT OR DELETE OR UPDATE ON "work_attribute"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_work_attribute_type"
AFTER INSERT OR DELETE OR UPDATE ON "work_attribute_type"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_work_attribute_type_allowed_value"
AFTER INSERT OR DELETE OR UPDATE ON "work_attribute_type_allowed_value"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_work_gid_redirect"
AFTER INSERT OR DELETE OR UPDATE ON "work_gid_redirect"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_work_language"
AFTER INSERT OR DELETE OR UPDATE ON "work_language"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_work_meta"
AFTER INSERT OR DELETE OR UPDATE ON "work_meta"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_work_tag"
AFTER INSERT OR DELETE OR UPDATE ON "work_tag"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_work_type"
AFTER INSERT OR DELETE OR UPDATE ON "work_type"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

COMMIT;
