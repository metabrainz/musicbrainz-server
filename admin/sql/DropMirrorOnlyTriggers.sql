-- Automatically generated, do not edit.
\unset ON_ERROR_STOP

DROP TRIGGER IF EXISTS a_ins_l_area_area_mirror ON l_area_area;
DROP TRIGGER IF EXISTS a_upd_l_area_area_mirror ON l_area_area;
DROP TRIGGER IF EXISTS a_del_l_area_area_mirror ON l_area_area;
DROP TRIGGER IF EXISTS a_ins_release_mirror ON release;
DROP TRIGGER IF EXISTS a_upd_release_mirror ON release;
DROP TRIGGER IF EXISTS a_del_release_mirror ON release;
DROP TRIGGER IF EXISTS a_ins_release_event_mirror ON release_country;
DROP TRIGGER IF EXISTS a_upd_release_event_mirror ON release_country;
DROP TRIGGER IF EXISTS a_del_release_event_mirror ON release_country;
DROP TRIGGER IF EXISTS a_ins_release_event_mirror ON release_unknown_country;
DROP TRIGGER IF EXISTS a_upd_release_event_mirror ON release_unknown_country;
DROP TRIGGER IF EXISTS a_del_release_event_mirror ON release_unknown_country;
DROP TRIGGER IF EXISTS a_ins_release_group_mirror ON release_group;
DROP TRIGGER IF EXISTS a_upd_release_group_mirror ON release_group;
DROP TRIGGER IF EXISTS a_del_release_group_mirror ON release_group;
DROP TRIGGER IF EXISTS a_upd_release_group_meta_mirror ON release_group_meta;
DROP TRIGGER IF EXISTS a_ins_release_group_secondary_type_join_mirror ON release_group_secondary_type_join;
DROP TRIGGER IF EXISTS a_del_release_group_secondary_type_join_mirror ON release_group_secondary_type_join;
DROP TRIGGER IF EXISTS a_ins_release_label_mirror ON release_label;
DROP TRIGGER IF EXISTS a_upd_release_label_mirror ON release_label;
DROP TRIGGER IF EXISTS a_del_release_label_mirror ON release_label;
DROP TRIGGER IF EXISTS a_ins_track_mirror ON track;
DROP TRIGGER IF EXISTS a_upd_track_mirror ON track;
DROP TRIGGER IF EXISTS a_del_track_mirror ON track;
DROP TRIGGER IF EXISTS apply_artist_release_group_pending_updates_mirror ON release;
DROP TRIGGER IF EXISTS apply_artist_release_pending_updates_mirror ON release;
DROP TRIGGER IF EXISTS apply_artist_release_pending_updates_mirror ON release_country;
DROP TRIGGER IF EXISTS apply_artist_release_pending_updates_mirror ON release_first_release_date;
DROP TRIGGER IF EXISTS apply_artist_release_group_pending_updates_mirror ON release_group;
DROP TRIGGER IF EXISTS apply_artist_release_group_pending_updates_mirror ON release_group_meta;
DROP TRIGGER IF EXISTS apply_artist_release_group_pending_updates_mirror ON release_group_secondary_type_join;
DROP TRIGGER IF EXISTS apply_artist_release_pending_updates_mirror ON release_label;
DROP TRIGGER IF EXISTS apply_artist_release_group_pending_updates_mirror ON track;
DROP TRIGGER IF EXISTS apply_artist_release_pending_updates_mirror ON track;
