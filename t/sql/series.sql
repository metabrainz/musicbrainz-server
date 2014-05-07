INSERT INTO editor (id, name, password, privs, email, website, bio,
                    email_confirm_date, member_since, last_login_date,
                    edits_accepted, edits_rejected, auto_edits_accepted,
                    edits_failed, ha1)
    VALUES (
        1, 'new_editor', '{CLEARTEXT}password', 0, 'test@editor.org',
        'http://musicbrainz.org', 'biography', '2005-10-20', '1989-07-23',
        now(), 12, 2, 59, 9, 'e1dd8fee8ee728b0ddc8027d3a3db478'
    );

INSERT INTO link_type (id, gid, entity_type0, entity_type1, entity0_cardinality,
                       entity1_cardinality, name, description, link_phrase,
                       reverse_link_phrase, long_link_phrase) VALUES
    (
        1, 'ea6f0698-6782-30d6-b16d-293081b66774',
        'recording', 'series', 0, 0, 'part of',
        'Indicates that the recording is part of a series.',
        'parts', 'part of', 'is a part of'
    ),
    (
        2, 'b0d44366-cdf0-3acb-bee6-0f65a77a6ef0',
        'series', 'work', 0, 0, 'part of',
        'Indicates that the work is part of a series.',
        'parts', 'part of', 'has part'
    ),
    (
        3, '57681e8d-4b77-40bf-9932-4a8cda1484cd',
        'series', 'url', 0, 0, 'wikipedia',
        'Points to the Wikipedia page for this series.',
        'Wikipedia', 'Wikipedia page for', 'has a Wikipedia page at'
    );

INSERT INTO orderable_link_type (link_type, direction) VALUES (1, 2), (2, 1);

INSERT INTO series_type (id, name, entity_type, parent, child_order, description) VALUES
    (1, 'Recording', 'recording', NULL, 0, 'Indicates that the series is of recordings.'),
    (2, 'Work', 'work', NULL, 3, 'Indicates that the series is of works.');

INSERT INTO series_ordering_type (id, name, parent, child_order, description) VALUES
    (1, 'Automatic', NULL, 0,
     'Sorts the items in the series automatically by their ordering attribute, using a natural sort order.'
    ),
    (2, 'Manual', NULL, 1,
     'Allows for manually setting the position of each item in the series.'
    );

INSERT INTO series_alias_type (id, name) VALUES (1, 'Series name'), (2, 'Search hint');

INSERT INTO link_attribute_type (id, root, parent, child_order, gid, name, description) VALUES
    (1, 1, NULL, 0, '58ed5e16-411a-4676-a6f9-0d8a25823763', 'ordering',
        'This attribute indicates the number of a work in a series.'
    ),
    (2, 1, 1, 0, '795daee5-fdcd-4b4b-a440-922b5e5f2aee', 'catalog number',
     'This attribute indicates the catalog number of a work in a series.'
    ),
    (3, 1, 1, 1, '05ddb0ad-fa4b-4a23-8c05-7017fc21f1b3', 'part number',
     'This attribute indicates the part number of a work in a series.'
    );

INSERT INTO link_text_attribute_type VALUES (1), (2), (3);

INSERT INTO link_type_attribute_type (link_type, attribute_type, min, max) VALUES
    (1, 1, 0, 1), (2, 1, 0, 1);

INSERT INTO series (id, gid, name, comment, type, ordering_attribute, ordering_type)
    VALUES (1, 'a8749d0c-4a5a-4403-97c5-f6cd018f8e6d', 'Test Recording Series', 'test comment 1', 1, 3, 1),
           (2, '2e8872b9-2745-4807-a84e-094d425ec267', 'Test Work Series', 'test comment 2', 2, 2, 2),
           (3, 'dbb23c50-d4e4-11e3-9c1a-0800200c9a66', 'Dumb Recording Series', '', 1, 3, 1);

INSERT INTO series_alias (id, series, name, type, sort_name) VALUES
    (1, 1, 'Test Recording Series Alias', 2, 'Test Recording Series Alias');

INSERT INTO link (id, link_type, attribute_count) VALUES
    (1, 1, 0), (2, 1, 0), (3, 1, 0), (4, 1, 0);

INSERT INTO link_attribute_text_value (link, attribute_type, text_value) VALUES
    (1, 3, 'A1'), (2, 3, 'A11'), (3, 3, 'A10'), (4, 3, 'A100');

INSERT INTO artist_credit (id, name, artist_count) VALUES (1, 'Shared Name', 1);

INSERT INTO recording (id, gid, name, artist_credit, length) VALUES
    (1, '123c079d-374e-4436-9448-da92dedef3ce', 'Dancing Queen', 1, 123456),
    (2, '54b9d183-7dab-42ba-94a3-7388a66604b8', 'King of the Mountain', 1, 293720),
    (3, '659f405b-b4ee-4033-868a-0daa27784b89', 'π', 1, 369680),
    (4, 'ae674299-2824-4500-9516-653ac1bc6f80', 'Bertie', 1, 258839);

INSERT INTO l_recording_series (id, link, entity0, entity1, link_order) VALUES
    (1, 1, 1, 1, 1), (2, 2, 2, 1, 2), (3, 3, 3, 3, 1), (4, 4, 4, 3, 2);

ALTER SEQUENCE url_id_seq RESTART;
SELECT setval('series_id_seq', (SELECT max(id) FROM series));
SELECT setval('series_alias_id_seq', (SELECT max(id) FROM series_alias));
SELECT setval('artist_credit_id_seq', (SELECT max(id) FROM artist_credit));
SELECT setval('recording_id_seq', (SELECT max(id) FROM recording));
SELECT setval('link_id_seq', (SELECT max(id) FROM link));
SELECT setval('link_type_id_seq', (SELECT max(id) FROM link_type));
SELECT setval('l_recording_series_id_seq', (SELECT max(id) FROM l_recording_series));
