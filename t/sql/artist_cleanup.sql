SET client_min_messages TO 'warning';

INSERT INTO artist (id, gid, name, sort_name, edits_pending) VALUES
    (3, '6f0e02df-c745-4f2a-84bd-51b12685b942', 'Recording Artist', 'Recording Artist', 0),
    (4, '5cd50089-fd14-460c-ae72-e94277b15ae4', 'Relationship Artist', 'Relationship Artist', 0),
    (5, '74b265fe-aeaf-4f47-a619-98d70ff61ffa', 'Open Edit Artist', 'Open Edit Artist', 2),
    (6, '08d33da4-d011-4731-897a-3df1fcfc4ed5', 'Empty Artist', 'Empty Artist', 0),
    (7, 'c1f4717d-32af-418c-abae-e85ded7bd420', 'Open Creation Edit Artist', 'Open Creation Edit Artist', 1);

INSERT INTO artist_credit (id, name, artist_count, gid)
  VALUES (1, 'Recording Artist', 1, '7511889a-0c25-4991-8799-2ee08c54d9a3');
INSERT INTO artist_credit_name (artist_credit, position, artist, name, join_phrase)
  VALUES (1, 1, 3, 'Recording Artist', '');

INSERT INTO recording (id, gid, name, artist_credit, length) VALUES
    (1, '4d463513-8744-45d5-b425-e6e55c724d2e', 'Test Recording', 1, 123456);

INSERT INTO link (id, link_type, attribute_count) VALUES (1, 148, 0);

INSERT INTO l_artist_recording (id, link, entity0, entity1) VALUES (1, 1, 4, 1);

INSERT INTO editor (id, name, password, privs, email, website, bio, email_confirm_date, member_since, last_login_date, ha1) VALUES (1, 'new_editor', '{CLEARTEXT}password', 0, 'test@editor.org', 'http://musicbrainz.org', 'biography', '2005-10-20', '1989-07-23', now(), 'e1dd8fee8ee728b0ddc8027d3a3db478');

INSERT INTO edit (id, editor, type, status, expire_time)
    VALUES (1, 1, 1, 1, NOW()),
           (2, 1, 2, 1, NOW()),
           (3, 1, 1, 1, NOW());

INSERT INTO edit_data (edit, data)
    VALUES (1, '{"name": "Open Edit Artist", "ended": 0, "area_id": null, "comment": "", "type_id": "1", "end_date": {"day": null, "year": null, "month": null}, "entity_id": 5, "gender_id": null, "ipi_codes": [], "sort_name": "Open Edit Artist", "begin_date": {"day": null, "year": null, "month": null}, "entity_gid": "74b265fe-aeaf-4f47-a619-98d70ff61ffa", "isni_codes": [], "end_area_id": null, "begin_area_id": null}'),
           (2, '{"entity": {"name": "Open Edit Artist", "id": 5}, "new": {"name": "New Name"}, "old": {"name": "Open Edit Artist"}}'),
           (3, '{"name": "Open Creation Edit Artist", "ended": 0, "area_id": null, "comment": "", "type_id": "1", "end_date": {"day": null, "year": null, "month": null}, "entity_id": 7, "gender_id": null, "ipi_codes": [], "sort_name": "Open Creation Edit Artist", "begin_date": {"day": null, "year": null, "month": null}, "entity_gid": "c1f4717d-32af-418c-abae-e85ded7bd420", "isni_codes": [], "end_area_id": null, "begin_area_id": null}');

INSERT INTO edit_artist (edit, artist)
    VALUES (1, 5), (2, 5), (3, 7);
