SET client_min_messages TO 'warning';


INSERT INTO url (id, gid, url)
    VALUES (1, '9201840b-d810-4e0f-bb75-c791205f5b24', 'http://musicbrainz.org/'),
           (2, '9b3c5c67-572a-4822-82a3-bdd3f35cf152', 'http://microsoft.com'),
           (3, '25d6b63a-12dc-41c9-858a-2f42ae610a7d', 'http://zh-yue.wikipedia.org/wiki/%E7%8E%8B%E8%8F%B2'),
           (4, '7bd45cc7-6189-4712-35e1-cdf3632cf1a9', 'http://www.allmusic.com/artist/faye-wong-mn0000515659');

INSERT INTO link_type (id, name, gid, link_phrase, long_link_phrase, reverse_link_phrase, entity_type0, entity_type1, description)
  VALUES (1, 'wikipedia', 'fcd58926-4243-40bb-a2e5-c7464b3ce577', 'wikipedia', 'wikipedia', 'wikipedia', 'artist', 'url', 'description'),
         (2, 'allmusic', '6b3e3c85-0002-4f34-aca6-80ace0d7e846', 'allmusic', 'allmusic', 'allmusic', 'artist', 'url', 'description'),
         (3, 'discogs', '4a78823c-1c53-4176-a5f3-58026c76f2bc', 'discogs', 'discogs', 'discogs', 'release', 'url', 'description'),
         (4, 'amazon asin', '4f2e710d-166c-480c-a293-2e2c8d658d87', 'amazon', 'amazon', 'amazon', 'release', 'url', 'description');
INSERT INTO artist (id, gid, name, sort_name) VALUES (100, 'acd58926-4243-40bb-a2e5-c7464b3ce577', 'Faye Wong', 'Faye Wong');
INSERT INTO link (id, link_type) VALUES (1, 1);
INSERT INTO link (id, link_type) VALUES (2, 2);
INSERT INTO l_artist_url (id, link, entity0, entity1) VALUES (1, 1, 100, 3);
INSERT INTO l_artist_url (id, link, entity0, entity1) VALUES (2, 2, 100, 4);

SELECT setval('url_id_seq', (SELECT max(id) FROM url));
SELECT setval('link_id_seq', (SELECT max(id) FROM link));
SELECT setval('l_artist_url_id_seq', (SELECT max(id) FROM l_artist_url));
