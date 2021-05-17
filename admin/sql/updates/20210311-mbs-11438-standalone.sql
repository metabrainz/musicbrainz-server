\set ON_ERROR_STOP 1

BEGIN;

ALTER TABLE artist_release
    ADD CONSTRAINT artist_release_fk_artist
    FOREIGN KEY (artist)
    REFERENCES artist(id)
    ON DELETE CASCADE;

ALTER TABLE artist_release
    ADD CONSTRAINT artist_release_fk_release
    FOREIGN KEY (release)
    REFERENCES release(id)
    ON DELETE CASCADE;

ALTER TABLE artist_release_group
    ADD CONSTRAINT artist_release_group_fk_artist
    FOREIGN KEY (artist)
    REFERENCES artist(id)
    ON DELETE CASCADE;

ALTER TABLE artist_release_group
    ADD CONSTRAINT artist_release_group_fk_release_group
    FOREIGN KEY (release_group)
    REFERENCES release_group(id)
    ON DELETE CASCADE;

CREATE TRIGGER b_upd_artist_credit_name BEFORE UPDATE ON artist_credit_name
    FOR EACH ROW EXECUTE PROCEDURE b_upd_artist_credit_name();

CREATE TRIGGER a_ins_release_group_secondary_type_join AFTER INSERT ON release_group_secondary_type_join
    FOR EACH ROW EXECUTE PROCEDURE a_ins_release_group_secondary_type_join();

CREATE TRIGGER a_del_release_group_secondary_type_join AFTER DELETE ON release_group_secondary_type_join
    FOR EACH ROW EXECUTE PROCEDURE a_del_release_group_secondary_type_join();

CREATE TRIGGER b_upd_release_group_secondary_type_join BEFORE UPDATE ON release_group_secondary_type_join
    FOR EACH ROW EXECUTE PROCEDURE b_upd_release_group_secondary_type_join();

CREATE TRIGGER a_ins_release_label AFTER INSERT ON release_label
    FOR EACH ROW EXECUTE PROCEDURE a_ins_release_label();

CREATE TRIGGER a_upd_release_label AFTER UPDATE ON release_label
    FOR EACH ROW EXECUTE PROCEDURE a_upd_release_label();

CREATE TRIGGER a_del_release_label AFTER DELETE ON release_label
    FOR EACH ROW EXECUTE PROCEDURE a_del_release_label();

CREATE CONSTRAINT TRIGGER apply_artist_release_group_pending_updates
    AFTER INSERT OR UPDATE OR DELETE ON release DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE apply_artist_release_group_pending_updates();

CREATE CONSTRAINT TRIGGER apply_artist_release_pending_updates
    AFTER INSERT OR UPDATE OR DELETE ON release DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE apply_artist_release_pending_updates();

CREATE CONSTRAINT TRIGGER apply_artist_release_pending_updates
    AFTER INSERT OR UPDATE OR DELETE ON release_country DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE apply_artist_release_pending_updates();

CREATE CONSTRAINT TRIGGER apply_artist_release_pending_updates
    AFTER INSERT OR UPDATE OR DELETE ON release_first_release_date DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE apply_artist_release_pending_updates();

CREATE CONSTRAINT TRIGGER apply_artist_release_group_pending_updates
    AFTER INSERT OR UPDATE OR DELETE ON release_group DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE apply_artist_release_group_pending_updates();

CREATE CONSTRAINT TRIGGER apply_artist_release_group_pending_updates
    AFTER UPDATE ON release_group_meta DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE apply_artist_release_group_pending_updates();

CREATE CONSTRAINT TRIGGER apply_artist_release_group_pending_updates
    AFTER INSERT OR DELETE ON release_group_secondary_type_join DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE apply_artist_release_group_pending_updates();

CREATE CONSTRAINT TRIGGER apply_artist_release_pending_updates
    AFTER INSERT OR UPDATE OR DELETE ON release_label DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE apply_artist_release_pending_updates();

CREATE CONSTRAINT TRIGGER apply_artist_release_group_pending_updates
    AFTER INSERT OR UPDATE OR DELETE ON track DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE apply_artist_release_group_pending_updates();

CREATE CONSTRAINT TRIGGER apply_artist_release_pending_updates
    AFTER INSERT OR UPDATE OR DELETE ON track DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE apply_artist_release_pending_updates();

COMMIT;
