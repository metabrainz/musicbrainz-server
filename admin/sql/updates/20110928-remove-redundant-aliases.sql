BEGIN;

DELETE FROM artist_alias WHERE id IN (
    SELECT artist_alias.id FROM artist_alias
    JOIN artist ON artist.id = artist_alias.artist
    WHERE artist_alias.name = artist.name
      AND artist_alias.edits_pending = 0
);

DELETE FROM label_alias WHERE id IN (
    SELECT label_alias.id FROM label_alias
    JOIN label ON label.id = label_alias.label
    WHERE label_alias.name = label.name
      AND label_alias.edits_pending = 0
);

DELETE FROM work_alias WHERE id IN (
    SELECT work_alias.id FROM work_alias
    JOIN work ON work.id = work_alias.work
    WHERE work_alias.name = work.name
      AND work_alias.edits_pending = 0
);

COMMIT;
