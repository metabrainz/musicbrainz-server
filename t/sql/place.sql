SET client_min_messages TO 'WARNING';

INSERT INTO place (id, gid, name, type, address, area, coordinates, comment, edits_pending, last_updated, begin_date_year, begin_date_month, begin_date_day, end_date_year, end_date_month, end_date_day, ended) VALUES (1, 'df9269dd-0470-4ea2-97e8-c11e46080edd', 'A Test Place', 2, 'An Address', 1178, '(0.323,1.234)', 'A PLACE!', 0, '2013-09-07 14:40:22.041309+00', 2013, NULL, NULL, NULL, NULL, NULL, '0');

INSERT INTO place_alias (id, name, sort_name, place, type, edits_pending)
    VALUES (1, 'A Test Alias', 'A Test Alias', 1, 1, 0);
