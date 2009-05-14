BEGIN;

CREATE TABLE label_alias
(
    id                 SERIAL,
    label              INTEGER NOT NULL, -- references label.id
    name               INTEGER NOT NULL, -- references label_name.id
    editpending        INTEGER DEFAULT 0,
);

ALTER TABLE label_alias ADD CONSTRAINT label_alias_pk PRIMARY KEY (id);

ALTER TABLE label_alias ADD CONSTRAINT label_alias_fk_label
    FOREIGN KEY (label) REFERENCES label(id);

ALTER TABLE label_alias ADD CONSTRAINT label_alias_fk_name
    FOREIGN KEY (name) REFERENCES label_name(id);

CREATE INDEX label_alias_idx_name ON label_alias (name);
CREATE INDEX label_alias_idx_label ON label_alias (label);

CREATE OR REPLACE FUNCTION a_ins_label_alias() RETURNS trigger AS $$
BEGIN
    PERFORM inc_name_refcount('label', NEW.name, 1);
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_upd_label_alias() RETURNS trigger AS $$
BEGIN
    IF NEW.name != OLD.name THEN
        PERFORM dec_name_refcount('label', OLD.name, 1);
        PERFORM inc_name_refcount('label', NEW.name, 1);
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_del_label_alias() RETURNS trigger AS $$
BEGIN
    PERFORM dec_name_refcount('label', OLD.name, 1);
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER a_ins_label_alias AFTER INSERT ON label_alias
    FOR EACH ROW EXECUTE PROCEDURE a_ins_label_alias();

CREATE TRIGGER a_upd_label_alias AFTER UPDATE ON label_alias
    FOR EACH ROW EXECUTE PROCEDURE a_upd_label_alias();

CREATE TRIGGER a_del_label_alias AFTER DELETE ON label_alias
    FOR EACH ROW EXECUTE PROCEDURE a_del_label_alias();

COMMIT;