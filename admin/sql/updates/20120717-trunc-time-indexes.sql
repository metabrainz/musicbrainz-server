CREATE INDEX CONCURRENTLY ON edit (date_trunc('day', open_time AT TIME ZONE 'UTC'));
CREATE INDEX CONCURRENTLY ON edit (date_trunc('day', close_time AT TIME ZONE 'UTC'));
CREATE INDEX CONCURRENTLY ON edit (date_trunc('day', expire_time AT TIME ZONE 'UTC'));
