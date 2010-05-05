PostgreSQL MusicBrainz Collate Extension
========================================

This extension provides collate support using the Unicode Collation
Algorithm (1), as it is implemented by the International Components
for Unicode library (2).

[1] http://www.unicode.org/unicode/reports/tr10/
[2] http://userguide.icu-project.org/collation



Requirements
============

To use this extension you will need:

- PostgreSQL version 8.3 or newer
- libicu version 3.8 or newer

You will need -dev packages installed for both of those, check that pg_config
and icu-config are in your path.


Installation
============

  $ make
  $ sudo make install
  $ cd ..

  musicbrainz_db=# set search_path=musicbrainz
  musicbrainz_db=# \i musicbrainz_collate.sql
  CREATE FUNCTION
  musicbrainz_db=# \q

You can also use InitDb.pl to install extensions, e.g. like this:

  $ ./admin/InitDb.pl --install-extension=musicbrainz_collate.sql  --extension-schema=musicbrainz

Make sure your database user has sufficient permissions to create functions.
See http://www.postgresql.org/docs/8.3/interactive/contrib.html for more
information about using postgresql extensions.


Usage
=====

This module provides a simple function to generate a sortkey from a postgresql
TEXT column.

test=> select * from unsorted order by musicbrainz_collate(column) limit 4;
 name
------
 aaa
 AAA
 äää
 ÄÄÄ
(4 rows)


License
=======

musicbrainz_collate, a postgresql extension to sort with the UCA.
Copyright 2010  MetaBrainz Foundation

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
