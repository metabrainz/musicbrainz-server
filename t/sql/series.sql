SET client_min_messages TO 'WARNING';

INSERT INTO series (id, gid, name, comment, type, ordering_type)
    VALUES (1, 'a8749d0c-4a5a-4403-97c5-f6cd018f8e6d', 'Test Recording Series', 'test comment 1', 3, 1),
           (2, '2e8872b9-2745-4807-a84e-094d425ec267', 'Test Work Series', 'test comment 2', 4, 2),
           (3, 'dbb23c50-d4e4-11e3-9c1a-0800200c9a66', 'Dumb Recording Series', '', 3, 1);

INSERT INTO series_alias (id, series, name, type, sort_name) VALUES
    (1, 1, 'Test Series Alias', 1, 'Test Series Alias');

INSERT INTO link (id, link_type, attribute_count) VALUES
    (1, 740, 1), (2, 740, 1), (3, 740, 1), (4, 740, 1),
    (5, 743, 1), (6, 743, 1), (7, 743, 1), (8, 743, 1);

INSERT INTO link_attribute (link, attribute_type) VALUES
    (1, 788), (2, 788), (3, 788), (4, 788), (5, 788), (6, 788), (7, 788), (8, 788);

INSERT INTO link_attribute_text_value (link, attribute_type, text_value)
    VALUES (1, 788, 'A1'),
           (2, 788, 'A11'),
           (3, 788, 'A10'),
           (4, 788, 'A100'),
           (5, 788, 'WTF 87'),
           (6, 788, 'WTF 21'),
           (7, 788, 'WTF 99'),
           (8, 788, 'WTF 12');

INSERT INTO artist (id, gid, name, sort_name) VALUES
    (77, 'ac3a3195-ba87-4154-a937-bbc06aac4038', 'Some Artist', 'Some Artist');

INSERT INTO artist_credit (id, name, artist_count, gid)
    VALUES (1, 'Shared Name', 1, '949a7fd5-fe73-3e8f-922e-01ff4ca958f7');

INSERT INTO artist_credit_name (artist_credit, position, artist, name) VALUES
    (1, 0, 77, 'Shared Name');

INSERT INTO recording (id, gid, name, artist_credit, length) VALUES
    (1, '123c079d-374e-4436-9448-da92dedef3ce', 'Dancing Queen', 1, 123456),
    (2, '54b9d183-7dab-42ba-94a3-7388a66604b8', 'King of the Mountain', 1, 293720),
    (3, '659f405b-b4ee-4033-868a-0daa27784b89', 'π', 1, 369680),
    (4, 'ae674299-2824-4500-9516-653ac1bc6f80', 'Bertie', 1, 258839);

INSERT INTO work (id, gid, name, type) VALUES
    (1, '7e0e3ea0-d674-11e3-9c1a-0800200c9a66', 'Wōrk1', 1),
    (2, 'f89a8de8-f0e3-453c-9516-5bc3edd2fd88', 'Wōrk2', 1),
    (3, '8234f641-4231-4b2f-a14f-c469b9b8de11', 'Wōrk3', 1),
    (4, 'efe72c7d-652d-4243-b01b-152997bb730e', 'Wōrk4', 1);

INSERT INTO l_recording_series (id, link, entity0, entity1, link_order) VALUES
    (1, 1, 1, 1, 1), (2, 2, 2, 1, 2), (3, 3, 3, 3, 1), (4, 4, 4, 3, 2);

INSERT INTO l_series_work (id, link, entity0, entity1, link_order) VALUES
    (1, 5, 2, 1, 1), (2, 6, 2, 2, 2), (3, 7, 2, 3, 3), (4, 8, 2, 4, 4);
