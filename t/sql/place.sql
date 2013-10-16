SET client_min_messages TO 'WARNING';

INSERT INTO place_type (id, name) VALUES (1, 'Venue');

INSERT INTO place (id, gid, name, type, address, area, coordinates, comment, edits_pending, last_updated, begin_date_year, begin_date_month, begin_date_day, end_date_year, end_date_month, end_date_day, ended) VALUES (1, 'df9269dd-0470-4ea2-97e8-c11e46080edd', 'A Test Place', 1, 'An Address', 241, '(0.323,1.234)', 'A PLACE!', 0, '2013-09-07 14:40:22.041309+00', 2013, NULL, NULL, NULL, NULL, NULL, '0');

