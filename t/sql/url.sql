BEGIN;
SET client_min_messages TO 'warning';

TRUNCATE url CASCADE;
INSERT INTO url (id, gid, url, description, editpending, refcount)
    VALUES (1, '9201840b-d810-4e0f-bb75-c791205f5b24', 'http://musicbrainz.org/',
        'MusicBrainz', 1, 2);

COMMIT;
