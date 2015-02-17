\set ON_ERROR_STOP 1
BEGIN;

ALTER TABLE edit_series
    ADD CONSTRAINT edit_series_fk_edit
    FOREIGN KEY (edit)
    REFERENCES edit(id);

ALTER TABLE edit_series
    ADD CONSTRAINT edit_series_fk_series
    FOREIGN KEY (series)
    REFERENCES series(id)
    ON DELETE CASCADE;

COMMIT;
