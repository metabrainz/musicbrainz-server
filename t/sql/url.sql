BEGIN;
SET client_min_messages TO 'warning';

TRUNCATE url CASCADE;
INSERT INTO url (id, gid, url, description, refcount)
    VALUES (1, '9201840b-d810-4e0f-bb75-c791205f5b24', 'http://musicbrainz.org/',
        'MusicBrainz', 2),
           (2, '9b3c5c67-572a-4822-82a3-bdd3f35cf152', 'http://microsoft.com',
           'EVIL', 1);

COMMIT;
