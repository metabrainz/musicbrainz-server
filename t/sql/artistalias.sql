INSERT INTO artist (id, gid, name, sort_name)
    VALUES (1, '945c079d-374e-4436-9448-da92dedef3cf', 'Name', 'Name');

INSERT INTO artist (id, gid, name, sort_name)
    VALUES (2, '73371ea0-7217-11de-8a39-0800200c9a66', 'Empty Artist', 'Empty Artist');

INSERT INTO artist (id, gid, name, sort_name, comment)
    VALUES (3, '686cdcc0-7218-11de-8a39-0800200c9a66', 'Name', 'Name', 'Artist 3');

INSERT INTO artist_alias (id, artist, name, sort_name, begin_date_year,
    begin_date_month, begin_date_day, end_date_year, end_date_month,
    end_date_day)
  VALUES (1, 1, 'Alias 1', 'Alias 1', 2000, 1, 2, 2003, 4, 5);
INSERT INTO artist_alias (id, artist, name, sort_name, locale) VALUES (2, 1, 'Alias 2', 'Alias 2', 'en_GB');
INSERT INTO artist_alias (id, artist, name, sort_name) VALUES (3, 3, 'Alias 2', 'Alias 2');

INSERT INTO artist_alias_type (id, name) VALUES (1, 'Legal name'), (2, 'Alias');

ALTER SEQUENCE artist_alias_id_seq RESTART 4;
