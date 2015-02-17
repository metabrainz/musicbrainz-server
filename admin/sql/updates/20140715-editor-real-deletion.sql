CREATE INDEX CONCURRENTLY edit_note_idx_editor ON edit_note (editor);
BEGIN;
WITH editors (editor_id) AS (
           SELECT id FROM editor WHERE deleted
    EXCEPT SELECT editor FROM annotation
    EXCEPT SELECT candidate FROM autoeditor_election
    EXCEPT SELECT proposer FROM autoeditor_election
    EXCEPT SELECT seconder_1 FROM autoeditor_election
    EXCEPT SELECT seconder_2 FROM autoeditor_election
    EXCEPT SELECT voter FROM autoeditor_election_vote
    EXCEPT SELECT editor FROM edit
    EXCEPT SELECT editor FROM edit_note
    EXCEPT SELECT editor FROM vote)
DELETE FROM editor WHERE editor.id IN (SELECT editor_id FROM editors);
COMMIT;
