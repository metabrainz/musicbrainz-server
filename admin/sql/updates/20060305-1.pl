#!/usr/bin/perl -w
# vi: set ts=4 sw=4 :
#____________________________________________________________________________
#
#   MusicBrainz -- the open internet music database
#
#   Copyright (C) 2006 Björn Krombholz
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
#   
#   This is a simple script that updates the modsfailed counter for
#   every moderator in the DB. It needs to be run only once (if at all)
#   to fix results of a bug in server versions < the 20060223 release.
#
#   $Id$
#____________________________________________________________________________

use 5.008;
use strict;

use FindBin;
use lib "$FindBin::Bin/../../../lib";

require DBDefs;
require MusicBrainz;
require Sql;
require Moderation;

#use ModDefs qw( STATUS_FAILEDDEP STATUS_ERROR STATUS_FAILEDPREREQ );

my $verbose = 1;

my $mb = MusicBrainz->new;
$mb->Login;
my $sql = Sql->new($mb->{dbh});

$verbose
	? open(LOG, ">&STDOUT")
	: open(LOG, ">/dev/null");


################################################################################

print LOG localtime() . " : Fixing failed mods counters.\n";


# define function that loops over all moderators
$sql->AutoCommit;
my $func = $sql->Do(<<'EOF');
CREATE OR REPLACE FUNCTION moderator_fix_failed_count() RETURNS void AS
'
	DECLARE
		i moderator%ROWTYPE;
		n integer = 0;
	BEGIN
		FOR i IN SELECT * FROM moderator where modsaccepted > 0 or modsrejected > 0 ORDER BY id LOOP
			n := n+1;
			UPDATE moderator
			  SET modsfailed = (
				SELECT COUNT(*) FROM moderation_closed AS mc
				WHERE mc.moderator = i.id AND status >= 3 AND status <= 5
			  )
			  WHERE id = i.id;
			IF n % 10000 = 0
			THEN
				RAISE INFO \'Updated moderators: %\', i.id;
			END IF;
		END LOOP;
	END;
'
LANGUAGE plpgsql;
EOF

# run the function
$sql->AutoCommit;
$sql->Do('SELECT moderator_fix_failed_count();');

# remove the temporary function
$sql->Do('DROP FUNCTION moderator_fix_failed_count();');

print LOG localtime() . " : Done!\n";

# eof FixFailedModCount
