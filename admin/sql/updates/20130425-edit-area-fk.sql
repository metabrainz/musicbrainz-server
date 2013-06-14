BEGIN;

ALTER TABLE edit_area
   ADD CONSTRAINT edit_area_fk_edit
   FOREIGN KEY (edit)
   REFERENCES edit(id);

ALTER TABLE edit_area
   ADD CONSTRAINT edit_area_fk_area
   FOREIGN KEY (area)
   REFERENCES area(id)
   ON DELETE CASCADE;

COMMIT;
