\set ON_ERROR_STOP 1

BEGIN;

CREATE TRIGGER update_aggregate_rating_for_insert AFTER INSERT ON artist_rating_raw
    FOR EACH ROW EXECUTE PROCEDURE update_aggregate_rating_for_raw_insert('artist');

CREATE TRIGGER update_aggregate_rating_for_update AFTER UPDATE ON artist_rating_raw
    FOR EACH ROW EXECUTE PROCEDURE update_aggregate_rating_for_raw_update('artist');

CREATE TRIGGER update_aggregate_rating_for_delete AFTER DELETE ON artist_rating_raw
    FOR EACH ROW EXECUTE PROCEDURE update_aggregate_rating_for_raw_delete('artist');

CREATE TRIGGER update_aggregate_rating_for_insert AFTER INSERT ON event_rating_raw
    FOR EACH ROW EXECUTE PROCEDURE update_aggregate_rating_for_raw_insert('event');

CREATE TRIGGER update_aggregate_rating_for_update AFTER UPDATE ON event_rating_raw
    FOR EACH ROW EXECUTE PROCEDURE update_aggregate_rating_for_raw_update('event');

CREATE TRIGGER update_aggregate_rating_for_delete AFTER DELETE ON event_rating_raw
    FOR EACH ROW EXECUTE PROCEDURE update_aggregate_rating_for_raw_delete('event');

CREATE TRIGGER update_aggregate_rating_for_insert AFTER INSERT ON label_rating_raw
    FOR EACH ROW EXECUTE PROCEDURE update_aggregate_rating_for_raw_insert('label');

CREATE TRIGGER update_aggregate_rating_for_update AFTER UPDATE ON label_rating_raw
    FOR EACH ROW EXECUTE PROCEDURE update_aggregate_rating_for_raw_update('label');

CREATE TRIGGER update_aggregate_rating_for_delete AFTER DELETE ON label_rating_raw
    FOR EACH ROW EXECUTE PROCEDURE update_aggregate_rating_for_raw_delete('label');

CREATE TRIGGER update_aggregate_rating_for_insert AFTER INSERT ON place_rating_raw
    FOR EACH ROW EXECUTE PROCEDURE update_aggregate_rating_for_raw_insert('place');

CREATE TRIGGER update_aggregate_rating_for_update AFTER UPDATE ON place_rating_raw
    FOR EACH ROW EXECUTE PROCEDURE update_aggregate_rating_for_raw_update('place');

CREATE TRIGGER update_aggregate_rating_for_delete AFTER DELETE ON place_rating_raw
    FOR EACH ROW EXECUTE PROCEDURE update_aggregate_rating_for_raw_delete('place');

CREATE TRIGGER update_aggregate_rating_for_insert AFTER INSERT ON recording_rating_raw
    FOR EACH ROW EXECUTE PROCEDURE update_aggregate_rating_for_raw_insert('recording');

CREATE TRIGGER update_aggregate_rating_for_update AFTER UPDATE ON recording_rating_raw
    FOR EACH ROW EXECUTE PROCEDURE update_aggregate_rating_for_raw_update('recording');

CREATE TRIGGER update_aggregate_rating_for_delete AFTER DELETE ON recording_rating_raw
    FOR EACH ROW EXECUTE PROCEDURE update_aggregate_rating_for_raw_delete('recording');

CREATE TRIGGER update_aggregate_rating_for_insert AFTER INSERT ON release_group_rating_raw
    FOR EACH ROW EXECUTE PROCEDURE update_aggregate_rating_for_raw_insert('release_group');

CREATE TRIGGER update_aggregate_rating_for_update AFTER UPDATE ON release_group_rating_raw
    FOR EACH ROW EXECUTE PROCEDURE update_aggregate_rating_for_raw_update('release_group');

CREATE TRIGGER update_aggregate_rating_for_delete AFTER DELETE ON release_group_rating_raw
    FOR EACH ROW EXECUTE PROCEDURE update_aggregate_rating_for_raw_delete('release_group');

CREATE TRIGGER update_aggregate_rating_for_insert AFTER INSERT ON work_rating_raw
    FOR EACH ROW EXECUTE PROCEDURE update_aggregate_rating_for_raw_insert('work');

CREATE TRIGGER update_aggregate_rating_for_update AFTER UPDATE ON work_rating_raw
    FOR EACH ROW EXECUTE PROCEDURE update_aggregate_rating_for_raw_update('work');

CREATE TRIGGER update_aggregate_rating_for_delete AFTER DELETE ON work_rating_raw
    FOR EACH ROW EXECUTE PROCEDURE update_aggregate_rating_for_raw_delete('work');

COMMIT;
