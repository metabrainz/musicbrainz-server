BEGIN;

DELETE FROM edit_artist WHERE (edit, artist) IN (SELECT edit, edit_artist.artist FROM edit_artist LEFT JOIN artist ON artist.id = edit_artist.artist WHERE artist.id IS NULL);
DELETE FROM edit_label WHERE (edit, label) IN (SELECT edit, edit_label.label FROM edit_label LEFT JOIN label ON label.id = edit_label.label WHERE label.id IS NULL);
DELETE FROM edit_recording WHERE (edit, recording) IN (SELECT edit, edit_recording.recording FROM edit_recording LEFT JOIN recording ON recording.id = edit_recording.recording WHERE recording.id IS NULL);
DELETE FROM edit_release WHERE (edit, release) IN (SELECT edit, edit_release.release FROM edit_release LEFT JOIN release ON release.id = edit_release.release WHERE release.id IS NULL);
DELETE FROM edit_release_group WHERE (edit, release_group) IN (SELECT edit, edit_release_group.release_group FROM edit_release_group LEFT JOIN release_group ON release_group.id = edit_release_group.release_group WHERE release_group.id IS NULL);
DELETE FROM edit_url WHERE (edit, url) IN (SELECT edit, edit_url.url FROM edit_url LEFT JOIN url ON url.id = edit_url.url WHERE url.id IS NULL);
DELETE FROM edit_work WHERE (edit, work) IN (SELECT edit, edit_work.work FROM edit_work LEFT JOIN work ON work.id = edit_work.work WHERE work.id IS NULL);

COMMIT;
