\set ON_ERROR_STOP 1
BEGIN;

ALTER TABLE editor_collection_type -- Already dropped in mirror update script
      ADD CONSTRAINT allowed_collection_entity_type CHECK (
          entity_type IN ('area', 'artist', 'event', 'genre', 'instrument', 'label', 'place', 'recording', 'release', 'release_group', 'series', 'work')
      );

ALTER TABLE editor_collection_genre
   ADD CONSTRAINT editor_collection_genre_fk_collection
     FOREIGN KEY (collection)
     REFERENCES editor_collection(id),
   ADD CONSTRAINT editor_collection_genre_fk_genre
     FOREIGN KEY (genre)
     REFERENCES genre(id);

COMMIT;
