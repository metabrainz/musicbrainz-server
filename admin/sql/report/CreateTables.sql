BEGIN;

SET search_path = report;

CREATE TABLE report.index (
    report_name TEXT NOT NULL PRIMARY KEY,
    generated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

COMMIT;
