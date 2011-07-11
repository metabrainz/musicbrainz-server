MODULE_big = musicbrainz_unaccent
OBJS = musicbrainz_unaccent.o
DATA_built = musicbrainz_unaccent.sql
DATA = uninstall_musicbrainz_unaccent.sql
DOCS = README.musicbrainz_unaccent

PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
