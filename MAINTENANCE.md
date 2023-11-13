MusicBrainz Server Maintenance
==============================

Indexes and collations
----------------------

After upgrading your system running PostgreSQL, you may encounter the
following kinds of warnings in the logs of your PostgreSQL database server:

    WARNING:  collation "XYZ" has version mismatch
    DETAIL:  The collation in the database was created using version 1.2.3,
             but the operating system provides version 4.5.6.
    HINT:  Rebuild all objects affected by this collation and run
           ALTER COLLATION "XYZ" REFRESH VERSION, or build PostgreSQL with
           the right library version.

This can occur if the versions of glibc or libicu change on your system.
As the warning indicates, the correct course of action is to rebuild all
indexes using the affected collations. Since PostgreSQL doesn't currently
have a convenient way of doing this, MusicBrainz provides its own script
for that purpose:

    ./admin/RebuildIndexesUsingCollations.pl

This will connect to the MAINTENANCE database defined in lib/DBDefs.pm
and run `REINDEX` statements for every index using the "default" or
"musicbrainz" collations. By default, this is done `CONCURRENTLY` so as
not to disrupt existing database traffic; if you don't mind temporarily
locking the tables against writes, you can disable concurrent reindexing
and speed things up:

    ./admin/RebuildIndexesUsingCollations.pl --noconcurrently
