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

package MusicBrainz::Server::Moderation::MOD_ADD_LINK;

use ModDefs qw( :modstatus MODBOT_MODERATOR );
use base 'Moderation';
use MusicBrainz::Server::Link;
use MusicBrainz::Server::Attribute;

sub Name { "Add Relationship" }
(__PACKAGE__)->RegisterHandler;

sub PreInsert
{
	my ($self, %opts) = @_;

	my $entities = $opts{'entities'} or die;	# a list of Album/Track/Artist objects, etc
	my $linktype = $opts{'linktype'} or die;	# a LinkType object
	my $url = $opts{'url'} or undef;
	my $attrs = $opts{'attributes'};

	my $begindate = &MusicBrainz::MakeDisplayDateStr(join('-', $opts{'begindate'}->[0], $opts{'begindate'}->[1], $opts{'begindate'}->[2]));
	my $enddate = &MusicBrainz::MakeDisplayDateStr(join('-', $opts{'enddate'}->[0], $opts{'enddate'}->[1], $opts{'enddate'}->[2]));

	my $link = MusicBrainz::Server::Link->new(
		$self->{DBH},
		scalar($linktype->Types),
	);

	$link = $link->Insert($linktype, $entities, $begindate, $enddate);
	unless ($link)
	{
		$self->SuppressInsert;
		return;
	}

	my ($linkphrase, $rlinkphrase);
	my $attr = MusicBrainz::Server::Attribute->new(
		$self->{DBH},
		scalar($linktype->Types),
		$link->GetId
	);
	if ($attr)
	{
		if (!defined $attr->Insert([map { $_->{value} } @$attrs]))
		{
			$self->SuppressInsert;
			return;
		}
		($linkphrase, $rlinkphrase) = $attr->ReplaceAttributes($linktype->{linkphrase}, $linktype->{rlinkphrase});
    }

	if (@$entities[0]->{type} eq 'album' || @$entities[0]->{type} eq 'track')
	{
	    $self->SetArtist(@$entities[0]->{obj}->GetArtist);
	} 
	else
	{
	    $self->SetArtist(@$entities[0]->{obj}->GetId);
	}

	$self->SetTable($link->Table);
	$self->SetColumn("id");
	$self->SetRowId($link->GetId);

	my %new = (
	    linkid=>$link->GetId,
		linktypeid=>$linktype->{id},
		linktypename=>$linktype->{name},
		linktypephrase=>$linkphrase,
		rlinktypephrase=>$rlinkphrase,
		entity0id=>@$entities[0]->{id},
		entity0type=>@$entities[0]->{type},
		entity0name=>@$entities[0]->{name},
		entity1id=>@$entities[1]->{id},
		entity1type=>@$entities[1]->{type},
		entity1name=>@$entities[1]->{name},
		begindate=>$begindate,
		enddate=>$enddate,
	);
	$new{url} = $url if ($url);

	$self->SetNew($self->ConvertHashToNew(\%new));
}

sub PostLoad
{
	my $self = shift;
	$self->{'new_unpacked'} = $self->ConvertNewToHash($self->GetNew)
		or die;
}

sub DeniedAction
{
  	my $self = shift;
	my $new = $self->{'new_unpacked'};

	my $link = MusicBrainz::Server::Link->new($self->{DBH}, [$new->{entity0type}, $new->{entity1type}]);
	$link = $link->newFromId($new->{linkid});
	if ($link)
	{
		$link->Delete;
	}
}

1;
# eof MOD_ADD_LINK.pm
