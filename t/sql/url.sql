SET client_min_messages TO 'warning';

INSERT INTO url (id, gid, url, last_updated, edits_pending)
    VALUES (1, '9201840b-d810-4e0f-bb75-c791205f5b24', 'http://musicbrainz.org/', '2011-01-18 16:23:38+00', 0),
           (2, '9b3c5c67-572a-4822-82a3-bdd3f35cf152', 'http://microsoft.com', NOW(), 0),
           (3, '25d6b63a-12dc-41c9-858a-2f42ae610a7d', 'http://zh-yue.wikipedia.org/wiki/%E7%8E%8B%E8%8F%B2', '2011-01-18 16:23:38+00', 0),
           (4, '7bd45cc7-6189-4712-35e1-cdf3632cf1a9', 'https://www.allmusic.com/artist/faye-wong-mn0000515659', NOW(), 0),
           (5, '9b3c5c67-572a-4822-82a3-bdd3f35cf153', 'http://microsoft.fr', '2011-01-18 16:23:38+00', 2);

INSERT INTO artist (id, gid, name, sort_name) VALUES (100, 'acd58926-4243-40bb-a2e5-c7464b3ce577', 'Faye Wong', 'Faye Wong');
INSERT INTO link (id, link_type) VALUES (1, 179);
INSERT INTO link (id, link_type) VALUES (2, 283);
INSERT INTO l_artist_url (id, link, entity0, entity1) VALUES (1, 1, 100, 3);
INSERT INTO l_artist_url (id, link, entity0, entity1) VALUES (2, 2, 100, 4);
