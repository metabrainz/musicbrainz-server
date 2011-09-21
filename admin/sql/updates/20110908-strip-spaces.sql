BEGIN;

CREATE OR REPLACE FUNCTION clean_spaces(str TEXT)
RETURNS TEXT AS $$
    SELECT btrim(
             regexp_replace(
               regexp_replace($1, E'\\s{2,}', ' ', 'g'),
               E'[\\r\\n]+', '', 'g'),
             chr(9) || chr(32))
$$ LANGUAGE SQL IMMUTABLE;

CREATE OR REPLACE FUNCTION needs_cleaning(str TEXT)
RETURNS BOOLEAN AS $$
    SELECT ($1 ~ E'\\s{2,}' OR $1 ~ E'^\\s+' OR $1 ~ E'\\s+$')
$$ LANGUAGE SQL IMMUTABLE;

--------------------------------------------------------------------------------
-- Find artist name merges
INSERT INTO artist_name (name)
SELECT DISTINCT clean_spaces(name) FROM artist_name n1
WHERE needs_cleaning(name)
AND NOT EXISTS (
    SELECT TRUE FROM artist_name n2
    WHERE n2.name = clean_spaces(n1.name)
);

SELECT n1.id AS old_id, n2.id AS new_id
INTO TEMPORARY artist_name_merge
FROM artist_name n1
JOIN artist_name n2 ON clean_spaces(n1.name) = n2.name
WHERE n1.id != n2.id;

-- Update merges
UPDATE artist_alias SET name = merge.new_id FROM artist_name_merge merge WHERE artist_alias.name = merge.old_id;
UPDATE artist_credit SET name = merge.new_id FROM artist_name_merge merge WHERE artist_credit.name = merge.old_id;
UPDATE artist_credit_name SET name = merge.new_id FROM artist_name_merge merge WHERE artist_credit_name.name = merge.old_id;
UPDATE artist SET name = merge.new_id FROM artist_name_merge merge WHERE artist.name = merge.old_id;
UPDATE artist SET sort_name = merge.new_id FROM artist_name_merge merge WHERE artist.sort_name = merge.old_id;

-- Delete bad names
DELETE FROM artist_name WHERE id IN (SELECT old_id FROM artist_name_merge);

--------------------------------------------------------------------------------
-- Find label name merges
INSERT INTO label_name (name)
SELECT DISTINCT clean_spaces(name) FROM label_name n1
WHERE needs_cleaning(name)
AND NOT EXISTS (
    SELECT TRUE FROM label_name n2
    WHERE n2.name = clean_spaces(n1.name)
);

SELECT n1.id AS old_id, n2.id AS new_id
INTO TEMPORARY label_name_merge
FROM label_name n1
JOIN label_name n2 ON clean_spaces(n1.name) = n2.name
WHERE n1.id != n2.id;

-- Update merges
UPDATE label_alias SET name = merge.new_id FROM label_name_merge merge WHERE label_alias.name = merge.old_id;
UPDATE label SET name = merge.new_id FROM label_name_merge merge WHERE label.name = merge.old_id;
UPDATE label SET sort_name = merge.new_id FROM label_name_merge merge WHERE label.sort_name = merge.old_id;

-- Delete bad names
DELETE FROM label_name WHERE id IN (SELECT old_id FROM label_name_merge);

--------------------------------------------------------------------------------
-- Find release name merges
INSERT INTO release_name (name)
SELECT DISTINCT clean_spaces(name) FROM release_name n1
WHERE needs_cleaning(name)
AND NOT EXISTS (
    SELECT TRUE FROM release_name n2
    WHERE n2.name = clean_spaces(n1.name)
);

SELECT n1.id AS old_id, n2.id AS new_id
INTO TEMPORARY release_name_merge
FROM release_name n1
JOIN release_name n2 ON clean_spaces(n1.name) = n2.name
WHERE n1.id != n2.id;

-- Update merges
UPDATE release SET name = merge.new_id FROM release_name_merge merge WHERE release.name = merge.old_id;
UPDATE release_group SET name = merge.new_id FROM release_name_merge merge WHERE release_group.name = merge.old_id;

-- Delete bad names
DELETE FROM release_name WHERE id IN (SELECT old_id FROM release_name_merge);


--------------------------------------------------------------------------------
-- Find track name merges
INSERT INTO track_name (name)
SELECT DISTINCT clean_spaces(name) FROM track_name n1
WHERE needs_cleaning(name)
AND NOT EXISTS (
    SELECT TRUE FROM track_name n2
    WHERE n2.name = clean_spaces(n1.name)
);

SELECT n1.id AS old_id, n2.id AS new_id
INTO TEMPORARY track_name_merge
FROM track_name n1
JOIN track_name n2 ON clean_spaces(n1.name) = n2.name
WHERE n1.id != n2.id;

-- Update merges
UPDATE track SET name = merge.new_id FROM track_name_merge merge WHERE track.name = merge.old_id;
UPDATE recording SET name = merge.new_id FROM track_name_merge merge WHERE recording.name = merge.old_id;

-- Delete bad names
DELETE FROM track_name WHERE id IN (SELECT old_id FROM track_name_merge);

--------------------------------------------------------------------------------
-- Find work name merges
INSERT INTO work_name (name)
SELECT DISTINCT clean_spaces(name) FROM work_name n1
WHERE needs_cleaning(name)
AND NOT EXISTS (
    SELECT TRUE FROM work_name n2
    WHERE n2.name = clean_spaces(n1.name)
);

SELECT n1.id AS old_id, n2.id AS new_id
INTO TEMPORARY work_name_merge
FROM work_name n1
JOIN work_name n2 ON clean_spaces(n1.name) = n2.name
WHERE n1.id != n2.id;

-- Update merges
UPDATE work_alias SET name = merge.new_id FROM work_name_merge merge WHERE work_alias.name = merge.old_id;
UPDATE work SET name = merge.new_id FROM work_name_merge merge WHERE work.name = merge.old_id;

-- Delete bad names
DELETE FROM work_name WHERE id IN (SELECT old_id FROM work_name_merge);

--------------------------------------------------------------------------------
-- Update non-name columns
UPDATE artist        SET comment = clean_spaces(comment) WHERE needs_cleaning(comment);
UPDATE label         SET comment = clean_spaces(comment) WHERE needs_cleaning(comment);
UPDATE recording     SET comment = clean_spaces(comment) WHERE needs_cleaning(comment);
UPDATE release       SET comment = clean_spaces(comment) WHERE needs_cleaning(comment);
UPDATE release_group SET comment = clean_spaces(comment) WHERE needs_cleaning(comment);
UPDATE work          SET comment = clean_spaces(comment) WHERE needs_cleaning(comment);

UPDATE medium        SET name = clean_spaces(name) WHERE needs_cleaning(name);

UPDATE release_label SET catalog_number = clean_spaces(catalog_number) WHERE needs_cleaning(catalog_number);

DROP FUNCTION needs_cleaning (TEXT);
DROP FUNCTION clean_spaces (TEXT);

COMMIT;
