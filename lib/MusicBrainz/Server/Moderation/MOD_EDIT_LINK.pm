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

package MusicBrainz::Server::Moderation::MOD_EDIT_LINK;

use ModDefs qw( :artistid :modstatus MODBOT_MODERATOR );
use base 'Moderation';
use MusicBrainz::Server::Link;

sub Name { "Edit Relationship" }
(__PACKAGE__)->RegisterHandler;

sub PreInsert
{
	my ($self, %opts) = @_;

	my $entities = $opts{'newentities'} or die;		# a list of Album/Track/Artist objects, etc
	my $oldentities = $opts{'oldentities'} or die;	# a list of Album/Track/Artist objects, etc
	my $link = $opts{'node'} or die;              	# a Link object
	my $newlinktype = $opts{'newlinktype'} or die;	# new LinkType 
	my $oldlinktype = $opts{'oldlinktype'} or die;	# old LinkType 
	my $newattrs = $opts{'newattributes'};
	my $oldattrs = $opts{'oldattributes'};

	my $begindate = &MusicBrainz::Server::Validation::MakeDisplayDateStr(join('-', $opts{'begindate'}->[0], $opts{'begindate'}->[1], $opts{'begindate'}->[2]));
	my $enddate = &MusicBrainz::Server::Validation::MakeDisplayDateStr(join('-', $opts{'enddate'}->[0], $opts{'enddate'}->[1], $opts{'enddate'}->[2]));

	my $oldlinkphrase = $oldlinktype->{linkphrase};
	my $newlinkphrase = $newlinktype->{linkphrase};

    my $dummy;
    my $attr = MusicBrainz::Server::Attribute->new(
        $self->{dbh},
        scalar($newlinktype->Types)
    );
    $attr = $attr->newFromLinkId($link->id());
    ($oldlinkphrase, $dummy) = $attr->ReplaceAttributes($oldlinkphrase, '');
    $attr->attributes([map { $_->{value} } @$newattrs]);
    ($newlinkphrase, $dummy) = $attr->ReplaceAttributes($newlinkphrase, '');

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

    $self->table($link->Table);
    $self->column("id");
    $self->row_id($link->id);

    my %new = (
        linkid=>$link->id,
        oldlinktypeid=>$oldlinktype->{id},
        newlinktypeid=>$newlinktype->{id},
        oldlinktypephrase=>$oldlinkphrase,
        newlinktypephrase=>$newlinkphrase,
        oldentity0id=>@$oldentities[0]->{id},
        oldentity0type=>@$oldentities[0]->{type},
        oldentity0name=>@$oldentities[0]->{name},
        oldentity1id=>@$oldentities[1]->{id},
        oldentity1type=>@$oldentities[1]->{type},
        oldentity1name=>@$oldentities[1]->{name},
        newentity0id=>@$entities[0]->{id},
        newentity0type=>@$entities[0]->{type},
        newentity0name=>@$entities[0]->{name},
        newentity1id=>@$entities[1]->{id},
        newentity1type=>@$entities[1]->{type},
        newentity1name=>@$entities[1]->{name},
        newbegindate=>$begindate,
        newenddate=>$enddate,
		oldbegindate=>$link->begin_date(),
		oldenddate=>$link->end_date(),
		newattrs=>join(" ", map { $_->{value} } @$newattrs)
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
    if ($new->{newentity0type} eq 'album' || $new->{newentity1type} eq 'album')
    {
        my $rel = MusicBrainz::Server::Release->new($self->dbh);
        $rel->id($new->{newentity0type} eq 'album' ? $new->{newentity0id} : $new->{newentity1id});
        if ($rel->LoadFromId())
        {
            return $rel->quality;        
        }
    }
    elsif ($new->{newentity0type} eq 'artist' || $new->{newentity1type} eq 'artist')
    {
        my $rel = MusicBrainz::Server::Artist->new($self->dbh);
        $rel->id($new->{newentity0type} eq 'artist' ? $new->{newentity0id} : $new->{newentity1id});
        if ($rel->LoadFromId())
        {
            return $rel->quality;        
        }
    }
    return &ModDefs::QUALITY_NORMAL;
}

sub CheckPrerequisites
{
	my $self = shift;
	my $new = $self->{'new_unpacked'};

	my @types = @$new{qw( newentity0type newentity1type )};

	# Does the link being edited still exist?
	my $link;
	{
		require MusicBrainz::Server::Link;
		my $l = MusicBrainz::Server::Link->new($self->dbh, \@types);
		$l = $l->newFromId($new->{"linkid"});
		$link = $l, last if $l;

		$self->InsertNote(MODBOT_MODERATOR, "This link has been deleted.");
		return STATUS_FAILEDPREREQ;
	}

	# Has it already been modified?
	my $n = $link->GetNumberOfLinks;
	my $old_ids = join " ", map { $new->{"oldentity${_}id"} } 0..$n-1;
	my $new_ids = join " ", $link->Links;

	if ($link->GetLinkType != $new->{oldlinktypeid}
		or $link->begin_date ne $new->{oldbegindate}
		or $link->end_date ne $new->{oldenddate}
		or $old_ids ne $new_ids
	) {
		$self->InsertNote(MODBOT_MODERATOR, "This link has already been modified.");
		return STATUS_FAILEDDEP;
	}

	# Do all target entities exist?
	for my $i (0,1)
	{
		# If the entity is unchanged, it must still exist (because of the foreign key)
		my $oldid = $new->{"oldentity".$i."id"};
		my $newid = $new->{"newentity".$i."id"};
		last if $oldid == $newid;

		my $type = $types[$i];
		require MusicBrainz::Server::LinkEntity;
		my $ent = MusicBrainz::Server::LinkEntity->newFromTypeAndId(
			$self->{dbh}, $type, $newid,
		);
		last if $ent;

		$self->InsertNote(MODBOT_MODERATOR, "This $type has been deleted.");
		return STATUS_FAILEDPREREQ;
	}

	# Does the target link type exist?
	{
		require MusicBrainz::Server::LinkType;
		my $lt = MusicBrainz::Server::LinkType->new($self->dbh, \@types);
		$lt = $lt->newFromId($new->{"newlinktypeid"});
		last if $lt;

		$self->InsertNote(MODBOT_MODERATOR, "This link type has been deleted.");
		return STATUS_FAILEDPREREQ;
	}

	return undef; # undef means no error
}

sub ApprovedAction
{
  	my $self = shift;
	my $new = $self->{'new_unpacked'};
	my $asintypeid = MusicBrainz::Server::CoverArt->asin_link_type_id($self->{dbh});

	my $link = MusicBrainz::Server::Link->new($self->dbh, [$new->{oldentity0type}, $new->{oldentity1type}]);
	$link = $link->newFromId($new->{linkid});
	if ($link)
	{
		my $attr = MusicBrainz::Server::Attribute->new(
			$self->{dbh},
			[$new->{oldentity0type}, $new->{oldentity1type}],
			$link->id
		);
		if ($attr)
		{
			$attr = undef if (!$attr->Update([split(' ',$new->{newattrs})]));
    	}
		if (!$attr)
		{
			$self->InsertNote(MODBOT_MODERATOR, "The attributes for this link could not be updated.");
			return STATUS_ERROR;
        }

		$link->SetLinks([$new->{newentity0id}, $new->{newentity1id}]);
		$link->SetLinkType($new->{newlinktypeid});
		$link->begin_date($new->{newbegindate});
		$link->end_date($new->{newenddate});
		if (!$link->Update)
		{
			$self->InsertNote(MODBOT_MODERATOR, "This link could not be updated.");
			return STATUS_ERROR;
		}
	}

	# finally some special ASIN URL handling (update album_amazon_asin table data)
	if ($new->{oldlinktypeid} == $asintypeid &&
		$new->{oldentity0type} eq 'album' &&
		$new->{oldentity1type} eq 'url')
	{
		# link type changed, remove asin + coverart from album meta
		# currently this is the only way of editing a link, other cases (entity changes, etc.)
		# must be checked as well when implemented
		if ($new->{newlinktypeid} != $asintypeid)
		{
			my $al = MusicBrainz::Server::Release->new($self->dbh);
			$al->id($new->{oldentity0id});

            MusicBrainz::Server::CoverArt->UpdateAmazonData($al, -1)
				if ($al->LoadFromId(1));
		}
	} 
	elsif ($new->{newlinktypeid} == $asintypeid &&
			 $new->{newentity0type} eq 'album' &&
			 $new->{newentity1type} eq 'url')
	{
		# reverse case, link type changed _to_ Amazon AR
		my $al = MusicBrainz::Server::Release->new($self->dbh);
		$al->id($new->{newentity0id});
        MusicBrainz::Server::CoverArt->ParseAmazonURL($new->{newentity1name}, $al);
		
		# insert the asin data or ignore if already present
        MusicBrainz::Server::CoverArt->UpdateAmazonData($al, 0);
	}

    # TODO:
    # Add cover art support here
	
	return STATUS_APPLIED;
}

1;
# eof MOD_EDIT_LINK.pm
