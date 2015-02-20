\set ON_ERROR_STOP 1

ALTER INDEX editor_subscribe_artist_idx_uniq RENAME TO temp_subscr_index;
CREATE UNIQUE INDEX CONCURRENTLY editor_subscribe_artist_idx_uniq ON editor_subscribe_artist (editor, artist);
DROP INDEX temp_subscr_index;

ALTER INDEX editor_subscribe_label_idx_uniq RENAME TO temp_subscr_index;
CREATE UNIQUE INDEX CONCURRENTLY editor_subscribe_label_idx_uniq ON editor_subscribe_label (editor, label);
DROP INDEX temp_subscr_index;

ALTER INDEX editor_subscribe_series_idx_uniq RENAME TO temp_subscr_index;
CREATE UNIQUE INDEX CONCURRENTLY editor_subscribe_series_idx_uniq ON editor_subscribe_series (editor, series);
DROP INDEX temp_subscr_index;

ALTER INDEX editor_subscribe_editor_idx_uniq RENAME TO temp_subscr_index;
CREATE UNIQUE INDEX CONCURRENTLY editor_subscribe_editor_idx_uniq ON editor_subscribe_editor (editor, subscribed_editor);
DROP INDEX temp_subscr_index;
