cd ../..

# Create the tables and adjust the alummeta columns
./psql READWRITE < sql/updates/20060310-1.sql

# Import the actual data
./MBImport.pl ../mbdump-puids.tar.bz2

# Drop all the old functions
#./psql READWRITE < sqlDropReplicationTriggers.sql
./psql READWRITE < sql/DropTriggers.sql
./psql READWRITE < sql/DropFunctions.sql

# Create all the functions over
./psql READWRITE < sql/CreateFunctions.sql
./psql READWRITE < sql/CreateTriggers.sql
#./psql READWRITE < sql/CreateReplicationTriggers.sql

# Repopulate the album metadata
./psql READWRITE < sql/PopulateAlbumMeta.sql

# Finish by creating PKs, FKs, indexes etc.
./psql READWRITE < sql/updates/20060310-2.sql

cd -
