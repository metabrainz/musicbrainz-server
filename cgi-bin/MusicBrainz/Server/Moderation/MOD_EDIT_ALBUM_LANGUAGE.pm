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

package MusicBrainz::Server::Moderation::MOD_EDIT_ALBUM_LANGUAGE;

use ModDefs qw( :modstatus MODBOT_MODERATOR );
use base 'Moderation';

sub Name { "Edit Album Language" }
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
		die "Can't edit the language of 'non-album tracks' albums"
			if $al->IsNonAlbumTracks;

		my $curr_lang = $al->GetLanguageId || 0;
		my $curr_script = $al->GetScriptId || 0;
		my $prev = "$curr_lang,$curr_script";
		next if $prev eq $new{Language};

		$new{"AlbumId$seq"} = $al->GetId;
		$new{"AlbumName$seq"} = $al->GetName;
		$new{"Prev$seq"} = $prev;

		$fCanAutoMod = 0 if $curr_lang and $languageid != $curr_lang;
		$fCanAutoMod = 0 if $curr_script and $scriptid != $curr_script;

		++$artists{$al->GetArtist};
		++$seq;
	}

	$new{can_automod} = $fCanAutoMod;

	# Nothing to change?
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
	$self->SetNew($self->ConvertHashToNew(\%new));
	$self->SetLanguageId($languageid) if $languageid;
}

sub IsAutoMod
{
	my $self = shift;

	my $new = $self->ConvertNewToHash($self->GetNew);

	return $new->{can_automod};
}

# Used for display purposes by /comp/moderation/MOD_EDIT_ALBUMATTRS
sub PostLoad
{
	my $self = shift;
	my $new = $self->ConvertNewToHash($self->GetNew);
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

sub AdjustModPending
{
	my ($self, $adjust) = @_;
	my $albums = $self->{_new_albums};

	require Album;
	my $al = Album->new($self->{DBH});

	foreach my $album ( @$albums )
	{
		$al->SetId($album->{id});
		$al->UpdateLanguageModPending($adjust);
	}
}

sub CheckPrerequisites
{
	my $self = shift;
	my $new = $self->ConvertNewToHash($self->GetNew)
		or die;

	my @albums;
	my $status = undef;

	require Album;
	for (my $i = 0; defined $new->{"AlbumId$i"}; $i++)
	{
		my $id = $new->{"AlbumId$i"};
		my $al = Album->new($self->{DBH});
		$al->SetId($id);

		unless ( $al->LoadFromId )
		{
			$self->InsertNote(MODBOT_MODERATOR,
				"The album '" . $new->{"AlbumName$i"} . "' has been deleted. ");
			$status = STATUS_FAILEDDEP unless $status == STATUS_FAILEDPREREQ;
			next;
		}

		my $prev = $new->{"Prev$i"};
		my $curr = ($al->GetLanguageId||0) . "," . ($al->GetScriptId||0);

		# Make sure the language hasn't changed while this mod was open
		if ($curr ne $prev)
		{
			$self->InsertNote(MODBOT_MODERATOR,
				"The language or script of album '" . $new->{"AlbumName$i"}
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
		$al->SetLanguageId($languageid);
		$al->SetScriptId($scriptid);
		$al->UpdateLanguageAndScript;
	}

	STATUS_APPLIED;
}

1;
# eof MOD_EDIT_ALBUM_LANGUAGE.pm
