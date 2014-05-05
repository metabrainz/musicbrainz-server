\set ON_ERROR_STOP 1

BEGIN;

SELECT setval('label_alias_id_seq', (SELECT MAX(id) FROM label_alias));

-- Migrate existing sortnames

-- If the name contains non-Latin scripts, we currently have a weird mixture of non-Latin name and Latin sortname.
-- The guidelines for alias sortnames say not to do that, so for those we'll reuse the sortname as the alias name.
INSERT INTO label_alias (label, name, sort_name)
SELECT l.id, l.sort_name, l.sort_name
FROM label l
WHERE l.name != l.sort_name
AND l.name ~ '[\u0370-\u1DFF\u2E80-\u9FFF\uAC00-\uD7FF]'
AND l.sort_name NOT IN (SELECT sort_name FROM label_alias WHERE label = l.id) -- If there's already an alias with this sortname, we're not losing anything by dropping it
ORDER BY l.name;

-- If the name doesn't contain non-Latin scripts, we can just create an alias with the current name and sortname.
INSERT INTO label_alias (label, name, sort_name)
SELECT l.id, l.name, l.sort_name
FROM label l
WHERE l.name != l.sort_name
AND l.name !~ '[\u0370-\u1DFF\u2E80-\u9FFF\uAC00-\uD7FF]'
AND l.id NOT IN (SELECT label FROM label_alias WHERE name = l.name AND sort_name = l.sort_name)
ORDER BY l.name;

-- Drop the column

ALTER TABLE label DROP COLUMN sort_name;

COMMIT;
