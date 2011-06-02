BEGIN;

SELECT *
  INTO TEMPORARY edit_20110527
  FROM edit
 WHERE type IN (20, 21)
   AND data LIKE '%"artist_credit"%'
   AND data NOT LIKE '%"names"%';

\copy edit_20110527 to '20110527_rawdata_edit.dat';

COMMIT;
