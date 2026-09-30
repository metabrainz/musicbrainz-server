-- Automatically generated, do not edit.
\unset ON_ERROR_STOP

SET search_path = 'messaging';

SELECT setval('message_id_seq', COALESCE((SELECT MAX(id) FROM message), 0) + 1, FALSE);
SELECT setval('notification_id_seq', COALESCE((SELECT MAX(id) FROM notification), 0) + 1, FALSE);
