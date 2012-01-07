MODULE_big = musicbrainz_collate
OBJS = musicbrainz_collate.o
DATA = musicbrainz_collate.sql uninstall_musicbrainz_collate.sql
DOCS = README.musicbrainz_collate

SHLIB_LINK = $(shell icu-config --ldflags)

PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)

