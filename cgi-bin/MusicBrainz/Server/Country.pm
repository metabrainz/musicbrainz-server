#!/home/httpd/musicbrainz/mb_server/cgi-bin/perl -w
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

use strict;

package MusicBrainz::Server::Country;

use base qw( TableBase );
use Carp;

# GetId / SetId - see TableBase
# GetName / SetName - see TableBase
sub GetISOCode	{ $_[0]{isocode} }
sub SetISOCode	{ $_[0]{isocode} = $_[1] }

sub newFromId
{
	my ($self, $id) = @_;
   	my $sql = Sql->new($self->{DBH});
	$self->_new_from_row(
		$sql->SelectSingleRowHash(
			"SELECT * FROM country WHERE id = ?",
			$id,
		),
	);
}

sub newFromISOCode
{
	my ($self, $isocode) = @_;
   	my $sql = Sql->new($self->{DBH});
	$self->_new_from_row(
		$sql->SelectSingleRowHash(
			"SELECT * FROM country WHERE LOWER(isocode) = ?",
			lc($isocode),
		),
	);
}

sub All
{
	my ($self, $isocode) = @_;
   	my $sql = Sql->new($self->{DBH});
	map { $self->_new_from_row($_) }
		@{
			$sql->SelectListOfHashes(
				"SELECT * FROM country ORDER BY name",
			),
		};
}

sub GetCountryIdToNameHash
{
	my $self = shift;
   	my $sql = Sql->new($self->{DBH});
	my %h = map { $_->[0], $_->[1] }
		@{
			$sql->SelectListOfLists(
				"SELECT id, name FROM country ORDER BY name",
			),
		};
	wantarray ? %h : \%h;
}

1;
# eof Country.pm
