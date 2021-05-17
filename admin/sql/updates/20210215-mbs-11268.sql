\set ON_ERROR_STOP 1

BEGIN;

CREATE OR REPLACE VIEW medium_track_durations AS
    SELECT
        medium.id AS medium,
        array_agg(track.length ORDER BY track.position) FILTER (WHERE track.position = 0) AS pregap_length,
        array_agg(track.length ORDER BY track.position) FILTER (WHERE track.position > 0 AND track.is_data_track = false) AS cdtoc_track_lengths,
        array_agg(track.length ORDER BY track.position) FILTER (WHERE track.is_data_track = true) AS data_track_lengths
    FROM medium
    JOIN track ON track.medium = medium.id
    GROUP BY medium.id;

COMMIT;
