\set ON_ERROR_STOP 1
BEGIN;

CREATE TRIGGER end_date_implies_ended BEFORE UPDATE OR INSERT ON recording_alias
    FOR EACH ROW EXECUTE PROCEDURE end_date_implies_ended();

CREATE TRIGGER b_upd_recording_alias BEFORE UPDATE ON recording_alias
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER unique_primary_for_locale BEFORE UPDATE OR INSERT ON recording_alias
    FOR EACH ROW EXECUTE PROCEDURE unique_primary_recording_alias();

CREATE TRIGGER search_hint BEFORE UPDATE OR INSERT ON recording_alias
    FOR EACH ROW EXECUTE PROCEDURE simplify_search_hints(2);

CREATE TRIGGER end_date_implies_ended BEFORE UPDATE OR INSERT ON release_alias
    FOR EACH ROW EXECUTE PROCEDURE end_date_implies_ended();

CREATE TRIGGER b_upd_release_alias BEFORE UPDATE ON release_alias
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER unique_primary_for_locale BEFORE UPDATE OR INSERT ON release_alias
    FOR EACH ROW EXECUTE PROCEDURE unique_primary_release_alias();

CREATE TRIGGER search_hint BEFORE UPDATE OR INSERT ON release_alias
    FOR EACH ROW EXECUTE PROCEDURE simplify_search_hints(2);

CREATE TRIGGER end_date_implies_ended BEFORE UPDATE OR INSERT ON release_group_alias
    FOR EACH ROW EXECUTE PROCEDURE end_date_implies_ended();

CREATE TRIGGER b_upd_release_group_alias BEFORE UPDATE ON release_group_alias
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER unique_primary_for_locale BEFORE UPDATE OR INSERT ON release_group_alias
    FOR EACH ROW EXECUTE PROCEDURE unique_primary_release_group_alias();

CREATE TRIGGER search_hint BEFORE UPDATE OR INSERT ON release_group_alias
    FOR EACH ROW EXECUTE PROCEDURE simplify_search_hints(2);


ALTER TABLE release_alias
  ADD CONSTRAINT control_for_whitespace CHECK (controlled_for_whitespace(name)),
  ADD CONSTRAINT only_non_empty CHECK (name != ''),
  ADD CONSTRAINT control_for_whitespace_sort_name CHECK (controlled_for_whitespace(sort_name)),
  ADD CONSTRAINT only_non_empty_sort_name CHECK (sort_name != '');

ALTER TABLE release_group_alias
  ADD CONSTRAINT control_for_whitespace CHECK (controlled_for_whitespace(name)),
  ADD CONSTRAINT only_non_empty CHECK (name != ''),
  ADD CONSTRAINT control_for_whitespace_sort_name CHECK (controlled_for_whitespace(sort_name)),
  ADD CONSTRAINT only_non_empty_sort_name CHECK (sort_name != '');

ALTER TABLE recording_alias
  ADD CONSTRAINT control_for_whitespace CHECK (controlled_for_whitespace(name)),
  ADD CONSTRAINT only_non_empty CHECK (name != ''),
  ADD CONSTRAINT control_for_whitespace_sort_name CHECK (controlled_for_whitespace(sort_name)),
  ADD CONSTRAINT only_non_empty_sort_name CHECK (sort_name != '');


ALTER TABLE recording_alias
   ADD CONSTRAINT recording_alias_fk_recording
   FOREIGN KEY (recording)
   REFERENCES recording(id);

ALTER TABLE recording_alias
   ADD CONSTRAINT recording_alias_fk_type
   FOREIGN KEY (type)
   REFERENCES recording_alias_type(id);

ALTER TABLE recording_alias_type
   ADD CONSTRAINT recording_alias_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES recording_alias_type(id);

ALTER TABLE release_alias
   ADD CONSTRAINT release_alias_fk_release
   FOREIGN KEY (release)
   REFERENCES release(id);

ALTER TABLE release_alias
   ADD CONSTRAINT release_alias_fk_type
   FOREIGN KEY (type)
   REFERENCES release_alias_type(id);

ALTER TABLE release_alias_type
   ADD CONSTRAINT release_alias_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES release_alias_type(id);

ALTER TABLE release_group_alias
   ADD CONSTRAINT release_group_alias_fk_release_group
   FOREIGN KEY (release_group)
   REFERENCES release_group(id);

ALTER TABLE release_group_alias
   ADD CONSTRAINT release_group_alias_fk_type
   FOREIGN KEY (type)
   REFERENCES release_group_alias_type(id);

ALTER TABLE release_group_alias_type
   ADD CONSTRAINT release_group_alias_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES release_group_alias_type(id);

COMMIT;
