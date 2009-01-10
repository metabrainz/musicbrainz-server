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
use Carp qw( carp croak cluck );
use Errno qw( EEXIST );

sub entity_type { "url" }

sub new
{
	my ($class, $dbh) = @_;
	my $self = $class->SUPER::new($dbh);
	$self->{refcount} = undef;
	$self;
}

# Artist specific accessor function. Others are inherted from TableBase
sub url
{
    my ($self, $new_url) = @_;

    if (defined $new_url) { $self->{url} = $new_url; }
    return $self->{url};
}

sub desc
{
    my ($self, $new_desc) = @_;

    if (defined $new_desc) { $self->{desc} = $new_desc; }
    return $self->{desc};
}

sub name
{
    my ($self) = @_;
    return $_[0]->url;
}

sub LoadFromId
{
    my $self = shift;
    my $id;

    if ($id = $self->id)
    {
        my $url = $self->newFromId($id)
            or return undef;

        %$self = %$url;
        return 1;
    }
    elsif ($id = $self->mbid)
    {
        my $url = $self->newFromMBId($id)
            or return undef;

        %$self = %$url;
        return 1;
    }
    else
    {
        cluck "MusicBrainz::Server::URL::LoadFromId is called with no ID/MBID set\n";
        return undef;
    }
}

sub newFromId
{
	my $self = shift;
	$self = $self->new(shift) if not ref $self;
	my $id = shift;

	my $sql = Sql->new($self->dbh);

	my $row = $sql->SelectSingleRowHash(
		"SELECT id, gid AS mbid, url, description, refcount, modpending
		   FROM url
		  WHERE id = ?",
		$id,
	) or return undef;

	$row->{'desc'} = delete $row->{'description'};

	$row->{dbh} = $self->dbh;
	bless $row, ref($self);
	return $row;
}

sub newFromMBId
{
	my $self = shift;
	$self = $self->new(shift) if not ref $self;
	my $id = shift;

	my $sql = Sql->new($self->dbh);

	my $row = $sql->SelectSingleRowHash(
		"SELECT id, gid AS mbid, url, description, refcount, modpending
		   FROM url
		  WHERE gid = ?",
		$id,
	) or return undef;

	$row->{'desc'} = delete $row->{'description'};

	$row->{dbh} = $self->dbh;
	bless $row, ref($self);
	return $row;
}

sub Insert
{
	my ($self, $url, $desc) = @_;

	my $sql = Sql->new($self->dbh);

	$sql->Do("LOCK TABLE url IN EXCLUSIVE MODE");

	# Check to make sure we don't already have self in the database
	if (my $other = $self->newFromURL($url))
	{
		$sql->Do("UPDATE url SET refcount = refcount + 1 WHERE id = ?", $other->id);
		$self->{id} = $other->id;
		$self->{url} = $other->url;
		$self->{desc} = $other->desc;
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

	my $id = $self->id
		or croak "Missing url ID in UpdateURL";
	my $url = $self->url;
	defined($url) && $url ne ""
		or croak "Missing url in UpdateURL";
	my $desc = $self->desc;

	MusicBrainz::Server::Validation::TrimInPlace($url);

	my $sql = Sql->new($self->dbh);

	$sql->Do("LOCK TABLE url IN EXCLUSIVE MODE");

	if (my $other = $self->newFromURL($url))
	{
		if ($other->id != $self->id)
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

	my $sql = Sql->new($self->dbh);

	my $row = $sql->SelectSingleRowHash(
		"SELECT * FROM url
		WHERE url = ?
		LIMIT 1",
		$url,
	) or return undef;

	$row->{desc} = delete $row->{'description'};
	$row->{dbh} = $self->dbh;
	bless $row, ref($self);
}

sub Remove
{
	my $self = shift;

	my $sql = Sql->new($self->dbh);

	my $id = $self->id
		or croak "Missing ID in Remove";

	if (!defined $self->{refcount})
	{
		$self->LoadFromId($id)
			or return undef;
	}
	if ($self->{refcount} > 1)
	{
		$sql->Do("UPDATE url SET refcount = refcount - 1 WHERE id = ?", $self->id)
			or return undef;
	}
	else
	{
		$sql->Do("DELETE FROM url WHERE id = ?", $self->id)
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
