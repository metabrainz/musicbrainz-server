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

package MusicBrainz::Server::Moderation::MOD_EDIT_ALBUMATTRS;

use ModDefs;
use base 'Moderation';

sub Name { "Edit Album Attributes" }
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
		die "Can't edit attributes of 'non-album tracks' album"
			if $al->IsNonAlbumTracks;
		my $prev = join ",", $al->GetAttributes;
		next if $prev eq $new{'Attributes'};

		$new{"AlbumId$seq"} = $al->GetId;
		$new{"AlbumName$seq"} = $al->GetName;
		$new{"Prev$seq"} = $prev;

		my ($t, $s) = $al->GetReleaseTypeAndStatus;
		$fCanAutoMod = 0
			if defined($t) and $t != $type;
		$fCanAutoMod = 0
			if defined($s) and $s != $status;

		++$artists{$al->GetArtist};
		++$seq;
	}

	$new{can_automod} = $fCanAutoMod;

	unless ($seq)
	{
		$self->SuppressInsert;
		return;
	}

	$self->SetArtist(
		keys(%artists) > 1
			? &ModDefs::VARTIST_ID
			: $albums->[0]->GetArtist
	);
	$self->SetTable("album");
	$self->SetColumn("id");
	$self->SetRowId($albums->[0]->GetId);
	$self->SetNew($self->ConvertHashToNew(\%new));

	# This mod is immediately applied, and undone later if rejected.
 	for my $al (@$albums)
	{
	  	$al->SetAttributes(@$attrs);
  		$al->UpdateAttributes;
	}
}

sub IsAutoMod
{
	my ($self, $user_is_automod) = @_;
	$self->{"new_unpacked"}{"can_automod"} or $user_is_automod;
}

sub PostLoad
{
	my $self = shift;

	my $new = $self->{'new_unpacked'} = $self->ConvertNewToHash($self->GetNew)
		or die;

	my @albums;

	for (my $i=0; ; ++$i)
	{
		my $id = $new->{"AlbumId$i"}
			or last;
		my $name = $new->{"AlbumName$i"};
		defined($name) or last;
		my $prev = $new->{"Prev$i"};
		$prev = $self->GetPrev unless defined $prev;

		push @albums, { id => $id, name => $name, prev => $prev };
	}

	$self->{'new_albums'} = \@albums;
}

sub ConvertToText
{
	my $self = shift;
	require Album;
	my $al = Album->new($self->{DBH});

	join ", ",
		map {
			$al->GetAttributeName($_)
		} @_;
}

sub AdjustModPending
{
	my ($self, $adjust) = @_;

	# Prior to the ModerationClasses2 branch, the "mod pending" change would
	# only be applied to the album listed in $self->GetRowId - which, in the
	# case of a multiple album change, would be none of them (since the row id
	# for them was zero).
	# Now though we apply the modpending change to all affected albums.

	require Album;
	my $al = Album->new($self->{DBH});

	for my $album (@{ $self->{'new_albums'} })
	{
		$al->SetId($album->{'id'});
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
	require Album;
	my $al = Album->new($self->{DBH});

 	for my $t (@{ $self->{'new_albums'} })
	{
		$al->SetId($t->{'id'});
		$al->LoadFromId;
		$al->SetAttributes(split /,/, $t->{'prev'});
  		$al->UpdateAttributes;
	}
}

1;
# eof MOD_EDIT_ALBUMATTRS.pm
