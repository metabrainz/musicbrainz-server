\set ON_ERROR_STOP 1

BEGIN;

-- Skip past $EDITOR_MODBOT.
SELECT setval('editor_id_seq', 5, FALSE);

INSERT INTO artist (area, begin_area, begin_date_day, begin_date_month, begin_date_year, comment, edits_pending, end_area, end_date_day, end_date_month, end_date_year, ended, gender, gid, id, last_updated, name, sort_name, type) VALUES
    (NULL, NULL, 8, 1, 1947, '', 0, NULL, 10, 1, 2016, '1', 1, '5441c29d-3602-4898-b1a1-b77fa23b8e50', 956, '2016-02-07 10:16:37.066958+00', 'David Bowie', 'Bowie, David', 1),
    (NULL, NULL, 3, 5, 1903, '', 0, NULL, 14, 10, 1977, '1', 1, '2437980f-513a-44fc-80f1-b90d9d7fcf8f', 99, '2016-11-07 12:01:02.968948+00', 'Bing Crosby', 'Crosby, Bing', 1);

COMMIT;
