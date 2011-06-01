\set ON_ERROR_STOP 1

BEGIN;

CREATE VIEW s_artist AS
    SELECT
        a.id, gid, n.name, sn.name AS sort_name,
        begin_date_year, begin_date_month, begin_date_day,
        end_date_year, end_date_month, end_date_day,
        type, country, gender, comment, ipi_code,
        edits_pending, last_updated
    FROM artist a
    JOIN artist_name n ON a.name=n.id
    JOIN artist_name sn ON a.sort_name=sn.id;

CREATE VIEW s_artist_credit AS
    SELECT
        a.id, n.name, artist_count, ref_count, created
    FROM artist_credit a
    JOIN artist_name n ON a.name=n.id;

CREATE VIEW s_recording AS
    SELECT
        r.id, gid, n.name, artist_credit,
        length, comment, edits_pending, last_updated
    FROM recording r
    JOIN track_name n ON r.name=n.id;

CREATE VIEW s_release AS
    SELECT
        r.id, gid, n.name, artist_credit, release_group, status, packaging,
        country, language, script, date_year, date_month, date_day,
        barcode, comment, edits_pending, quality, last_updated
    FROM release r
    JOIN release_name n ON r.name=n.id;

CREATE VIEW s_release_group AS
    SELECT
        rg.id, gid, n.name, artist_credit,
        type, comment, edits_pending, last_updated
    FROM release_group rg
    JOIN release_name n ON rg.name=n.id;

CREATE VIEW s_track AS
    SELECT
        t.id, recording, tracklist, position, n.name, artist_credit,
        length, edits_pending, last_updated
    FROM track t
    JOIN track_name n ON t.name=n.id;

CREATE VIEW s_work AS
    SELECT
        w.id, gid, n.name, artist_credit,
        type, iswc, comment, edits_pending, last_updated
    FROM work w
    JOIN work_name n ON w.name=n.id;

COMMIT;

-- vi: set ts=4 sw=4 et :
