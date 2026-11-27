\set ON_ERROR_STOP 1

BEGIN;

CREATE INDEX area_tag_idx_tag_count
    ON area_tag (tag, count, area)
    WHERE count > 0;

CREATE INDEX artist_tag_idx_tag_count
    ON artist_tag (tag, count, artist)
    WHERE count > 0;

CREATE INDEX event_tag_idx_tag_count
    ON event_tag (tag, count, event)
    WHERE count > 0;

CREATE INDEX instrument_tag_idx_tag_count
    ON instrument_tag (tag, count, instrument)
    WHERE count > 0;

CREATE INDEX label_tag_idx_tag_count
    ON label_tag (tag, count, label)
    WHERE count > 0;

CREATE INDEX place_tag_idx_tag_count
    ON place_tag (tag, count, place)
    WHERE count > 0;

CREATE INDEX recording_tag_idx_tag_count
    ON recording_tag (tag, count, recording)
    WHERE count > 0;

CREATE INDEX release_tag_idx_tag_count
    ON release_tag (tag, count, release)
    WHERE count > 0;

CREATE INDEX release_group_tag_idx_tag_count
    ON release_group_tag (tag, count, release_group)
    WHERE count > 0;

CREATE INDEX series_tag_idx_tag_count
    ON series_tag (tag, count, series)
    WHERE count > 0;

CREATE INDEX work_tag_idx_tag_count
    ON work_tag (tag, count, work)
    WHERE count > 0;

COMMIT;
