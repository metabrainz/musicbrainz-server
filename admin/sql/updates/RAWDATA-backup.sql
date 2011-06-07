BEGIN;

SELECT * INTO TEMPORARY edit_20110607 FROM edit WHERE type = 34 AND data LIKE '%"label":{}%';

\copy edit_20110607 to '20110607_rawdata_edit.dat';

COMMIT;
