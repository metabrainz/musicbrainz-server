BEGIN;

UPDATE release_coverart SET cover_art_url = NULL
WHERE cover_art_url LIKE '%amazon%'
  AND id NOT IN (
    SELECT entity0
    FROM l_release_url
    JOIN link ON link.id=l_release_url.link
    JOIN link_type ON (link_type.id = link.link_type)
    WHERE link_type.name = 'amazon asin'
    UNION ALL
    SELECT id FROM release
    WHERE barcode IS NOT NULL
  );

COMMIT;
