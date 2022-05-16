Installing a master MusicBrainz server
======================================

Before we begin: are you *absolutely sure* this is what you want? For the vast
majority of cases, you want either mirror or standalone: mirror if you'll be
automatically updating from the main MusicBrainz site, and standalone if you'll
be running otherwise. This document is only relevant if you intend to work on
something concerning the *production* of replication packets, or if you're
trying to create a complete fork of the MusicBrainz data for some reason. (It
might be useful if you're setting up something else and want to implement
MusicBrainz-like replication too, but that's probably not what got you here).

Still with us? Okay. Continue with the main INSTALL.md, but don't run InitDb.pl
at all yet. First, clone [dbmirror](https://github.com/metabrainz/dbmirror) and
build it with the makefile. Ensure that your DBDefs.pm file lists `RT_MASTER`
in the appropriate place. Then, run InitDb (probably with a data dump, as with
any other server setup), but including the `--with-pending` flag and the path to the
file `pending.so` created by the dbmirror build process. This should set up the
dbmirror extension, as well as adding the replication functions and such to
your database.

Replication packets and other typically-master-only tasks
---------------------------------------------------------

Once you're set up, producing replication packets is a matter of running
`admin/RunExport`, which will produce a replication packet in the folders
configured in DBDefs (which you might want to change around). For other
master-server administration tasks, a good place to start is looking at the
scripts in `admin/cron/` -- `hourly.sh` controls hourly tasks such as
replication packets and running ModBot, while `daily.sh` is for daily (or
later) tasks, like producing full data dumps, sending subscription emails,
cleaning up unused entities, and calculating statistics.

Testing replication, mirror-side
-------------------------------

If you'd like to test replication with a different master, such as one you've
set up, upload the packets you've created somewhere, and configure the mirror
to use this with the `--base-uri` option to LoadReplicationChanges. The
replication sequence values will still have to match, so you'll probably want
to either import the mirror from the same one you imported the master from
(easiest) or produce a data dump from the master and use that to import
(harder, but tests less stuff).

GPG
---

You can also configure the GPG signing of packets and data dumps, by the
`GPG_SIGN_KEY` and `GPG_ENCRYPT_KEY` options in DBDefs. The former controls the
`.asc` files created alongside the `.tar.bz2` files of replication and data
dumps both; the latter controls the encryption of the private data dump, which
includes the unsanitized editor table and data such as tags and ratings. If
you're testing this mirror-side as well, be sure to properly configure
`GPG_PUB_KEY` as well.
