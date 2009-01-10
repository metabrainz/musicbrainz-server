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

package MusicBrainz::Server::Moderation::MOD_EDIT_RELEASE_LANGUAGE;

use ModDefs qw( :modstatus MODBOT_MODERATOR );
use base 'Moderation';

sub Name { "Edit Release Language" }
(__PACKAGE__)->RegisterHandler;

sub PreInsert
{
	my ($self, %opts) = @_;

	my $albums = $opts{'albums'} or die;
	my $languageid = $opts{'language'} || 0;
	my $scriptid = $opts{'script'} || 0;

	my %artists;
	my %new = (
		Language	=> "$languageid,$scriptid",
	);

	my $fCanAutoMod = 1;

	my $seq = 0;
	foreach my $al ( @$albums )
	{
		die "Can't edit the language of 'non-album tracks' releases"
			if $al->IsNonAlbumTracks;

		my $curr_lang = $al->language_id || 0;
		my $curr_script = $al->script_id || 0;
		my $prev = "$curr_lang,$curr_script";
		next if $prev eq $new{Language};

		$new{"AlbumId$seq"} = $al->id;
		$new{"AlbumName$seq"} = $al->name;
		$new{"Prev$seq"} = $prev;

		$fCanAutoMod = 0 if $curr_lang and $languageid != $curr_lang;
		$fCanAutoMod = 0 if $curr_script and $scriptid != $curr_script;

		++$artists{$al->artist};
		++$seq;
	}

	$new{can_automod} = $fCanAutoMod;

	# Nothing to change?
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
	$self->new_data($self->ConvertHashToNew(\%new));

        if ($languageid)
        {
	    my $language = new MusicBrainz::Server::Language($self->{dbh});
            $language->id($languageid);
	    $self->language($language);
	}
}

sub IsAutoEdit
{
	my $self = shift;

	my $new = $self->ConvertNewToHash($self->new_data);

	return $new->{can_automod};
}

# Used for display purposes by /comp/moderation/MOD_EDIT_RELEASE_ATTRS
sub PostLoad
{
	my $self = shift;
	my $new = $self->ConvertNewToHash($self->new_data);
	my @albums;

	for (my $i = 0; defined $new->{"AlbumId$i"}; $i++)
	{
		my $id = $new->{"AlbumId$i"};
		my $name = $new->{"AlbumName$i"};
		my ($prev_lang, $prev_script) = split ',', $new->{"Prev$i"};

		push @albums, { id => $id, name => $name,
						prev_lang => $prev_lang, prev_script => $prev_script };
	}

	my ($lang, $script) = split m/,/, $new->{Language};

	$self->{_new_albums} = \@albums;
	$self->{_languageid} = $lang;
	$self->{_scriptid} = $script;
}

sub DetermineQuality
{
	my $self = shift;

    # Take the quality level from the first release or set to normal for multiple releases
    if (scalar(@{$self->{'_new_albums'}}) == 1)
    {
        my $rel = MusicBrainz::Server::Release->new($self->dbh);
        $rel->id($self->{_new_albums}->[0]->{id});
        if ($rel->LoadFromId())
        {
            return $rel->quality;        
        }
    }
    return &ModDefs::QUALITY_NORMAL;
}

sub AdjustModPending
{
	my ($self, $adjust) = @_;
	my $albums = $self->{_new_albums};

	require MusicBrainz::Server::Release;
	my $al = MusicBrainz::Server::Release->new($self->dbh);

	foreach my $album ( @$albums )
	{
		$al->id($album->{id});
		$al->UpdateLanguageModPending($adjust);
	}
}

sub CheckPrerequisites
{
	my $self = shift;
	my $new = $self->ConvertNewToHash($self->new_data)
		or die;

	my @albums;
	my $status = undef;

	require MusicBrainz::Server::Release;
	for (my $i = 0; defined $new->{"AlbumId$i"}; $i++)
	{
		my $id = $new->{"AlbumId$i"};
		my $al = MusicBrainz::Server::Release->new($self->dbh);
		$al->id($id);

		unless ( $al->LoadFromId )
		{
			$self->InsertNote(MODBOT_MODERATOR,
				"The release '" . $new->{"AlbumName$i"} . "' has been deleted. ");
			$status = STATUS_FAILEDDEP unless $status == STATUS_FAILEDPREREQ;
			next;
		}

		my $prev = $new->{"Prev$i"};
		my $curr = ($al->language_id||0) . "," . ($al->script_id||0);

		# Make sure the language hasn't changed while this mod was open
		if ($curr ne $prev)
		{
			$self->InsertNote(MODBOT_MODERATOR,
				"The language or script of release '" . $new->{"AlbumName$i"}
			  . "' has already been changed. ");
			$status = STATUS_FAILEDPREREQ;
			next;
		}

		push @albums, $al;
	}

	# None of the albums may be changed. Thus we return STATUS_FAILEDDEP
	# or STATUS_FAILEDPREREQ.
	return $status if @albums == 0;

	# Save all albums that we are going to change in ApprovedAction().
	$self->{_albums} = \@albums;

	return undef; # undef means no prerequisite problem
}

sub ApprovedAction
{
	my $self = shift;

	my $status = $self->CheckPrerequisites;
	return $status if $status;

	my $languageid = $self->{_languageid};
	my $scriptid = $self->{_scriptid};
	my $albums = $self->{_albums};

	foreach my $al ( @$albums )
	{
		$al->language_id($languageid);
		$al->script_id($scriptid);
		$al->UpdateLanguageAndScript;
	}

	STATUS_APPLIED;
}

1;
# eof MOD_EDIT_RELEASE_LANGUAGE.pm
