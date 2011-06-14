BEGIN;

SELECT * INTO TEMPORARY edit_20110606 FROM edit WHERE type = 11 AND data LIKE '%"entity_id":%';

\copy edit_20110606 to '20110606_rawdata_edit.dat';

SELECT * INTO TEMPORARY edit_20110607 FROM edit WHERE type = 34 AND data LIKE '%"label":{}%';

\copy edit_20110607 to '20110607_rawdata_edit.dat';

COMMIT;
