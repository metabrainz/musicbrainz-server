SET client_min_messages TO 'WARNING';

INSERT INTO area (id, gid, name, type) VALUES
  (3983, 'b9576171-3434-4d1b-8883-165ed6e65d2f', 'Kensington and Chelsea', 2),
  ( 221, '8a754a16-0027-3a29-b6d7-2b40ea0481ed', 'United Kingdom', 1),
  (  38, '71bbafaa-e825-3e15-8ca9-017dcad1748b', 'Canada', 1);

INSERT INTO country_area (area) VALUES (38), (221);
INSERT INTO iso_3166_1 (area, code) VALUES (38, 'CA'), (221, 'GB');

INSERT INTO place (id, gid, name, type, address, area, coordinates, begin_date_year)
    VALUES (729, '4352063b-a833-421b-a420-e7fb295dece0', 'Royal Albert Hall', 2, 'Kensington Gore, London SW7 2AP', 3983, '(51.50105,-0.17748)', 1871);

INSERT INTO musicbrainz.event (id, gid, name, begin_date_year, begin_date_month, begin_date_day, end_date_year, end_date_month, end_date_day, time, type, cancelled, setlist, comment, edits_pending, last_updated, ended) VALUES
    (59357, 'ca1d24c1-1999-46fd-8a95-3d4108df5cb2', 'BBC Open Music Prom', 2022, 9, 1, 2022, 9, 1, '19:30:00', 1, '0', '', '2022, Prom 60', 0, '2022-05-08 22:43:07.147531+00', '1'),
    (72229, '183ba1ec-a87b-4c0e-85dd-496b7cea4399', 'Wacken Open Air 2024', 2024, 7, 31, 2024, 8, 3, NULL, 2, '0', '', '', 0, '2024-07-26 11:00:22.044929+00', '1'),
    (79579, '3495abf6-4692-45cd-af62-7d964558676a', 'Wacken Open Air 2024, Day 2', 2024, 7, 29, 2024, 7, 29, NULL, 2, '0', '', '', 0, '2024-07-20 17:00:38.747867+00', '1'),
    (79580, '6b67008c-55a1-44a4-98be-ecfdebc18987', 'Wacken Open Air 2024, Day 3', 2024, 7, 30, 2024, 7, 30, NULL, 2, '0', '', '', 0, '2024-07-20 17:00:38.699779+00', '1'),
    (86430, 'f0ecc038-d229-4b3e-aa98-d5f4de693272', 'Wacken Open Air 2024, Day 2: Welcome to the Jungle', 2024, 7, 29, 2024, 7, 29, NULL, 2, '0', '', '', 0, '2024-07-21 12:00:04.328426+00', '1'),
    (86433, 'eddb272f-1f10-4ece-875d-52cd0d3a2bb1', 'Wacken Open Air 2024, Day 3: LGH Clubstage', 2024, 7, 30, 2024, 7, 30, NULL, 2, '0', '', '', 0, '2024-07-21 12:00:26.447302+00', '1'),
    -- Test cases for events containing a cycle in l_event_event:
    (10000000, '0fcf8392-c3fd-485e-8919-bd4bf9872ff9', 'cycle A', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '0', '', '', 0, '2025-09-04 12:00:00+00', '0'),
    (10000001, 'c188cfc1-725d-496b-b7f1-b0258573508b', 'cycle B', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '0', '', '', 0, '2025-09-04 12:00:00+00', '0'),
    (10000002, '8b918af8-c275-42e3-858b-2098ea307208', 'cycle C', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '0', '', '', 0, '2025-09-04 12:00:00+00', '0');

INSERT INTO artist (id, gid, name, sort_name, begin_date_year, begin_date_month, type, area, gender) VALUES
    (1294951, 'f72a5b32-449f-4090-9a2a-ebbdd8d3c2e5', 'Kwamé Ryan', 'Ryan, Kwamé', 1970, NULL, 1, 38, 1),
    (831634, 'dfeba5ea-c967-4ad2-9cdd-3cffb4320143', 'BBC Concert Orchestra', 'BBC Concert Orchestra', 1952, 1, 5, 221, NULL);

INSERT INTO link (id, link_type, begin_date_year, begin_date_month, begin_date_day, end_date_year, end_date_month, end_date_day, attribute_count, created, ended) VALUES
    (199471, 794, NULL, NULL, NULL, NULL, NULL, NULL, 0, '1970-01-01 00:00:00.00000+00', '0'),
    (199854, 807, NULL, NULL, NULL, NULL, NULL, NULL, 0, '1970-01-01 00:00:00.00000+00', '0'),
    (199871, 806, NULL, NULL, NULL, NULL, NULL, NULL, 0, '1970-01-01 00:00:00.00000+00', '0'),
    (199999, 356, NULL, NULL, NULL, NULL, NULL, NULL, 0, '1970-01-01 00:00:00.00000+00', '0'),
    (201443, 818, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2014-11-26 19:46:43.79701+00', '0');

INSERT INTO l_area_area (id, link, entity0, entity1) VALUES (400588, 199999, 221, 3983);

INSERT INTO l_event_place (id, link, entity0, entity1) VALUES (51345, 199471, 59357, 729);

INSERT INTO l_artist_event (id, link, entity0, entity1) VALUES (160762, 199854, 831634, 59357), (160763, 199871, 1294951, 59357);

INSERT INTO musicbrainz.l_event_event (id, link, entity0, entity1, edits_pending, last_updated, link_order, entity0_credit, entity1_credit) VALUES
    (16709, 201443, 72229, 79579, 0, '2024-02-27 20:58:13.519546+00', 0, '', ''),
    (16710, 201443, 72229, 79580, 0, '2024-02-27 20:58:31.842580+00', 0, '', ''),
    (18460, 201443, 79579, 86430, 0, '2024-07-21 12:00:04.328426+00', 0, '', ''),
    (18463, 201443, 79580, 86433, 0, '2024-07-21 12:00:26.447302+00', 0, '', ''),
    -- Relationship cycle: A -> B -> C -> A:
    (10000000, 201443, 10000000, 10000001, 0, '2025-09-04 12:00:00+00', 0, '', ''),
    (10000001, 201443, 10000001, 10000002, 0, '2025-09-04 12:00:00+00', 0, '', ''),
    (10000002, 201443, 10000002, 10000000, 0, '2025-09-04 12:00:00+00', 0, '', '');

INSERT INTO series (id, gid, name, type, ordering_type) VALUES
    (35, 'd977f7fd-96c9-4e3e-83b5-eb484a9e6584', 'Totally True Tour', 8, 1);

INSERT INTO link (attribute_count, begin_date_day, begin_date_month, begin_date_year, created, end_date_day, end_date_month, end_date_year, ended, id, link_type) VALUES
    (0, NULL, NULL, NULL, '2014-07-09 15:10:16.494155-05', NULL, NULL, NULL, '0', 180899, 802);

INSERT INTO l_event_series (edits_pending, entity0, entity0_credit, entity1, entity1_credit, id, last_updated, link, link_order) VALUES
    (0, 59357, '', 35, '', 7798, '2014-07-09 15:10:16.494155-05', 180899, 1),
    (0, 72229, '', 35, '', 7799, '2014-07-09 15:10:16.494155-05', 180899, 1);
