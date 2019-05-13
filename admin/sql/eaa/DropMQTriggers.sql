BEGIN;

DROP TRIGGER eaa_delete ON musicbrainz.event;
DROP TRIGGER eaa_move ON event_art_archive.event_art;
DROP TRIGGER eaa_reindex ON event_art_archive.event_art;
DROP TRIGGER eaa_reindex ON musicbrainz.artist;
DROP TRIGGER eaa_reindex ON musicbrainz.event;
DROP TRIGGER eaa_reindex ON musicbrainz.l_artist_event;
DROP TRIGGER eaa_reindex ON musicbrainz.l_event_place;
DROP TRIGGER eaa_reindex ON musicbrainz.place;

DROP FUNCTION event_art_archive.delete_event ();
DROP FUNCTION event_art_archive.move_event ();
DROP FUNCTION event_art_archive.reindex_artist ();
DROP FUNCTION event_art_archive.reindex_eaa ();
DROP FUNCTION event_art_archive.reindex_event ();
DROP FUNCTION event_art_archive.reindex_l_artist_event ();
DROP FUNCTION event_art_archive.reindex_l_event_place ();
DROP FUNCTION event_art_archive.reindex_place ();

COMMIT;
