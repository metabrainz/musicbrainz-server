SET client_min_messages TO 'warning';

INSERT INTO artist (id, gid, name, sort_name)
    VALUES (1, '9637fb42-6289-445b-9e4f-5d3135d3b138', 'Spor', 'Spor'),
           (2, '16062b24-e317-4fcf-a898-81c3ac025fb6', 'Break', 'Break'),
           (3, 'd4d73e91-751c-4faf-be60-3fc169bab517', 'Tosca', 'Tosca');

INSERT INTO editor (id, name, password, ha1) VALUES (1, 'acid2', '{CLEARTEXT}xxx', '7d9d2d8a17d6a0aa928c409efdd2884c'), (2, 'rob', '{CLEARTEXT}XXX', '2cebfa4cc482ec4b55eb226b52000a61');

INSERT INTO editor_watch_artist (editor, artist)
    VALUES (1, 1), (1, 2);

INSERT INTO artist_credit (id, name, artist_count, gid)
    VALUES (1, 'Spor', 1, '949a7fd5-fe73-3e8f-922e-01ff4ca958f7');
INSERT INTO artist_credit_name
    (artist, artist_credit, join_phrase, position, name)
        VALUES (1, 1, '', 1, 'Spor');

INSERT INTO release_group (id, gid, name, artist_credit, type)
    VALUES (1, 'd98cfbe2-eb48-48e1-9f7b-e204c15b41c0', 'Resistance', 1, 2);

INSERT INTO release
    (id, gid, name, release_group, artist_credit, date_year, date_month,
     date_day, status)
        VALUES (1, 'f6f95294-e3a6-4ca4-9070-850757026a22', 'Resistance', 1, 1,
                EXTRACT(YEAR FROM NOW() + '@ 1 week'),
                EXTRACT(MONTH FROM NOW() + '@ 1 week'),
                EXTRACT(DAY FROM NOW() + '@ 1 week'), 1);


