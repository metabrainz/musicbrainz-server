\set ON_ERROR_STOP 1
BEGIN;

ALTER TABLE genre_alias
   ADD CONSTRAINT genre_alias_fk_genre
   FOREIGN KEY (genre)
   REFERENCES genre(id);

CREATE TRIGGER b_upd_genre BEFORE UPDATE ON genre
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER b_upd_genre_alias BEFORE UPDATE ON genre_alias
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER unique_primary_for_locale BEFORE UPDATE OR INSERT ON genre_alias
    FOR EACH ROW EXECUTE PROCEDURE unique_primary_genre_alias();

COMMIT;
