#____________________________________________________________________________
#
#	MusicBrainz -- the open internet music database
#
#	Copyright (C) 2000 Robert Kaye
#
#	This program is free software; you can redistribute it and/or modify
#	it under the terms of the GNU General Public License as published by
#	the Free Software Foundation; either version 2 of the License, or
#	(at your option) any later version.
#
#	This program is distributed in the hope that it will be useful,
#	but WITHOUT ANY WARRANTY; without even the implied warranty of
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#	GNU General Public License for more details.
#
#	You should have received a copy of the GNU General Public License
#	along with self program; if not, write to the Free Software
#	Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
#	$Id$
#____________________________________________________________________________

package MusicBrainz::Server::URL;

use TableBase;
{ our @ISA = qw( TableBase ) }

use strict;
use DBDefs;
use Carp qw( carp croak );
use Errno qw( EEXIST );

sub new
{
	my ($class, $dbh) = @_;
	my $self = $class->SUPER::new($dbh);
	$self->{refcount} = undef;
	$self;
}

# Artist specific accessor function. Others are inherted from TableBase
sub SetURL { $_[0]->{url} = $_[1]; }
sub GetURL { return $_[0]->{url}; }
sub SetDesc { $_[0]->{desc} = $_[1]; }
sub GetDesc { return $_[0]->{desc}; }
sub GetName { return $_[0]->GetURL; }

sub newFromId
{
	my $self = shift;
	$self = $self->new(shift) if not ref $self;
	my $id = shift;

	my $sql = Sql->new($self->{DBH});

	my $row = $sql->SelectSingleRowHash(
		"SELECT id, gid AS mbid, url, description, refcount, modpending
		   FROM url
		  WHERE id = ?",
		$id,
	) or return undef;

	$row->{'desc'} = delete $row->{'description'};

	$row->{DBH} = $self->{DBH};
	bless $row, ref($self);
	return $row;
}

sub LoadFromId
{
	my ($self) = @_;

	my $obj = $self->newFromId($self->GetId)
		or return undef;

	%$self = %$obj;
	return 1;
}

sub Insert
{
	my ($self, $url, $desc) = @_;

	my $sql = Sql->new($self->{DBH});

	$sql->Do("LOCK TABLE url IN EXCLUSIVE MODE");

	# Check to make sure we don't already have self in the database
	if (my $other = $self->newFromURL($url))
	{
		$sql->Do("UPDATE url SET refcount = refcount + 1 WHERE id = ?", $other->GetId);
		$self->{id} = $other->GetId;
		$self->{url} = $other->GetURL;
		$self->{desc} = $other->GetDesc;
		return 1;
	}

	my $mbid = $self->CreateNewGlobalId;
	$sql->Do(
		"INSERT INTO url (url, description, refcount, gid)
			VALUES (?, ?, 1, ?)",
		$url,
		$desc,
		$mbid,
	) or return 0;
	$self->{id} = $sql->GetLastInsertId('url');
	$self->{url} = $url;
	$self->{desc} = $desc;

	1;
}

sub UpdateURL
{
	my $self = shift;
	my $otherref = shift;

	my $id = $self->GetId
		or croak "Missing url ID in UpdateURL";
	my $url = $self->GetURL;
	defined($url) && $url ne ""
		or croak "Missing url in UpdateURL";
	my $desc = $self->GetDesc;

	MusicBrainz::Server::Validation::TrimInPlace($url);

	my $sql = Sql->new($self->{DBH});

	$sql->Do("LOCK TABLE url IN EXCLUSIVE MODE");

	if (my $other = $self->newFromURL($url))
	{
		if ($other->GetId != $self->GetId)
		{
			$$otherref = $other if $otherref;
			$! = EEXIST;
			return 0;
		}
	}

	$sql->Do(
		"UPDATE url SET url = ?, description = ? WHERE id = ?",
		$url,
		$desc,
		$id,
	);

	1;
}

sub newFromURL
{
	my $self = shift;
	$self = $self->new(shift, shift) if not ref $self;
	my $url = shift;

	MusicBrainz::Server::Validation::TrimInPlace($url) if defined $url;
	if (not defined $url or $url eq "")
	{
		carp "Missing url in newFromURL";
		return undef;
	}

	my $sql = Sql->new($self->{DBH});

	my $row = $sql->SelectSingleRowHash(
		"SELECT * FROM url
		WHERE url = ?
		LIMIT 1",
		$url,
	) or return undef;

	$row->{desc} = delete $row->{'description'};
	$row->{DBH} = $self->{DBH};
	bless $row, ref($self);
}

sub Remove
{
	my $self = shift;

	my $sql = Sql->new($self->{DBH});

	my $id = $self->GetId
		or croak "Missing ID in Remove";

	if (!defined $self->{refcount})
	{
		$self->LoadFromId($id)
			or return undef;
	}
	if ($self->{refcount} > 1)
	{
		$sql->Do("UPDATE url SET refcount = refcount - 1 WHERE id = ?", $self->GetId)
			or return undef;
	}
	else
	{
		$sql->Do("DELETE FROM url WHERE id = ?", $self->GetId)
			or return undef;
	}

	1;
}

sub IsLegalURL
{
	my ($class, $url) = @_;

	return 0 if $url =~ /\s/;

	require URI;
	my $u = eval { URI->new($url) }
		or return 0;

	return 0 if $u->scheme eq '';
	return 0 unless $u->authority =~ /\./;
	return 1;
}

1;
# vi: set ts=4 sw=4 :
