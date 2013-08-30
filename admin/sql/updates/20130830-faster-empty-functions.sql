BEGIN;

DROP FUNCTION empty_artists();
DROP FUNCTION empty_labels();
DROP FUNCTION empty_release_groups();
DROP FUNCTION empty_works();

CREATE OR REPLACE FUNCTION empty_artists() RETURNS SETOF int AS
$BODY$
  SELECT id FROM artist
  WHERE
    id > 2 AND
    edits_pending = 0 AND
    (
      last_updated < now() - '1 day'::interval OR last_updated is NULL
    )
  EXCEPT
  SELECT artist FROM edit_artist WHERE edit_artist.status = 1
  EXCEPT
  SELECT artist FROM artist_credit_name
  EXCEPT
  SELECT entity1 FROM l_area_artist
  EXCEPT
  SELECT entity0 FROM l_artist_artist
  EXCEPT
  SELECT entity1 FROM l_artist_artist
  EXCEPT
  SELECT entity0 FROM l_artist_label
  EXCEPT
  SELECT entity0 FROM l_artist_recording
  EXCEPT
  SELECT entity0 FROM l_artist_release
  EXCEPT
  SELECT entity0 FROM l_artist_release_group
  EXCEPT
  SELECT entity0 FROM l_artist_url
  EXCEPT
  SELECT entity0 FROM l_artist_work;
$BODY$
LANGUAGE 'sql';

CREATE OR REPLACE FUNCTION empty_labels() RETURNS SETOF int AS
$BODY$
  SELECT id FROM label
  WHERE
    id > 1 AND
    edits_pending = 0 AND
    (
      last_updated < now() - '1 day'::interval OR last_updated is NULL
    )
  EXCEPT
  SELECT label FROM edit_label WHERE edit_label.status = 1
  EXCEPT
  SELECT label FROM release_label
  EXCEPT
  SELECT entity1 FROM l_area_label
  EXCEPT
  SELECT entity1 FROM l_artist_label
  EXCEPT
  SELECT entity1 FROM l_label_label
  EXCEPT
  SELECT entity0 FROM l_label_label
  EXCEPT
  SELECT entity0 FROM l_label_recording
  EXCEPT
  SELECT entity0 FROM l_label_release
  EXCEPT
  SELECT entity0 FROM l_label_release_group
  EXCEPT
  SELECT entity0 FROM l_label_url
  EXCEPT
  SELECT entity0 FROM l_label_work;
$BODY$
LANGUAGE 'sql';

CREATE OR REPLACE FUNCTION empty_release_groups() RETURNS SETOF int AS
$BODY$
  SELECT id FROM release_group
  WHERE
    edits_pending = 0 AND
    (
      last_updated < now() - '1 day'::interval OR last_updated is NULL
    )
  EXCEPT
  SELECT release_group
  FROM edit_release_group
  JOIN edit ON (edit.id = edit_release_group.edit)
  WHERE edit.status = 1
  EXCEPT
  SELECT release_group FROM release
  EXCEPT
  SELECT entity1 FROM l_area_release_group
  EXCEPT
  SELECT entity1 FROM l_artist_release_group
  EXCEPT
  SELECT entity1 FROM l_label_release_group
  EXCEPT
  SELECT entity1 FROM l_recording_release_group
  EXCEPT
  SELECT entity1 FROM l_release_release_group
  EXCEPT
  SELECT entity1 FROM l_release_group_release_group
  EXCEPT
  SELECT entity0 FROM l_release_group_release_group
  EXCEPT
  SELECT entity0 FROM l_release_group_url
  EXCEPT
  SELECT entity0 FROM l_release_group_work;
$BODY$
LANGUAGE 'sql';

CREATE OR REPLACE FUNCTION empty_works() RETURNS SETOF int AS
$BODY$
  SELECT id FROM work
  WHERE
    edits_pending = 0 AND
    (
      last_updated < now() - '1 day'::interval OR last_updated is NULL
    )
  EXCEPT
  SELECT work
  FROM edit_work
  JOIN edit ON (edit.id = edit_work.edit)
  WHERE edit.status = 1
  EXCEPT
  SELECT entity1 FROM l_area_work
  EXCEPT
  SELECT entity1 FROM l_artist_work
  EXCEPT
  SELECT entity1 FROM l_label_work
  EXCEPT
  SELECT entity1 FROM l_recording_work
  EXCEPT
  SELECT entity1 FROM l_release_work
  EXCEPT
  SELECT entity1 FROM l_release_group_work
  EXCEPT
  SELECT entity1 FROM l_url_work
  EXCEPT
  SELECT entity1 FROM l_work_work
  EXCEPT
  SELECT entity0 FROM l_work_work;
$BODY$
LANGUAGE 'sql';

COMMIT;
