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

use strict;

package MusicBrainz::Server::Country;

use base qw( TableBase );
use Carp;

# id / id - see TableBase
# name / name - see TableBase
sub GetISOCode	{ $_[0]{isocode} }
sub SetISOCode	{ $_[0]{isocode} = $_[1] }

sub _id_cache_key
{
    my ($class, $id) = @_;
    "country-id-" . int($id);
}

sub _GetAllCacheKey
{
	"country-all";
}

sub newFromId
{
	my $self = shift;
    $self = $self->new(shift) if not ref $self;
	my $id = shift;

    my $key = $self->_id_cache_key($id);
    my $obj = MusicBrainz::Server::Cache->get($key);

    if ($obj)
    {
       	$$obj->SetDBH($self->GetDBH) if $$obj;
		return $$obj;
    }

   	my $sql = Sql->new($self->GetDBH);

	$obj = $self->_new_from_row(
		$sql->SelectSingleRowHash(
			"SELECT * FROM country WHERE id = ?",
			$id,
		),
	);

    # We can't store DBH in the cache...
    delete $obj->{DBH} if $obj;
    MusicBrainz::Server::Cache->set($key, \$obj);
    $obj->SetDBH($self->GetDBH) if $obj;

    return $obj;
}

sub All
{
	my $self = shift;
    $self = $self->new(shift) if not ref $self;

    my $key = $self->_GetAllCacheKey;
    my $obj = MusicBrainz::Server::Cache->get($key);

    if ($obj)
    {
		$_->SetDBH($self->GetDBH) for @$obj;
		return @$obj;
    }

   	my $sql = Sql->new($self->GetDBH);

	my @list = map { $self->_new_from_row($_) }
		@{
			$sql->SelectListOfHashes(
				"SELECT * FROM country ORDER BY name",
			),
		};

    # We can't store DBH in the cache...
    delete $_->{DBH} for @list;
    MusicBrainz::Server::Cache->set($key, \@list);
    $_->SetDBH($self->GetDBH) for @list;

	return @list;
}

1;
# eof Country.pm
