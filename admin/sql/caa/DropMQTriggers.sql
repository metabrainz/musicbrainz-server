BEGIN;

DROP TRIGGER caa_reindex ON musicbrainz.artist;
DROP TRIGGER caa_reindex ON musicbrainz.release;
DROP TRIGGER caa_reindex ON musicbrainz.release_label;
DROP TRIGGER caa_reindex ON cover_art_archive.cover_art;
DROP TRIGGER caa_reindex ON cover_art_archive.cover_art_type;
DROP TRIGGER caa_move ON cover_art_archive.cover_art;
DROP TRIGGER caa_delete ON musicbrainz.release;

DROP FUNCTION cover_art_archive.reindex_release ();
DROP FUNCTION cover_art_archive.reindex_artist ();
DROP FUNCTION cover_art_archive.reindex_release_via_catno ();
DROP FUNCTION cover_art_archive.reindex_caa ();
DROP FUNCTION cover_art_archive.reindex_caa_type ();
DROP FUNCTION cover_art_archive.caa_move ();
DROP FUNCTION cover_art_archive.delete_release ();

COMMIT;
