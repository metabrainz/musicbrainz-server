BEGIN;

SELECT * INTO TEMPORARY edit_20110525 FROM edit WHERE type IN (90, 91, 92);
SELECT * INTO TEMPORARY edit_artist_20110525
FROM edit_artist JOIN edit_20110525 edit ON edit.id = edit_artist.edit;

\copy edit_20110525 to '20110525_rawdata_edit.dat';
\copy edit_artist_20110525 to '20110525_rawdata_edit_artist.dat';

COMMIT;
