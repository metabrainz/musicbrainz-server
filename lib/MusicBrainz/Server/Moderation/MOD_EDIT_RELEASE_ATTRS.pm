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

package MusicBrainz::Server::Moderation::MOD_EDIT_RELEASE_ATTRS;

use ModDefs;
use base 'Moderation';

sub Name { "Edit Release Attributes" }
(__PACKAGE__)->RegisterHandler;

=pod

There are two cases here: single album, and multiple album.

Both:
	new hash includes: AttrType => ?, AttrStatus, => ?
	artist		album.artist (or VARTIST_ID if multiple mixed)
	tab.col		album.attributes

Single Album:
	new hash includes: AlbumId0, AlbumName0
	rowid		same as AlbumId0
	prev		comma-sep list of sorted attributes

Multiple Album:
	new hash includes: AlbumId/n/, AlbumName/n/, Prev/n/ for n = 0 ..
	rowid		0
	prev		""

=cut

sub PreInsert
{
	my ($self, %opts) = @_;

	my $albums = $opts{'albums'} or die;
	my $type = $opts{'attr_type'} || 0;
	my $status = $opts{'attr_status'} || 0;

	my $attrs = [ grep { $_ } ($type, $status) ];

	my %new;
	my %artists;

	$new{"Attributes"} = join ",", @$attrs;

	my $fCanAutoMod = 1;

	my $seq = 0;
	for my $al (@$albums)
	{
		die "Cannot edit attributes of 'non-album tracks' release"
			if $al->IsNonAlbumTracks;
		my $prev = join ",", @{ $al->attributes };
		next if $prev eq $new{'Attributes'};

		$new{"AlbumId$seq"} = $al->id;
		$new{"AlbumName$seq"} = $al->name;
		$new{"Prev$seq"} = $prev;

		my ($t, $s) = $al->release_type_and_status;
		$fCanAutoMod = 0
			if defined($t) and $t != $type;
		$fCanAutoMod = 0
			if defined($s) and $s != $status;

		++$artists{$al->artist};
		++$seq;
	}

	$new{can_automod} = $fCanAutoMod;

	unless ($seq)
	{
		$self->SuppressInsert;
		return;
	}

	# if in single edit mod, file moderation under release object.
	# If all n releases are stored under artist x use this
	# artist as the moderation artist, else VA.
	$self->row_id($albums->[0]->id) if ($seq == 1);
	$self->artist(
		keys(%artists) > 1
			? &ModDefs::VARTIST_ID
			: $albums->[0]->artist
	);

	$self->table("album");
	$self->column("id");
	$self->row_id($albums->[0]->id);
	$self->new_data($self->ConvertHashToNew(\%new));

	# This mod is immediately applied, and undone later if rejected.
 	for my $al (@$albums)
	{
	  	$al->attributes(@$attrs);
  		$al->UpdateAttributes;
	}
}

sub IsAutoEdit
{
	my ($self) = @_;
	$self->{"new_unpacked"}{"can_automod"};
}

sub PostLoad
{
	my $self = shift;

	my $new = $self->{'new_unpacked'} = $self->ConvertNewToHash($self->new_data)
		or die;

	my @albums;

	for (my $i=0; ; ++$i)
	{
		my $id = $new->{"AlbumId$i"}
			or last;
		my $name = $new->{"AlbumName$i"};
		defined($name) or last;
		my $prev = $new->{"Prev$i"};
		$prev = $self->previous_data unless defined $prev;

		push @albums, { id => $id, name => $name, prev => $prev };
	}

	$self->{'new_albums'} = \@albums;
}

sub DetermineQuality
{
	my $self = shift;

    # Take the quality level from the first release or set to normal for multiple releases
    my $quality_level = &ModDefs::QUALITY_NORMAL;
    if (scalar(@{$self->{'new_albums'}}) == 1)
    {
        my $rel = MusicBrainz::Server::Release->new($self->dbh);
        $rel->id($self->{new_albums}->[0]->{id});
        if ($rel->LoadFromId())
        {
            $quality_level = $rel->quality;        
        }
    }
    return $quality_level;
}

sub ConvertToText
{
	my $self = shift;
	require MusicBrainz::Server::Release;
	my $al = MusicBrainz::Server::Release->new($self->dbh);

	join ", ",
		map {
            MusicBrainz::Server::Release::attribute_name($_)
		} @_;
}

sub AdjustModPending
{
	my ($self, $adjust) = @_;

	# Prior to the ModerationClasses2 branch, the "mod pending" change would
	# only be applied to the releaseid listed in $self->row_id - which, in the
	# case of a multiple release change, would be none of them (since the row id
	# for them was zero).
	# Now though we apply the modpending change to all affected releases.

	require MusicBrainz::Server::Release;
	my $al = MusicBrainz::Server::Release->new($self->dbh);

	for my $album (@{ $self->{'new_albums'} })
	{
		$al->id($album->{'id'});
		$al->UpdateAttributesModPending($adjust);
	}
}

sub ApprovedAction
{
	&ModDefs::STATUS_APPLIED;
}

sub DeniedAction
{
	my $self = shift;
	require MusicBrainz::Server::Release;
	my $al = MusicBrainz::Server::Release->new($self->dbh);

 	for my $t (@{ $self->{'new_albums'} })
	{
		$al->id($t->{'id'});
		$al->LoadFromId;
		$al->attributes(split /,/, $t->{'prev'});
  		$al->UpdateAttributes;
	}
}

1;
# eof MOD_EDIT_RELEASE_ATTRS.pm
