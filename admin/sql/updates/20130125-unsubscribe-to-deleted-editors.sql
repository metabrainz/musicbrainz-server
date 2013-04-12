BEGIN;

DELETE FROM editor_subscribe_editor
WHERE subscribed_editor IN (
  SELECT id FROM editor WHERE name ~ E'^Deleted Editor #(\\d+)$'
  order by name asc
);

COMMIT;
