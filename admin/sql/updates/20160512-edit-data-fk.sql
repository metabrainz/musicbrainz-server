\set ON_ERROR_STOP 1
BEGIN;

ALTER TABLE edit_data
  ADD CONSTRAINT edit_data_fk_edit
  FOREIGN KEY (edit)
  REFERENCES edit(id);

COMMIT;
