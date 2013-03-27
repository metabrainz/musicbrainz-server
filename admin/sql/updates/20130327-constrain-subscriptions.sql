BEGIN;

-- These deletions will remove subscriptions to things that don't exist:
DELETE FROM editor_subscribe_artist
WHERE id IN (
  SELECT esa.id
  FROM editor_subscribe_artist esa
  LEFT JOIN artist ON (artist.id = esa.artist)
  WHERE artist.id IS NULL
  AND deleted_by_edit = 0
  AND merged_by_edit = 0
);

DELETE FROM editor_subscribe_label
WHERE id IN (
  SELECT esl.id
  FROM editor_subscribe_label esl
  LEFT JOIN label ON (label.id = esl.label)
  WHERE label.id IS NULL
  AND deleted_by_edit = 0
  AND merged_by_edit = 0
);

ALTER TABLE editor_subscribe_artist
  DROP COLUMN deleted_by_edit,
  DROP COLUMN merged_by_edit,
  ADD FOREIGN KEY (artist) REFERENCES artist (id),
  ADD FOREIGN KEY (last_edit_sent) REFERENCES edit (id);

ALTER TABLE editor_subscribe_label
  DROP COLUMN deleted_by_edit,
  DROP COLUMN merged_by_edit,
  ADD FOREIGN KEY (label) REFERENCES label (id),
  ADD FOREIGN KEY (last_edit_sent) REFERENCES edit (id);

CREATE TABLE artist_deletion
(
    gid UUID NOT NULL PRIMARY KEY,
    last_known_name INTEGER NOT NULL REFERENCES artist_name (id),
    last_known_comment TEXT NOT NULL,
    deleted_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE editor_subscribe_artist_deleted
(
    editor INTEGER NOT NULL REFERENCES editor (id),
    gid UUID NOT NULL REFERENCES artist_deletion (gid),
    deleted_by INTEGER NOT NULL REFERENCES edit (id),
    PRIMARY KEY (editor, gid)
);

CREATE TABLE label_deletion
(
    gid UUID NOT NULL PRIMARY KEY,
    last_known_name INTEGER NOT NULL REFERENCES label_name (id),
    last_known_comment TEXT NOT NULL,
    deleted_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE editor_subscribe_label_deleted
(
    editor INTEGER NOT NULL REFERENCES editor (id),
    gid UUID NOT NULL REFERENCES label_deletion (gid),
    deleted_by INTEGER NOT NULL REFERENCES edit (id),
    PRIMARY KEY (editor, gid)
);

COMMIT;
