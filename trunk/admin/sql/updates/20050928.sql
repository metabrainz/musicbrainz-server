-- Abstract: add the wiki_transclusion table

\set ON_ERROR_STOP 1

BEGIN;

CREATE TABLE wiki_transclusion
(
     id                  SERIAL,
     page                VARCHAR(255) NOT NULL,
     revision            SMALLINT NOT NULL DEFAULT 1
);

ALTER TABLE wiki_transclusion ADD CONSTRAINT wiki_transclusion_pkey PRIMARY KEY (id);
CREATE UNIQUE INDEX wiki_transclusion_page ON wiki_transclusion (page);

-- How do we optionally include these for the main server??
--CREATE TRIGGER "reptg_wiki_transclusion"
--AFTER INSERT OR DELETE OR UPDATE ON "wiki_transclusion"
--FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();


COMMIT;

-- vi: set ts=4 sw=4 et :
