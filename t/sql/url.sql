
SET client_min_messages TO 'warning';


INSERT INTO url (id, gid, url, description, ref_count)
    VALUES (1, '9201840b-d810-4e0f-bb75-c791205f5b24', 'http://musicbrainz.org/',
        'MusicBrainz', 2),
           (2, '9b3c5c67-572a-4822-82a3-bdd3f35cf152', 'http://microsoft.com',
           'EVIL', 1);

INSERT INTO url (id, gid, url, description, ref_count)
    VALUES (3, '25d6b63a-12dc-41c9-858a-2f42ae610a7d', 'http://zh-yue.wikipedia.org/wiki/王菲',
        'Cantonese wikipedia page of Faye Wong', 1);


