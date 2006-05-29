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

package MusicBrainz::Server::Moderation::MOD_REMOVE_LINK;

use ModDefs qw( :modstatus MODBOT_MODERATOR );
use base 'Moderation';
use MusicBrainz::Server::Link;

sub Name { "Remove Relationship" }
(__PACKAGE__)->RegisterHandler;

sub PreInsert
{
	my ($self, %opts) = @_;

	my $link = $opts{'link'} or die;
	my $types = $opts{'types'} or die;

	my @ents = $link->Entities();

	$self->SetArtist($types->[0] eq 'artist' ? $ents[0]->GetId : $ents[0]->GetArtist());
	$self->SetTable($link->Table);
	$self->SetColumn("id");
	$self->SetRowId($link->GetId);

	require MusicBrainz::Server::LinkType;
	my $linktype = MusicBrainz::Server::LinkType->newFromPackedTypes($self->{DBH}, $types->[0].'-'.$types->[1]);
    $linktype = $linktype->newFromId($link->GetLinkType());

    my $attr = MusicBrainz::Server::Attribute->new(
        $self->{DBH},
        scalar($linktype->Types)
    );
    $attr = $attr->newFromLinkId($link->GetId());
    my ($linkphrase, $dummy) = $attr->ReplaceAttributes($linktype->{linkphrase}, "");

	my %new = (
	    linkid=>$link->GetId,
		linktypeid=>$linktype->{id},
		linktypename=>$linktype->{name},
		linktypephrase=>$linkphrase,
		entity0id=>$ents[0]->GetId,
		entity0type=>$types->[0],
		entity0name=>$ents[0]->GetName,
		entity1id=>$ents[1]->GetId,
		entity1type=>$types->[1],
		entity1name=>$ents[1]->GetName,
		begindate=>$link->GetBeginDate(),
		enddate=>$link->GetEndDate(),
	);
	$self->SetNew($self->ConvertHashToNew(\%new));
}

sub ApprovedAction
{
	my $self = shift;
	my $new = $self->{'new_unpacked'};

	require MusicBrainz::Server::Link;

	my $link = MusicBrainz::Server::Link->new($self->{DBH}, [$new->{entity0type}, $new->{entity1type}]);
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
	if ($new->{linktypeid} == Album->GetAsinLinkTypeId($self->{DBH}) &&
		$new->{entity0type} eq 'album' &&
		$new->{entity1type} eq 'url')
	{
		my $al = Album->new($self->{DBH});
		$al->SetId($new->{entity0id});
		$al->UpdateAmazonData(-1)
			if ($al->LoadFromId(1));
	}

	return STATUS_APPLIED;
}

sub PostLoad
{
	my $self = shift;
	$self->{'new_unpacked'} = $self->ConvertNewToHash($self->GetNew)
		or die;
}

1;
# eof MOD_REMOVE_LINK.pm
