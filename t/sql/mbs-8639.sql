DROP TRIGGER a_ins_instrument ON instrument;

INSERT INTO editor (id, name, password, ha1, email, email_confirm_date, privs)
    VALUES (1, 'editor', '{CLEARTEXT}pass', '3f3edade87115ce351d63f42d92a1834', 'editor@example.com', now(), 8);

INSERT INTO instrument (id, gid, name, type)
    VALUES (100, '3bccb7eb-cbca-42cd-b0ac-a5e959df7221', 'drums', 3),
           (588, '1da1ca18-9d70-4217-9e3c-9e67c93b834a', 'other drums', 3);

INSERT INTO link (id, link_type, attribute_count)
    VALUES (1, 148, 2),
           (2, 148, 2),
           (3, 148, 1),
           (4, 148, 1); -- link 4 should be deleted and replaced by link 3

INSERT INTO link_attribute (link, attribute_type)
    VALUES (1, 125), (1, 700), (2, 125), (2, 700), (3, 125), (4, 700);

INSERT INTO link_attribute_credit (link, attribute_type, credited_as)
    VALUES (1, 125, 'drumz'),
           (1, 700, 'crazy drums'), -- link 1 should be split into two separate links, since credits differ
           (2, 700, 'kool drums');  -- link 2 should remain as a single link

INSERT INTO artist (id, gid, name, sort_name)
    VALUES (1, '52bf0d89-9668-4cd4-95f3-3d9d87a54c5c', 'A1', 'A1'),
           (2, 'd5359fdc-2601-4071-b6df-59394e353244', 'A2', 'A2'),
           (3, '7e3d2709-e232-4409-a917-c0ee07a7df6d', 'A3', 'A3');

INSERT INTO artist_credit (id, name, artist_count, gid)
    VALUES (1, 'A1', 1, '949a7fd5-fe73-3e8f-922e-01ff4ca958f7');

INSERT INTO artist_credit_name (artist_credit, position, artist, name, join_phrase)
    VALUES (1, 0, 1, 'A1', '');

INSERT INTO recording (id, gid, name, artist_credit, length)
    VALUES (1, '86368c22-3794-454f-8763-ba1d6279dae6', 'R1', 1, NULL);

INSERT INTO l_artist_recording (id, link, entity0, entity1)
    VALUES (1, 1, 1, 1), (2, 2, 2, 1), (3, 3, 3, 1), (4, 4, 3, 1);

CREATE TRIGGER a_ins_instrument AFTER INSERT ON instrument
    FOR EACH ROW EXECUTE PROCEDURE a_ins_instrument();
