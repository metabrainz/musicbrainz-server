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

use ModDefs qw( :artistid :modstatus MODBOT_MODERATOR );
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

	my $begindate = &MusicBrainz::Server::Validation::MakeDisplayDateStr(join('-', $opts{'begindate'}->[0], $opts{'begindate'}->[1], $opts{'begindate'}->[2]));
	my $enddate = &MusicBrainz::Server::Validation::MakeDisplayDateStr(join('-', $opts{'enddate'}->[0], $opts{'enddate'}->[1], $opts{'enddate'}->[2]));

	my $link = MusicBrainz::Server::Link->new(
		$self->{dbh},
		scalar($linktype->types),
	);

	$link = $link->Insert($linktype, $entities, $begindate, $enddate);
	unless ($link)
	{
		$self->SuppressInsert;
		return;
	}

	my ($linkphrase, $rlinkphrase);
	my $attr = MusicBrainz::Server::Attribute->new(
		$self->{dbh},
		scalar($linktype->types),
		$link->id
	);

	if ($attr)
	{
		if (!defined $attr->Insert([map { $_->{value} } @$attrs]))
		{
			$self->SuppressInsert;
			return;
		}
		($linkphrase, $rlinkphrase) = $attr->ReplaceAttributes($linktype->link_phrase, $linktype->reverse_link_phrase);
    }

	if (@$entities[0]->{type} eq 'album' || @$entities[0]->{type} eq 'track')
	{
		my $artistid = @$entities[0]->{type} eq 'track' ? @$entities[0]->{obj}->artist->id
                     :                                    @$entities[0]->{obj}->artist;
		# Don't assign the edit to VA if we don't have to
		if ($artistid == VARTIST_ID && @$entities[1]->{type} eq 'artist')
		{
			$self->artist(@$entities[1]->{obj}->id);
		}
		else
		{
			$self->artist($artistid);
		}
	} 
	elsif (@$entities[0]->{type} ne 'label')
	{
	    $self->artist(@$entities[0]->{obj}->id);
	}

	$self->table($link->table);
	$self->column("id");
	$self->row_id($link->id);

	my %new = (
	    linkid          => $link->id,
		linktypeid      => $linktype->id,
		linktypename    => $linktype->name,
		linktypephrase  => $linkphrase,
		rlinktypephrase => $rlinkphrase,
		entity0id       => @$entities[0]->{id},
		entity0type     => @$entities[0]->{type},
		entity0name     => @$entities[0]->{name},
		entity1id       => @$entities[1]->{id},
		entity1type     => @$entities[1]->{type},
		entity1name     => @$entities[1]->{name},
		begindate       => $begindate,
		enddate         => $enddate,
	);
	$new{url} = $url if ($url);

	$self->new_data($self->ConvertHashToNew(\%new));

	# finally some special ASIN URL handling (update album_amazon_asin table data)
	if ($linktype->id == MusicBrainz::Server::CoverArt->asin_link_type_id($self->{dbh}) &&
		@$entities[0]->{type} eq 'album' &&
		@$entities[1]->{type} eq 'url')
	{
		my $al = MusicBrainz::Server::Release->new($self->dbh);
		$al->id(@$entities[0]->{id});
		if ($al->LoadFromId(1))
		{
            MusicBrainz::Server::CoverArt->ParseAmazonURL(@$entities[1]->{name}, $al);
			# TODO implement overwriting, if some special flag on the AR edit page is set
			#      to allow saying "use this as cover image source"
            MusicBrainz::Server::CoverArt->UpdateAmazonData($al, 0);
		}
	}

    # now check to see if we need to tinker with generic cover art
	if ($linktype->id == MusicBrainz::Server::CoverArt->GetCoverArtLinkTypeId($self->{dbh}) &&
		@$entities[0]->{type} eq 'album' &&
		@$entities[1]->{type} eq 'url')
	{
		my $al = MusicBrainz::Server::Release->new($self->dbh);
		$al->id(@$entities[0]->{id});
		if ($al->LoadFromId(1))
		{
            MusicBrainz::Server::CoverArt->ParseCoverArtURL(@$entities[1]->{name}, $al);
            MusicBrainz::Server::CoverArt->UpdateCoverArtData($al, 0);
		}
	}
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

sub DeniedAction
{
  	my $self = shift;
	my $new = $self->{'new_unpacked'};

	my $link = MusicBrainz::Server::Link->new($self->dbh, [$new->{entity0type}, $new->{entity1type}]);
	$link = $link->newFromId($new->{linkid});
	if ($link)
	{
		$link->Delete;

		# remove amazon asin and coverart data as well
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
	}
}

1;
# eof MOD_ADD_LINK.pm
