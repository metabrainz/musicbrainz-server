\set ON_ERROR_STOP 1

BEGIN;

ALTER TABLE genre_alias
   ADD CONSTRAINT genre_alias_fk_type
   FOREIGN KEY (type)
   REFERENCES genre_alias_type(id);

ALTER TABLE genre_alias
   ADD CONSTRAINT genre_alias_fk_genre
   FOREIGN KEY (genre)
   REFERENCES genre(id);

ALTER TABLE genre_alias_type
   ADD CONSTRAINT genre_alias_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES genre_alias_type(id);

CREATE TRIGGER end_date_implies_ended BEFORE UPDATE OR INSERT ON genre_alias
    FOR EACH ROW EXECUTE PROCEDURE end_date_implies_ended();
    
CREATE TRIGGER b_upd_genre_alias BEFORE UPDATE ON genre_alias
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER search_hint BEFORE UPDATE OR INSERT ON genre_alias
    FOR EACH ROW EXECUTE PROCEDURE simplify_search_hints(2);

COMMIT;
