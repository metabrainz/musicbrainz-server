SET search_path = 'musicbrainz';

DROP INDEX artist_tag_idx_artist;
DROP INDEX artist_tag_raw_idx_artist;
DROP INDEX label_tag_idx_label;
DROP INDEX label_tag_raw_idx_label;
DROP INDEX recording_tag_idx_recording;
DROP INDEX recording_tag_raw_idx_track;
DROP INDEX release_group_tag_idx_release_group;
DROP INDEX release_group_tag_raw_idx_release;

CREATE INDEX CONCURRENTLY release_tag_idx_tag ON release_tag (tag);

CREATE INDEX CONCURRENTLY release_tag_raw_idx_tag ON release_tag_raw (tag);
CREATE INDEX CONCURRENTLY release_tag_raw_idx_editor ON release_tag_raw (editor);

CREATE INDEX CONCURRENTLY work_tag_raw_idx_tag ON work_tag_raw (tag);
CREATE INDEX CONCURRENTLY work_tag_raw_idx_editor ON work_tag_raw (editor);

CREATE INDEX CONCURRENTLY tag_relation_idx_tag2 ON tag_relation (tag2);

BEGIN;

SELECT delete_unused_tag(id) FROM tag;

COMMIT;
