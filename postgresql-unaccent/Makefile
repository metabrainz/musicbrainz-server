MODULE_big = unaccent
SHLIB_LINK += -lunac
OBJS = unaccent.o
DATA_built = unaccent.sql
DATA = uninstall_unaccent.sql
DOCS = README.unaccent

PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
