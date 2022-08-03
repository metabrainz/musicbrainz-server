\set ON_ERROR_STOP 1

BEGIN;

DELETE FROM area_tag a WHERE NOT EXISTS (
    SELECT 1
      FROM area_tag_raw r
     WHERE r.area = a.area AND r.tag = a.tag
);

UPDATE area_tag a SET count = (
    SELECT sum(CASE WHEN is_upvote THEN 1 ELSE -1 END)
      FROM area_tag_raw r
     WHERE r.area = a.area AND r.tag = a.tag
  GROUP BY r.area, r.tag
);

DELETE FROM artist_tag a WHERE NOT EXISTS (
    SELECT 1
      FROM artist_tag_raw r
     WHERE r.artist = a.artist AND r.tag = a.tag
);

UPDATE artist_tag a SET count = (
    SELECT sum(CASE WHEN is_upvote THEN 1 ELSE -1 END)
      FROM artist_tag_raw r
     WHERE r.artist = a.artist AND r.tag = a.tag
  GROUP BY r.artist, r.tag
);

DELETE FROM event_tag a WHERE NOT EXISTS (
    SELECT 1
      FROM event_tag_raw r
     WHERE r.event = a.event AND r.tag = a.tag
);

UPDATE event_tag a SET count = (
    SELECT sum(CASE WHEN is_upvote THEN 1 ELSE -1 END)
      FROM event_tag_raw r
     WHERE r.event = a.event AND r.tag = a.tag
  GROUP BY r.event, r.tag
);

DELETE FROM instrument_tag a WHERE NOT EXISTS (
    SELECT 1
      FROM instrument_tag_raw r
     WHERE r.instrument = a.instrument AND r.tag = a.tag
);

UPDATE instrument_tag a SET count = (
    SELECT sum(CASE WHEN is_upvote THEN 1 ELSE -1 END)
      FROM instrument_tag_raw r
     WHERE r.instrument = a.instrument AND r.tag = a.tag
  GROUP BY r.instrument, r.tag
);

DELETE FROM label_tag a WHERE NOT EXISTS (
    SELECT 1
      FROM label_tag_raw r
     WHERE r.label = a.label AND r.tag = a.tag
);

UPDATE label_tag a SET count = (
    SELECT sum(CASE WHEN is_upvote THEN 1 ELSE -1 END)
      FROM label_tag_raw r
     WHERE r.label = a.label AND r.tag = a.tag
  GROUP BY r.label, r.tag
);

DELETE FROM place_tag a WHERE NOT EXISTS (
    SELECT 1
      FROM place_tag_raw r
     WHERE r.place = a.place AND r.tag = a.tag
);

UPDATE place_tag a SET count = (
    SELECT sum(CASE WHEN is_upvote THEN 1 ELSE -1 END)
      FROM place_tag_raw r
     WHERE r.place = a.place AND r.tag = a.tag
  GROUP BY r.place, r.tag
);

DELETE FROM recording_tag a WHERE NOT EXISTS (
    SELECT 1
      FROM recording_tag_raw r
     WHERE r.recording = a.recording AND r.tag = a.tag
);

UPDATE recording_tag a SET count = (
    SELECT sum(CASE WHEN is_upvote THEN 1 ELSE -1 END)
      FROM recording_tag_raw r
     WHERE r.recording = a.recording AND r.tag = a.tag
  GROUP BY r.recording, r.tag
);

DELETE FROM release_tag a WHERE NOT EXISTS (
    SELECT 1
      FROM release_tag_raw r
     WHERE r.release = a.release AND r.tag = a.tag
);

UPDATE release_tag a SET count = (
    SELECT sum(CASE WHEN is_upvote THEN 1 ELSE -1 END)
      FROM release_tag_raw r
     WHERE r.release = a.release AND r.tag = a.tag
  GROUP BY r.release, r.tag
);

DELETE FROM release_group_tag a WHERE NOT EXISTS (
    SELECT 1
      FROM release_group_tag_raw r
     WHERE r.release_group = a.release_group AND r.tag = a.tag
);

UPDATE release_group_tag a SET count = (
    SELECT sum(CASE WHEN is_upvote THEN 1 ELSE -1 END)
      FROM release_group_tag_raw r
     WHERE r.release_group = a.release_group AND r.tag = a.tag
  GROUP BY r.release_group, r.tag
);

DELETE FROM series_tag a WHERE NOT EXISTS (
    SELECT 1
      FROM series_tag_raw r
     WHERE r.series = a.series AND r.tag = a.tag
);

UPDATE series_tag a SET count = (
    SELECT sum(CASE WHEN is_upvote THEN 1 ELSE -1 END)
      FROM series_tag_raw r
     WHERE r.series = a.series AND r.tag = a.tag
  GROUP BY r.series, r.tag
);

DELETE FROM work_tag a WHERE NOT EXISTS (
    SELECT 1
      FROM work_tag_raw r
     WHERE r.work = a.work AND r.tag = a.tag
);

UPDATE work_tag a SET count = (
    SELECT sum(CASE WHEN is_upvote THEN 1 ELSE -1 END)
      FROM work_tag_raw r
     WHERE r.work = a.work AND r.tag = a.tag
  GROUP BY r.work, r.tag
);

UPDATE tag t SET ref_count = (
  (SELECT count(*) FROM area_tag_raw r WHERE r.tag = t.id) +
  (SELECT count(*) FROM artist_tag_raw r WHERE r.tag = t.id) +
  (SELECT count(*) FROM event_tag_raw r WHERE r.tag = t.id) +
  (SELECT count(*) FROM instrument_tag_raw r WHERE r.tag = t.id) +
  (SELECT count(*) FROM label_tag_raw r WHERE r.tag = t.id) +
  (SELECT count(*) FROM place_tag_raw r WHERE r.tag = t.id) +
  (SELECT count(*) FROM recording_tag_raw r WHERE r.tag = t.id) +
  (SELECT count(*) FROM release_tag_raw r WHERE r.tag = t.id) +
  (SELECT count(*) FROM release_group_tag_raw r WHERE r.tag = t.id) +
  (SELECT count(*) FROM series_tag_raw r WHERE r.tag = t.id) +
  (SELECT count(*) FROM work_tag_raw r WHERE r.tag = t.id)
);

-- Unused, non-replicated table that holds FKs to tag.
TRUNCATE tag_relation;

DELETE FROM tag WHERE ref_count = 0;

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
