\set ON_ERROR_STOP 1
BEGIN;

SET LOCAL statement_timeout TO '15min';

-- I) Artists

\echo MBS-10921 (1/12): Unlist “Add relationship” edits from artists’ history...
DELETE FROM edit_artist
WHERE (edit, artist) IN (
    SELECT ea.edit, ea.artist
    FROM edit_artist ea
    JOIN edit e ON ea.edit = e.id
    JOIN edit_data ed ON e.id = ed.edit
    WHERE e.id >= 70658947 AND e.id < 71006471
    AND e.type = 90
    AND jsonb_extract_path_text(ed.data, 'type0') = 'recording'
    AND jsonb_extract_path_text(ed.data, 'type1') = 'work'
    AND jsonb_extract_path_text(ed.data, 'entity0', 'id')::int IN (
        SELECT id FROM recording
    )
    AND jsonb_extract_path_text(ed.data, 'entity0', 'id')::int NOT IN (
        SELECT r.id
        FROM recording r
        JOIN artist_credit_name acn ON r.artist_credit = acn.artist_credit
        WHERE acn.artist = ea.artist
    )
    LIMIT 1951 -- of 195080
)
RETURNING *;

\echo MBS-10921 (2/12): Unlist “Edit relationship” edits from artists’ history...
DELETE FROM edit_artist
WHERE (edit, artist) IN (
    SELECT ea.edit, ea.artist
    FROM edit_artist ea
    JOIN edit e ON ea.edit = e.id
    JOIN edit_data ed ON e.id = ed.edit
    WHERE e.id >= 70658947 AND e.id < 71006471
    AND e.type = 91
    AND jsonb_extract_path_text(ed.data, 'type0') = 'recording'
    AND jsonb_extract_path_text(ed.data, 'type1') = 'work'
    AND jsonb_extract_path_text(ed.data, 'link', 'entity0', 'id')::int IN (
        SELECT id FROM recording
    )
    AND jsonb_extract_path_text(ed.data, 'link', 'entity0', 'id')::int NOT IN (
        SELECT r.id
        FROM recording r
        JOIN artist_credit_name acn ON r.artist_credit = acn.artist_credit
        WHERE acn.artist = ea.artist
    )
    LIMIT 845 -- of 84449
)
RETURNING *;

\echo MBS-10921 (3/12): Unlist “Remove relationship” edits from artists’ history...
DELETE FROM edit_artist
WHERE (edit, artist) IN (
    SELECT ea.edit, ea.artist
    FROM edit_artist ea
    JOIN edit e ON ea.edit = e.id
    JOIN edit_data ed ON e.id = ed.edit
    WHERE e.id >= 70658947 AND e.id < 71006471
    AND e.type = 92
    AND jsonb_extract_path_text(ed.data, 'relationship', 'link', 'type', 'entity0_type') = 'recording'
    AND jsonb_extract_path_text(ed.data, 'relationship', 'link', 'type', 'entity1_type') = 'work'
    AND jsonb_extract_path_text(ed.data, 'relationship', 'entity0', 'id')::int IN (
        SELECT id FROM recording
    )
    AND jsonb_extract_path_text(ed.data, 'relationship', 'entity0', 'id')::int NOT IN (
        SELECT r.id
        FROM recording r
        JOIN artist_credit_name acn ON r.artist_credit = acn.artist_credit
        WHERE acn.artist = ea.artist
    )
    LIMIT 18 -- of 1799
)
RETURNING *;

-- II) Recordings

\echo MBS-10921 (4/12): Unlist “Reorder relationships” edits from artists’ history...
DELETE FROM edit_artist
WHERE (edit, artist) IN (
    SELECT ea.edit, ea.artist
    FROM edit_artist ea
    JOIN edit e ON ea.edit = e.id
    JOIN edit_data ed ON e.id = ed.edit
    WHERE e.id >= 70658947 AND e.id < 71006471
    AND e.type = 99
    AND jsonb_extract_path_text(ed.data, 'link_type', 'entity0_type') = 'recording'
    AND jsonb_extract_path_text(ed.data, 'link_type', 'entity1_type') = 'work'
    AND jsonb_extract_path_text(data, 'relationship_order', '0', 'relationship', 'entity0', 'id')::int IN (
        SELECT id FROM recording
    )
    AND jsonb_extract_path_text(data, 'relationship_order', '0', 'relationship', 'entity0', 'id')::int NOT IN (
        SELECT r.id
        FROM recording r
        JOIN artist_credit_name acn ON r.artist_credit = acn.artist_credit
        WHERE acn.artist = ea.artist
    )
    LIMIT 9 -- of 821
)
RETURNING *;

\echo MBS-10921 (5/12): Unlist “Add relationship” edits from recordings’ history...
DELETE FROM edit_recording
WHERE (edit, recording) IN (
    SELECT er.edit, er.recording
    FROM edit_recording er
    JOIN edit e ON er.edit = e.id
    JOIN edit_data ed ON er.edit = ed.edit
    WHERE e.id >= 70658947 AND e.id < 71006471
    AND e.type = 90
    AND jsonb_extract_path_text(ed.data, 'type0') = 'recording'
    AND jsonb_extract_path_text(ed.data, 'type1') = 'work'
    AND jsonb_extract_path_text(ed.data, 'entity0', 'id')::int != er.recording
    AND jsonb_extract_path_text(ed.data, 'entity0', 'id')::int IN (
        SELECT id FROM recording
    )
    LIMIT 5368 -- of 536757
)
RETURNING *;

\echo MBS-10921 (6/12): Unlist “Edit relationship” edits from recordings’ history...
DELETE FROM edit_recording
WHERE (edit, recording) IN (
    SELECT er.edit, er.recording
    FROM edit_recording er
    JOIN edit e ON er.edit = e.id
    JOIN edit_data ed ON er.edit = ed.edit
    WHERE e.id >= 70658947 AND e.id < 71006471
    AND e.type = 91
    AND jsonb_extract_path_text(ed.data, 'type0') = 'recording'
    AND jsonb_extract_path_text(ed.data, 'type1') = 'work'
    AND jsonb_extract_path_text(ed.data, 'link', 'entity0', 'id')::int != er.recording
    AND jsonb_extract_path_text(ed.data, 'link', 'entity0', 'id')::int IN (
        SELECT id FROM recording
    )
    LIMIT 2543 -- of 254266
)
RETURNING *;

\echo MBS-10921 (7/12): Unlist “Remove relationship” edits from recordings’ history...
DELETE FROM edit_recording
WHERE (edit, recording) IN (
    SELECT er.edit, er.recording
    FROM edit_recording er
    JOIN edit e ON er.edit = e.id
    JOIN edit_data ed ON er.edit = ed.edit
    WHERE e.id >= 70658947 AND e.id < 71006471
    AND e.type = 92
    AND jsonb_extract_path_text(ed.data, 'relationship', 'link', 'type', 'entity0_type') = 'recording'
    AND jsonb_extract_path_text(ed.data, 'relationship', 'link', 'type', 'entity1_type') = 'work'
    AND jsonb_extract_path_text(ed.data, 'relationship', 'entity0', 'id')::int != er.recording
    AND jsonb_extract_path_text(ed.data, 'relationship', 'entity0', 'id')::int IN (
        SELECT id FROM recording
    )
    LIMIT 115 -- of 11435
)
RETURNING *;

\echo MBS-10921 (8/12): Unlist “Reorder relationships” edits from recordings’ history...
DELETE FROM edit_recording
WHERE (edit, recording) IN (
    SELECT er.edit, er.recording
    FROM edit_recording er
    JOIN edit e ON er.edit = e.id
    JOIN edit_data ed ON er.edit = ed.edit
    WHERE e.id >= 70658947 AND e.id < 71006471
    AND e.type = 99
    AND jsonb_extract_path_text(ed.data, 'link_type', 'entity0_type') = 'recording'
    AND jsonb_extract_path_text(ed.data, 'link_type', 'entity1_type') = 'work'
    AND jsonb_extract_path_text(data, 'relationship_order', '0', 'relationship', 'entity0', 'id')::int != er.recording
    AND jsonb_extract_path_text(data, 'relationship_order', '0', 'relationship', 'entity0', 'id')::int IN (
        SELECT id FROM recording
    )
    LIMIT 52 -- of 5109
)
RETURNING *;

-- III) Releases

\echo MBS-10921 (9/12): Unlist “Add relationship” edits from releases’ history...
DELETE FROM edit_release
WHERE (edit, release) IN (
    SELECT er.edit, er.release
    FROM edit_release er
    JOIN edit e ON er.edit = e.id
    JOIN edit_data ed ON e.id = ed.edit
    WHERE e.id >= 70658947 AND e.id < 71006471
    AND e.type = 90
    AND jsonb_extract_path_text(ed.data, 'type0') = 'recording'
    AND jsonb_extract_path_text(ed.data, 'type1') = 'work'
    AND jsonb_extract_path_text(ed.data, 'entity0', 'id')::int IN (
        SELECT id FROM recording
    )
    AND jsonb_extract_path_text(ed.data, 'entity0', 'id')::int NOT IN (
        SELECT track.recording
        FROM track
        JOIN medium ON track.medium = medium.id
        WHERE medium.release = er.release
    )
    LIMIT 10144 -- of 1014376
)
RETURNING *;

\echo MBS-10921 (10/12): Unlist “Edit relationship” edits from releases’ history...
DELETE FROM edit_release
WHERE (edit, release) IN (
    SELECT er.edit, er.release
    FROM edit_release er
    JOIN edit e ON er.edit = e.id
    JOIN edit_data ed ON e.id = ed.edit
    WHERE e.id >= 70658947 AND e.id < 71006471
    AND e.type = 91
    AND jsonb_extract_path_text(ed.data, 'type0') = 'recording'
    AND jsonb_extract_path_text(ed.data, 'type1') = 'work'
    AND jsonb_extract_path_text(ed.data, 'link', 'entity0', 'id')::int IN (
        SELECT id FROM recording
    )
    AND jsonb_extract_path_text(ed.data, 'link', 'entity0', 'id')::int NOT IN (
        SELECT track.recording
        FROM track
        JOIN medium ON track.medium = medium.id
        WHERE medium.release = er.release
    )
    LIMIT 5035 -- of 503445
)
RETURNING *;

\echo MBS-10921 (11/12): Unlist “Remove relationship” edits from releases’ history...
DELETE FROM edit_release
WHERE (edit, release) IN (
    SELECT er.edit, er.release
    FROM edit_release er
    JOIN edit e ON er.edit = e.id
    JOIN edit_data ed ON e.id = ed.edit
    WHERE e.id >= 70658947 AND e.id < 71006471
    AND e.type = 92
    AND jsonb_extract_path_text(ed.data, 'relationship', 'link', 'type', 'entity0_type') = 'recording'
    AND jsonb_extract_path_text(ed.data, 'relationship', 'link', 'type', 'entity1_type') = 'work'
    AND jsonb_extract_path_text(ed.data, 'relationship', 'entity0', 'id')::int IN (
        SELECT id FROM recording
    )
    AND jsonb_extract_path_text(ed.data, 'relationship', 'entity0', 'id')::int NOT IN (
        SELECT track.recording
        FROM track
        JOIN medium ON track.medium = medium.id
        WHERE medium.release = er.release
    )
    LIMIT 232 -- of 23172
)
RETURNING *;

\echo MBS-10921 (12/12): Unlist “Reorder relationships” edits from releases’ history...
DELETE FROM edit_release
WHERE (edit, release) IN (
    SELECT er.edit, er.release
    FROM edit_release er
    JOIN edit e ON er.edit = e.id
    JOIN edit_data ed ON e.id = ed.edit
    WHERE e.id >= 70658947 AND e.id < 71006471
    AND e.type = 99
    AND jsonb_extract_path_text(ed.data, 'link_type', 'entity0_type') = 'recording'
    AND jsonb_extract_path_text(ed.data, 'link_type', 'entity1_type') = 'work'
    AND jsonb_extract_path_text(data, 'relationship_order', '0', 'relationship', 'entity0', 'id')::int IN (
        SELECT id FROM recording
    )
    AND jsonb_extract_path_text(data, 'relationship_order', '0', 'relationship', 'entity0', 'id')::int NOT IN (
        SELECT track.recording
        FROM track
        JOIN medium ON track.medium = medium.id
        WHERE medium.release = er.release
    )
    LIMIT 82 -- of 8184
)
RETURNING *;

COMMIT;

-- vi: set et sts=4 sw=4 ts=4 :
