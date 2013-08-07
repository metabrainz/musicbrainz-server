\set ON_ERROR_STOP 1

BEGIN;

CREATE OR REPLACE VIEW s_artist AS
    SELECT
        a.id, gid, name, sort_name,
        begin_date_year, begin_date_month, begin_date_day,
        end_date_year, end_date_month, end_date_day,
        type, country, gender, comment,
        edits_pending, last_updated, ended
    FROM artist a

CREATE OR REPLACE VIEW s_artist_credit AS
    SELECT
        a.id, name, artist_count, ref_count, created
    FROM artist_credit a

CREATE OR REPLACE VIEW s_artist_credit_name AS
    SELECT
        a.artist_credit, a.position, a.artist, name,
        a.join_phrase
    FROM artist_credit_name a

CREATE OR REPLACE VIEW s_label AS
    SELECT
        a.id, a.gid, name, sort_name,
        a.begin_date_year, a.begin_date_month, a.begin_date_day,
        a.end_date_year, a.end_date_month, a.end_date_day,
        a.label_code, a.type, a.country, a.comment,
        a.edits_pending, a.last_updated, ended
    FROM label a

CREATE OR REPLACE VIEW s_recording AS
    SELECT
        r.id, gid, name, artist_credit,
        length, comment, edits_pending, last_updated
    FROM recording r

CREATE OR REPLACE VIEW s_release AS
    SELECT
        r.id, gid, name, artist_credit, release_group, status, packaging,
        language, script, barcode, comment, edits_pending, quality, last_updated
    FROM release r

CREATE OR REPLACE VIEW s_release_event AS
    SELECT
        release, date_year, date_month, date_day, country
    FROM (
        SELECT release, date_year, date_month, date_day, country
        FROM release_country
        UNION ALL
        SELECT release, date_year, date_month, date_day, NULL
        FROM release_unknown_country
    );

CREATE OR REPLACE VIEW s_release_group AS
    SELECT
        rg.id, gid, name, artist_credit,
        type, comment, edits_pending, last_updated
    FROM release_group rg

CREATE OR REPLACE VIEW s_track AS
    SELECT
        t.id, recording, medium, position, name, artist_credit,
        length, edits_pending, last_updated, t.number
    FROM track t

CREATE OR REPLACE VIEW s_work AS
    SELECT
        w.id, gid, name, artist_credit,
        type, comment, edits_pending, last_updated
    FROM work w

COMMIT;

-- vi: set ts=4 sw=4 et :
