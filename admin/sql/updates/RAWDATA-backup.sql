BEGIN;

SELECT * INTO TEMPORARY edit_20110610 FROM edit WHERE type = 37 AND data LIKE '%"label":{}%';

\copy edit_20110610 to '20110610_rawdata_edit.dat';

COMMIT;
