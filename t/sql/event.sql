SET client_min_messages TO 'WARNING';

INSERT INTO area (id, gid, name, type) VALUES
  (3983, 'b9576171-3434-4d1b-8883-165ed6e65d2f', 'Kensington and Chelsea', 2),
  ( 221, '8a754a16-0027-3a29-b6d7-2b40ea0481ed', 'United Kingdom', 1),
  (  38, '71bbafaa-e825-3e15-8ca9-017dcad1748b', 'Canada', 1);

INSERT INTO country_area (area) VALUES (38), (221);
INSERT INTO iso_3166_1 (area, code) VALUES (38, 'CA'), (221, 'GB');

INSERT INTO place (id, gid, name, type, address, area, coordinates, begin_date_year)
    VALUES (729, '4352063b-a833-421b-a420-e7fb295dece0', 'Royal Albert Hall', 2, 'Kensington Gore, London SW7 2AP', 3983, '(51.50105,-0.17748)', 1871);

INSERT INTO event (id, gid, name, begin_date_year, begin_date_month, begin_date_day, end_date_year, end_date_month, end_date_day, time, type, cancelled, setlist, comment, ended)
    VALUES (59357, 'ca1d24c1-1999-46fd-8a95-3d4108df5cb2', 'BBC Open Music Prom', 2022, 9, 1, 2022, 9, 1, '19:30:00', 1, 'f', NULL, '2022, Prom 60', 't');

INSERT INTO artist (id, gid, name, sort_name, begin_date_year, begin_date_month, type, area, gender)
    VALUES (1294951, 'f72a5b32-449f-4090-9a2a-ebbdd8d3c2e5', 'Kwamé Ryan', 'Ryan, Kwamé', 1970, NULL, 1, 38, 1),
           (831634, 'dfeba5ea-c967-4ad2-9cdd-3cffb4320143', 'BBC Concert Orchestra', 'BBC Concert Orchestra', 1952, 1, 5, 221, NULL);

INSERT INTO link (id, link_type) VALUES (199471, 794), (199854, 807), (199871, 806), (199999, 356);

INSERT INTO l_area_area (id, link, entity0, entity1) VALUES (400588, 199999, 221, 3983);

INSERT INTO l_event_place (id, link, entity0, entity1) VALUES (51345, 199471, 59357, 729);

INSERT INTO l_artist_event (id, link, entity0, entity1) VALUES (160762, 199854, 831634, 59357), (160763, 199871, 1294951, 59357);
