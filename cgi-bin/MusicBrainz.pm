#!/usr/bin/perl -w
# vi: set ts=4 sw=4 :
#____________________________________________________________________________
#
#   MusicBrainz -- the open internet music database
#
#   Copyright (C) 2000 Robert Kaye
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
#   $Id$
#____________________________________________________________________________

use 5.008;
no warnings qw( portable );

package MusicBrainz;

use strict;
use DBDefs;
use MusicBrainz::Server::Replication ':replication_type';
use Carp qw( carp cluck croak );
use Encode qw( decode encode );

sub new
{
    my $class = shift;
    bless {}, ref($class) || $class;
}

################################################################################
# Database connect / disconnect
################################################################################

sub Login
{
	my ($this, %opts) = @_;

	my $db = $opts{'db'};

	{
		last if $db;

		$db = $MusicBrainz::db;
		last if $db;

		{
			$INC{'Apache.pm'} or last;
			my $r = eval{ Apache->request } or last;
			$db = $r->dir_config->get("MBDatabase");
		}
		last if $db;
	}

	$db = (&DBDefs::REPLICATION_TYPE == RT_SLAVE ? "READONLY" : "READWRITE")
		if not defined $db;

	if (not ref($db) and $db =~ /,/)
	{
		our %round_robin;
		my $arr = ($round_robin{$db} ||= [ split /,/, $db ]);
		$db = shift @$arr;
		push @$arr, $db;
	}

	unless (ref $db)
	{
		$db = MusicBrainz::Server::Database->get($db)
			or croak "No such database '$db', Check your Database section in DBDefs.pm and make sure that ".
			         "READWRITE, READONLY and RAWDATA are all defined and correct.";
	}

   require DBI;
   $this->{DBH} = DBI->connect($db->dbi_args);
   return 0 if (!$this->{DBH});

	# Since DBD::Pg 1.4, $dbh->prepare uses real PostgreSQL prepared
	# queries, but the codebase uses some queries that are not valid on
	# the server side.
	require DBD::Pg;
	if ($DBD::Pg::VERSION >= 1.40)
	{
		$this->{DBH}->{pg_server_prepare} = 0;
	}


	# Naughty!  Might break in future.  If it does just do the two "SET"
	# commands every time, like we used to before this was added.
	my $tied = tied %{ $this->{DBH} };
	if (not $tied->{'_mb_prepared_connection_'})
	{
		require Sql;
		my $sql = Sql->new($this->{DBH});

		$sql->AutoCommit(1);
		$sql->Do("SET TIME ZONE 'UTC'");
		$sql->AutoCommit(1);
		$sql->Do("SET CLIENT_ENCODING = 'UNICODE'");

		$tied->{'_mb_prepared_connection_'} = 1;
	}

   return 1;
}

# Logout and DESTROY are pointless under Apache::DBI (since ->disconnect does
# nothing).  But it does do something under normal DBI (e.g. under cron).

sub Logout
{
   my ($this) = @_;

   $this->{DBH}->disconnect() if ($this->{DBH});
}

sub DESTROY
{
    shift()->Logout;
}

1;
# eof MusicBrainz.pm
