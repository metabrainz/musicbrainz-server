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

package MusicBrainz::Server::Moderation::MOD_REMOVE_LINK;

use ModDefs qw( :modstatus MODBOT_MODERATOR );
use base 'Moderation';
use MusicBrainz::Server::Link;
use MusicBrainz::Server::CoverArt;

sub Name { "Remove Relationship" }
(__PACKAGE__)->RegisterHandler;

sub PreInsert
{
	my ($self, %opts) = @_;

	my $link = $opts{'link'} or die;
	my $types = $opts{'types'} or die;

	my @ents = $link->Entities();

	if ($types->[0] eq 'album' || $types->[0] eq 'track')
	{
        my $id = $types->[0] eq 'track' ? $ents[0]->artist->id : $ents[0]->artist;
	    $self->artist($id);
	}
	elsif ($types->[0] ne 'label')
	{
	    $self->artist($ents[0]->id);
	}
	$self->table($link->Table);
	$self->column("id");
	$self->row_id($link->id);

	require MusicBrainz::Server::LinkType;
	my $linktype = MusicBrainz::Server::LinkType->newFromPackedTypes($self->{dbh}, $types->[0].'-'.$types->[1]);
    $linktype = $linktype->newFromId($link->GetLinkType());

    my $attr = MusicBrainz::Server::Attribute->new(
        $self->{dbh},
        scalar($linktype->Types)
    );
    $attr = $attr->newFromLinkId($link->id());
    my ($linkphrase, $dummy) = $attr->ReplaceAttributes($linktype->{linkphrase}, "");

	my %new = (
	    linkid=>$link->id,
		linktypeid=>$linktype->{id},
		linktypename=>$linktype->{name},
		linktypephrase=>$linkphrase,
		entity0id=>$ents[0]->id,
		entity0type=>$types->[0],
		entity0name=>$ents[0]->name,
		entity1id=>$ents[1]->id,
		entity1type=>$types->[1],
		entity1name=>$ents[1]->name,
		begindate=>$link->begin_date(),
		enddate=>$link->end_date(),
	);
	$self->new_data($self->ConvertHashToNew(\%new));
}

sub PostLoad
{
	my $self = shift;
	$self->{'new_unpacked'} = $self->ConvertNewToHash($self->new_data)
		or die;
}

sub DetermineQuality
{
	my $self = shift;

    my $id = 0;
    my $type = '';
    my $new = $self->{'new_unpacked'};

    if ($new->{entity0type} eq 'album' || $new->{entity1type} eq 'album')
    {
        my $rel = MusicBrainz::Server::Release->new($self->dbh);
        $rel->id($new->{entity0type} eq 'album' ? $new->{entity0id} : $new->{entity1id});
        if ($rel->LoadFromId())
        {
            return $rel->quality;        
        }
    }
    elsif ($new->{entity0type} eq 'artist' || $new->{entity1type} eq 'artist')
    {
        my $rel = MusicBrainz::Server::Artist->new($self->dbh);
        $rel->id($new->{entity0type} eq 'artist' ? $new->{entity0id} : $new->{entity1id});
        if ($rel->LoadFromId())
        {
            return $rel->quality;        
        }
    }
    return &ModDefs::QUALITY_NORMAL;
}

sub ApprovedAction
{
	my $self = shift;
	my $new = $self->{'new_unpacked'};

	require MusicBrainz::Server::Link;

	my $link = MusicBrainz::Server::Link->new($self->dbh, [$new->{entity0type}, $new->{entity1type}]);
	$link or return STATUS_ERROR;

	unless ($link = $link->newFromId($new->{linkid}))
	{
		$self->InsertNote(MODBOT_MODERATOR, "This relationship has already been removed");
		return STATUS_APPLIED;
	}

	if (not $link->Delete)
	{
		$self->InsertNote(MODBOT_MODERATOR, "This relationship could not be removed");
		return STATUS_ERROR;
	}

	# finally some special ASIN URL handling 
	if ($new->{linktypeid} == MusicBrainz::Server::CoverArt->asin_link_type_id($self->{dbh}) &&
		$new->{entity0type} eq 'album' &&
		$new->{entity1type} eq 'url')
	{
		my $al = MusicBrainz::Server::Release->new($self->dbh);
		$al->id($new->{entity0id});
        MusicBrainz::Server::CoverArt->UpdateAmazonData($al, -1)
			if ($al->LoadFromId(1));
	}
	if ($new->{linktypeid} == MusicBrainz::Server::CoverArt->GetCoverArtLinkTypeId($self->{dbh}) &&
		$new->{entity0type} eq 'album' &&
		$new->{entity1type} eq 'url')
	{
		my $al = MusicBrainz::Server::Release->new($self->dbh);
		$al->id($new->{entity0id});
        MusicBrainz::Server::CoverArt->UpdateCoverArtData($al, -1)
			if ($al->LoadFromId(1));
	}

	return STATUS_APPLIED;
}


1;
# eof MOD_REMOVE_LINK.pm
