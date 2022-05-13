INSERT INTO artist (id, gid, name, sort_name, comment)
    VALUES (1, 'e46bb5a2-f4df-44a1-aafe-d07f4c998ba0', 'A', 'A', ''),
           (2, '213d688f-2a10-463a-86b8-d50a1ae624ee', 'B', 'B', '');

INSERT INTO artist_credit (id, name, artist_count, gid)
    VALUES (1, 'A', 1, '949a7fd5-fe73-3e8f-922e-01ff4ca958f7');

INSERT INTO artist_credit_name (artist_credit, position, artist, name, join_phrase)
    VALUES (1, 0, 1, 'A!', '');

INSERT INTO work (id, gid, name, type, edits_pending, comment)
    VALUES (1, '559be0c1-2c87-45d6-ba43-1b1feb8f831e', 'W1', 1, 0, ''),
           (2, 'aff4e1f7-d3dd-4621-bd4c-25d1b87bb286', 'W2', 1, 0, ''),
           (3, '11d4a39f-ee76-459f-aaf5-b84131d867f2', 'W3', 1, 0, ''),
           (4, 'a72c9be6-5ef9-4bdf-afa1-6a3db697ff62', 'W4', 1, 0, ''),
           (5, '5c089ef8-ada9-4dc0-a2bc-f4d7e84df840', 'W5', 1, 0, '');

INSERT INTO work_language (work, language)
    VALUES (1, 120), (2, 120), (3, 120), (4, 120), (5, 120);

INSERT INTO iswc (id, work, iswc)
    VALUES (1, 1, 'T-000.000.001-0'),
           (2, 1, 'T-000.000.002-0');

INSERT INTO work_gid_redirect
    VALUES ('a30a4245-a7ec-4979-8b1e-b549f2782239', 1);

INSERT INTO work_alias (id, name, sort_name, work, edits_pending)
    VALUES (1, 'WA1', 'WA1', 1, 0),
           (2, 'WA2', 'WA2', 1, 0);

INSERT INTO recording (id, gid, name, artist_credit, length)
    VALUES (1, 'aeb9b50a-e14a-4330-a2e6-7c8a311a9822', 'R', 1, 300000);

INSERT INTO link (id, link_type, attribute_count)
    VALUES (1, 278, 0), -- performance
           (2, 168, 0), -- composer
           (3, 165, 0), -- lyricist
           (4, 161, 0), -- publishing
           (5, 281, 0), -- parts
           (6, 350, 0), -- arrangement
           (7, 167, 0), -- writer
           (8, 239, 0); -- medley

-- performance
INSERT INTO l_recording_work (id, link, entity0, entity1)
    VALUES (1, 1, 1, 1);

INSERT INTO l_artist_work (id, link, entity0, entity1)
    VALUES (1, 2, 1, 1), -- composer
           (2, 3, 1, 1), -- lyricist
           (3, 4, 1, 1), -- publishing
           (4, 7, 2, 1); -- writer

INSERT INTO l_work_work (id, link, entity0, entity1)
    VALUES (1, 5, 1, 2), -- parts
           (2, 5, 1, 3),
           (3, 6, 1, 4), -- arrangement
           (4, 8, 5, 1); -- medley
