
MODULES = musicbrainz_collate
DATA = musicbrainz_collate.sql uninstall_musicbrainz_collate.sql
DOCS = README.musicbrainz_collate

PGXS := $(shell pg_config --pgxs)
include $(PGXS)

CC = gcc-4.4
ICU_LIBS = $(shell icu-config --ldflags-libsonly)

musicbrainz_collate.so: musicbrainz_collate.o
	$(CC) $(ICU_LIBS) -shared -o $@ $< 


