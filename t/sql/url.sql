SET client_min_messages TO 'warning';


INSERT INTO url (id, gid, url, description)
    VALUES (1, '9201840b-d810-4e0f-bb75-c791205f5b24', 'http://musicbrainz.org/',
        'MusicBrainz'),
           (2, '9b3c5c67-572a-4822-82a3-bdd3f35cf152', 'http://microsoft.com',
           'EVIL');

INSERT INTO url (id, gid, url, description)
    VALUES (3, '25d6b63a-12dc-41c9-858a-2f42ae610a7d', 'http://zh-yue.wikipedia.org/wiki/王菲',
        'Cantonese wikipedia page of Faye Wong');

INSERT INTO link_type (id, name, gid, link_phrase, short_link_phrase, reverse_link_phrase, entity_type0, entity_type1)
  VALUES (1, 'wikipedia', 'fcd58926-4243-40bb-a2e5-c7464b3ce577', 'wikipedia', 'wikipedia', 'wikipedia',
          'artist', 'url');
INSERT INTO artist_name (id, name) VALUES (100, 'Faye Wong');
INSERT INTO artist (id, gid, name, sort_name) VALUES (100, 'acd58926-4243-40bb-a2e5-c7464b3ce577', 100, 100);
INSERT INTO link (id, link_type) VALUES (1, 1);
INSERT INTO l_artist_url (id, link, entity0, entity1) VALUES (1, 1, 100, 3);
