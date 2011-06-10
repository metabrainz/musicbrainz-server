-- Automatically generated, do not edit.
\unset ON_ERROR_STOP

DROP FUNCTION a_del_recording();
DROP FUNCTION a_del_release();
DROP FUNCTION a_del_release_group();
DROP FUNCTION a_del_track();
DROP FUNCTION a_ins_artist();
DROP FUNCTION a_ins_editor();
DROP FUNCTION a_ins_label();
DROP FUNCTION a_ins_recording();
DROP FUNCTION a_ins_release();
DROP FUNCTION a_ins_release_group();
DROP FUNCTION a_ins_track();
DROP FUNCTION a_ins_work();
DROP FUNCTION a_upd_recording();
DROP FUNCTION a_upd_release();
DROP FUNCTION a_upd_release_group();
DROP FUNCTION a_upd_track();
DROP FUNCTION b_upd_last_updated_table();
DROP FUNCTION create_bounding_cube(durations INTEGER[], fuzzy INTEGER);
DROP FUNCTION create_cube_from_durations(durations INTEGER[]);
DROP FUNCTION dec_ref_count(tbl varchar, row_id integer, val integer);
DROP FUNCTION deny_special_purpose_deletion();
DROP FUNCTION empty_artists();
DROP FUNCTION from_hex(t text);
DROP FUNCTION generate_uuid_v3(namespace varchar, name varchar);
DROP FUNCTION generate_uuid_v4();
DROP FUNCTION inc_ref_count(tbl varchar, row_id integer, val integer);
DROP FUNCTION page_index(txt varchar);
DROP FUNCTION page_index_max(txt varchar);
DROP FUNCTION set_release_group_first_release_date(release_group_id INTEGER);
DROP AGGREGATE array_accum;
