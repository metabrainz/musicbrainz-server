\set ON_ERROR_STOP 1

BEGIN;

CREATE OR REPLACE VIEW s_artist AS
    SELECT
        a.id, gid, n.name, sn.name AS sort_name,
        begin_date_year, begin_date_month, begin_date_day,
        end_date_year, end_date_month, end_date_day,
        type, country, gender, comment,
        edits_pending, last_updated, ended
    FROM artist a
    JOIN artist_name n ON a.name=n.id
    JOIN artist_name sn ON a.sort_name=sn.id;

CREATE OR REPLACE VIEW s_artist_credit AS
    SELECT
        a.id, n.name, artist_count, ref_count, created
    FROM artist_credit a
    JOIN artist_name n ON a.name=n.id;

CREATE OR REPLACE VIEW s_artist_credit_name AS
    SELECT
        a.artist_credit, a.position, a.artist, n.name,
        a.join_phrase
    FROM artist_credit_name a
    JOIN artist_name n ON a.name = n.id;

CREATE OR REPLACE VIEW s_label AS
    SELECT
        a.id, a.gid, n.name, sn.name AS sort_name,
        a.begin_date_year, a.begin_date_month, a.begin_date_day,
        a.end_date_year, a.end_date_month, a.end_date_day,
        a.label_code, a.type, a.country, a.comment,
        a.edits_pending, a.last_updated, ended
    FROM label a
    JOIN label_name n ON a.name = n.id
    JOIN label_name sn ON a.sort_name = sn.id;

CREATE OR REPLACE VIEW s_recording AS
    SELECT
        r.id, gid, n.name, artist_credit,
        length, comment, edits_pending, last_updated
    FROM recording r
    JOIN track_name n ON r.name=n.id;

CREATE OR REPLACE VIEW s_release AS
    SELECT
        r.id, gid, n.name, artist_credit, release_group, status, packaging,
        country, language, script, date_year, date_month, date_day,
        barcode, comment, edits_pending, quality, last_updated
    FROM release r
    JOIN release_name n ON r.name=n.id;

CREATE OR REPLACE VIEW s_release_group AS
    SELECT
        rg.id, gid, n.name, artist_credit,
        type, comment, edits_pending, last_updated
    FROM release_group rg
    JOIN release_name n ON rg.name=n.id;

CREATE OR REPLACE VIEW s_track AS
    SELECT
        t.id, recording, medium, position, n.name, artist_credit,
        length, edits_pending, last_updated, t.number
    FROM track t
    JOIN track_name n ON t.name=n.id;

CREATE OR REPLACE VIEW s_work AS
    SELECT
        w.id, gid, n.name, artist_credit,
        type, comment, edits_pending, last_updated
    FROM work w
    JOIN work_name n ON w.name=n.id;

COMMIT;

-- vi: set ts=4 sw=4 et :
