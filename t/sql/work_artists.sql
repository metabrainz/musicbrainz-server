SET client_min_messages TO 'warning';

INSERT INTO work (id, gid, name, type)
    VALUES (1, 'f693f5ed-10fc-31c6-87c3-01cb47dd27a0', 'Dancing Queen', 1);

INSERT INTO artist (id, gid, name, sort_name)
    VALUES (1, 'd87e52c5-bb8d-4da8-b941-9f4928627dc8', 'ABBA', 'ABBA'),
           (2, 'fa37018e-3557-4cb7-973f-555003c30174', 'London Philharmonic Orchestra', 'London Philharmonic Orchestra'),
           (3, '6d7af416-da1d-4b2c-aa94-8ca43a6dfb34', 'Louis Clark', 'Louis Clark'),
           (4, '2f031686-3f01-4f33-a4fc-fb3944532efa', 'Benny Andersson', 'Benny Andersson'),
           (5, 'ffb77292-9712-4d03-94aa-bdb1d4771d38', 'Björn Ulvaeus', 'Björn Ulvaeus'),
           (6, 'b7ffd2af-418f-4be2-bdd1-22f8b48613da', 'Nine Inch Nails', 'Nine Inch Nails');

INSERT INTO artist_credit (id, name, artist_count, gid)
    VALUES (1, 'ABBA', 1, '949a7fd5-fe73-3e8f-922e-01ff4ca958f7'),
           (2, 'Louis Clark & Royal Philharmonic Orchestra', 2, 'fa37018e-3557-4cb7-aa94-8ca43a6dfb34');
INSERT INTO artist_credit_name (artist_credit, position, artist, name, join_phrase)
    VALUES (1, 0, 1, 'ABBA', ''),
           (2, 0, 3, 'Louis Clark', ' & '),
           (2, 1, 2, 'London Philharmonic Orchestra', '');

INSERT INTO recording (id, gid, name, artist_credit, length, comment, edits_pending, last_updated, video)
    VALUES (1, 'a502f559-f70c-4e0d-a5e5-e0cc319d0bd7', 'Dancing Queen', 1, 10000, '', 0, '2012-04-23 23:00:09.754657+00', 'f'),
           (2, 'd14b0cbc-7e2e-483d-a1c1-e3751310c0b2', 'Dancing Queen', 2, 10000, '', 0, '2012-04-23 23:00:09.754657+00', 'f');

INSERT INTO link (id, link_type, attribute_count)
    VALUES (1, 278, 0), (2, 278, 0), -- performance
           (3, 168, 0), (4, 168, 0), -- composer
           (5, 165, 0), -- lyricist
           (6, 846, 0); -- dedication

INSERT INTO l_recording_work (id, link, entity0, entity1)
    VALUES (1, 1, 1, 1), (2, 1, 2, 1);

INSERT INTO l_artist_work (id, link, entity0, entity1, entity0_credit)
    VALUES (1, 3, 4, 1, ''),  (2, 4, 5, 1, ''), -- composer
           (3, 5, 4, 1, ''), -- lyricist
           (4, 6, 6, 1, 'NIN'); -- dedication
