\set ON_ERROR_STOP 1

BEGIN;

CREATE TRIGGER update_counts_for_insert AFTER INSERT ON area_tag_raw
    FOR EACH ROW EXECUTE PROCEDURE update_tag_counts_for_raw_insert('area');

CREATE TRIGGER update_counts_for_update AFTER UPDATE ON area_tag_raw
    FOR EACH ROW EXECUTE PROCEDURE update_tag_counts_for_raw_update('area');

CREATE TRIGGER update_counts_for_delete AFTER DELETE ON area_tag_raw
    FOR EACH ROW EXECUTE PROCEDURE update_tag_counts_for_raw_delete('area');

CREATE TRIGGER update_counts_for_insert AFTER INSERT ON artist_tag_raw
    FOR EACH ROW EXECUTE PROCEDURE update_tag_counts_for_raw_insert('artist');

CREATE TRIGGER update_counts_for_update AFTER UPDATE ON artist_tag_raw
    FOR EACH ROW EXECUTE PROCEDURE update_tag_counts_for_raw_update('artist');

CREATE TRIGGER update_counts_for_delete AFTER DELETE ON artist_tag_raw
    FOR EACH ROW EXECUTE PROCEDURE update_tag_counts_for_raw_delete('artist');

CREATE TRIGGER update_counts_for_insert AFTER INSERT ON event_tag_raw
    FOR EACH ROW EXECUTE PROCEDURE update_tag_counts_for_raw_insert('event');

CREATE TRIGGER update_counts_for_update AFTER UPDATE ON event_tag_raw
    FOR EACH ROW EXECUTE PROCEDURE update_tag_counts_for_raw_update('event');

CREATE TRIGGER update_counts_for_delete AFTER DELETE ON event_tag_raw
    FOR EACH ROW EXECUTE PROCEDURE update_tag_counts_for_raw_delete('event');

CREATE TRIGGER update_counts_for_insert AFTER INSERT ON instrument_tag_raw
    FOR EACH ROW EXECUTE PROCEDURE update_tag_counts_for_raw_insert('instrument');

CREATE TRIGGER update_counts_for_update AFTER UPDATE ON instrument_tag_raw
    FOR EACH ROW EXECUTE PROCEDURE update_tag_counts_for_raw_update('instrument');

CREATE TRIGGER update_counts_for_delete AFTER DELETE ON instrument_tag_raw
    FOR EACH ROW EXECUTE PROCEDURE update_tag_counts_for_raw_delete('instrument');

CREATE TRIGGER update_counts_for_insert AFTER INSERT ON label_tag_raw
    FOR EACH ROW EXECUTE PROCEDURE update_tag_counts_for_raw_insert('label');

CREATE TRIGGER update_counts_for_update AFTER UPDATE ON label_tag_raw
    FOR EACH ROW EXECUTE PROCEDURE update_tag_counts_for_raw_update('label');

CREATE TRIGGER update_counts_for_delete AFTER DELETE ON label_tag_raw
    FOR EACH ROW EXECUTE PROCEDURE update_tag_counts_for_raw_delete('label');

CREATE TRIGGER update_counts_for_insert AFTER INSERT ON place_tag_raw
    FOR EACH ROW EXECUTE PROCEDURE update_tag_counts_for_raw_insert('place');

CREATE TRIGGER update_counts_for_update AFTER UPDATE ON place_tag_raw
    FOR EACH ROW EXECUTE PROCEDURE update_tag_counts_for_raw_update('place');

CREATE TRIGGER update_counts_for_delete AFTER DELETE ON place_tag_raw
    FOR EACH ROW EXECUTE PROCEDURE update_tag_counts_for_raw_delete('place');

CREATE TRIGGER update_counts_for_insert AFTER INSERT ON recording_tag_raw
    FOR EACH ROW EXECUTE PROCEDURE update_tag_counts_for_raw_insert('recording');

CREATE TRIGGER update_counts_for_update AFTER UPDATE ON recording_tag_raw
    FOR EACH ROW EXECUTE PROCEDURE update_tag_counts_for_raw_update('recording');

CREATE TRIGGER update_counts_for_delete AFTER DELETE ON recording_tag_raw
    FOR EACH ROW EXECUTE PROCEDURE update_tag_counts_for_raw_delete('recording');

CREATE TRIGGER update_counts_for_insert AFTER INSERT ON release_tag_raw
    FOR EACH ROW EXECUTE PROCEDURE update_tag_counts_for_raw_insert('release');

CREATE TRIGGER update_counts_for_update AFTER UPDATE ON release_tag_raw
    FOR EACH ROW EXECUTE PROCEDURE update_tag_counts_for_raw_update('release');

CREATE TRIGGER update_counts_for_delete AFTER DELETE ON release_tag_raw
    FOR EACH ROW EXECUTE PROCEDURE update_tag_counts_for_raw_delete('release');

CREATE TRIGGER update_counts_for_insert AFTER INSERT ON release_group_tag_raw
    FOR EACH ROW EXECUTE PROCEDURE update_tag_counts_for_raw_insert('release_group');

CREATE TRIGGER update_counts_for_update AFTER UPDATE ON release_group_tag_raw
    FOR EACH ROW EXECUTE PROCEDURE update_tag_counts_for_raw_update('release_group');

CREATE TRIGGER update_counts_for_delete AFTER DELETE ON release_group_tag_raw
    FOR EACH ROW EXECUTE PROCEDURE update_tag_counts_for_raw_delete('release_group');

CREATE TRIGGER update_counts_for_insert AFTER INSERT ON series_tag_raw
    FOR EACH ROW EXECUTE PROCEDURE update_tag_counts_for_raw_insert('series');

CREATE TRIGGER update_counts_for_update AFTER UPDATE ON series_tag_raw
    FOR EACH ROW EXECUTE PROCEDURE update_tag_counts_for_raw_update('series');

CREATE TRIGGER update_counts_for_delete AFTER DELETE ON series_tag_raw
    FOR EACH ROW EXECUTE PROCEDURE update_tag_counts_for_raw_delete('series');

CREATE TRIGGER update_counts_for_insert AFTER INSERT ON work_tag_raw
    FOR EACH ROW EXECUTE PROCEDURE update_tag_counts_for_raw_insert('work');

CREATE TRIGGER update_counts_for_update AFTER UPDATE ON work_tag_raw
    FOR EACH ROW EXECUTE PROCEDURE update_tag_counts_for_raw_update('work');

CREATE TRIGGER update_counts_for_delete AFTER DELETE ON work_tag_raw
    FOR EACH ROW EXECUTE PROCEDURE update_tag_counts_for_raw_delete('work');

COMMIT;
