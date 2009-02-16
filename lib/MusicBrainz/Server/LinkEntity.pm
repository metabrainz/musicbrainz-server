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

package MusicBrainz::Server::LinkEntity;

use Carp qw( croak );

my @sorted_types;
my %classes;

sub Register
{
	my ($class, $handler) = @_;
	my $type = $handler->Type;
	$classes{$type} = $handler;
	@sorted_types = sort keys %classes;
}

sub Types { @sorted_types }

sub ValidateTypes
{
	my ($class, $types) = @_;
	
	# Verify that the types are all valid, and are in order
	my $last = undef;
	for my $type (@$types)
	{
		$classes{$type} or return 0;
		defined($last) or next;
		$type ge $last or return 0;
		$last = $type;
	}

	1;
}

sub IsValidType
{
	exists $classes{ $_[1] }
}

sub NameFromType
{
	my ($class, $type) = @_;
	my $handler = $classes{$type}
		or croak "Bad type '$type'";
	$handler->Name;
}

sub newFromTypeAndId
{
	my ($class, $dbh, $type, $id) = @_;
	my $handler = $classes{$type}
		or croak "Bad type '$type'";
	$handler->newFromId($dbh, $id);
}

sub newFromTypeAndMBId
{
	my ($class, $dbh, $type, $id) = @_;
	my $handler = $classes{$type}
		or croak "Bad type '$type'";
	$handler->newFromMBId($dbh, $id);
}

sub URLFromTypeAndId
{
	my ($class, $type, $id) = @_;
	my $handler = $classes{$type}
		or croak "Bad type '$type'";
	$handler->URLFromId($id);
}

sub Transform
{
	shift;
	map { +{ type => $_->LinkEntityName, id => $_->id } } @_;
}

################################################################################

sub AllLinkTypes
{
	my $class = shift;
	my @all;

	for my $l0 ($class->Types)
	{
		for my $l1 ($class->Types)
		{
			next if $l1 lt $l0;
			push @all, [ $l0, $l1 ];
		}
	}

	return \@all;
}

################################################################################
package MusicBrainz::Server::LinkEntity::Album;
MusicBrainz::Server::LinkEntity->Register(__PACKAGE__);
################################################################################

sub Type { "album" }
sub Name { "Album" }

sub newFromId
{
	my ($class, $dbh, $id) = @_;
	require MusicBrainz::Server::Release;
	my $object = MusicBrainz::Server::Release->new($dbh);
	$object->id($id);
	$object->LoadFromId or return undef;
	$object;
}

sub newFromMBId
{
	my ($class, $dbh, $id) = @_;
	require MusicBrainz::Server::Release;
	my $object = MusicBrainz::Server::Release->new($dbh);
	$object->mbid($id);
	$object->LoadFromId or return undef;
	$object;
}

sub URLFromId
{
	"/show/release/?releaseid=$_[1]";
}

################################################################################
package MusicBrainz::Server::LinkEntity::Artist;
MusicBrainz::Server::LinkEntity->Register(__PACKAGE__);
################################################################################

sub Type { "artist" }
sub Name { "Artist" }

sub newFromId
{
	my ($class, $dbh, $id) = @_;
	require MusicBrainz::Server::Artist;
	my $object = MusicBrainz::Server::Artist->new($dbh);
	$object->id($id);
	$object->LoadFromId or return undef;
	$object;
}

sub newFromMBId
{
	my ($class, $dbh, $id) = @_;
	require MusicBrainz::Server::Artist;
	my $object = MusicBrainz::Server::Artist->new($dbh);
	$object->mbid($id);
	$object->LoadFromId or return undef;
	$object;
}

sub URLFromId
{
	"/show/artist/?artistid=$_[1]";
}

################################################################################
package MusicBrainz::Server::LinkEntity::Track;
MusicBrainz::Server::LinkEntity->Register(__PACKAGE__);
################################################################################

sub Type { "track" }
sub Name { "Track" }

sub newFromId
{
	my ($class, $dbh, $id) = @_;
	require MusicBrainz::Server::Track;
	my $object = MusicBrainz::Server::Track->new($dbh);
	$object->id($id);
	$object->LoadFromId or return undef;
	$object;
}

sub newFromMBId
{
	my ($class, $dbh, $id) = @_;
	require MusicBrainz::Server::Track;
	my $object = MusicBrainz::Server::Track->new($dbh);
	$object->mbid($id);
	$object->LoadFromId or return undef;
	$object;
}

sub URLFromId
{
	"/show/track/?trackid=$_[1]";
}

################################################################################
package MusicBrainz::Server::LinkEntity::URL;
MusicBrainz::Server::LinkEntity->Register(__PACKAGE__);
################################################################################

sub Type { "url" }
sub Name { "URL" }

sub newFromId
{
	my ($class, $dbh, $id) = @_;
	require MusicBrainz::Server::URL;
	my $object = MusicBrainz::Server::URL->new($dbh);
	$object->newFromId($id);
}

sub newFromMBId
{
	my ($class, $dbh, $id) = @_;
	require MusicBrainz::Server::URL;
	my $object = MusicBrainz::Server::URL->new($dbh);
	$object->newFromMBId($id);
}

sub URLFromId
{
	"/show/url/?urlid=$_[1]";
}

################################################################################
package MusicBrainz::Server::LinkEntity::Label;
MusicBrainz::Server::LinkEntity->Register(__PACKAGE__);
################################################################################

sub Type { "label" }
sub Name { "Label" }

sub newFromId
{
	my ($class, $dbh, $id) = @_;
	require MusicBrainz::Server::Label;
	my $object = MusicBrainz::Server::Label->new($dbh);
	$object->newFromId($id);
}

sub newFromMBId
{
	my ($class, $dbh, $id) = @_;
	require MusicBrainz::Server::Label;
	my $object = MusicBrainz::Server::Label->new($dbh);
	$object->newFromMBId($id);
}

sub URLFromId
{
	"/show/label/?label=$_[1]";
}

1;
# eof LinkEntity.pm
