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

package MusicBrainz::Server::ModerationNote;

require Exporter;
{ our @ISA = qw( Exporter TableBase ); our @EXPORT_OK = qw( mark_up_text_as_html ) }

use Carp;
use Encode qw( encode decode );

use ModDefs qw( VOTE_ABS );

# GetId / SetId - see TableBase
sub GetModerationId	{ $_[0]{moderation} }
sub SetModerationId	{ $_[0]{moderation} = $_[1] }
sub GetUserId		{ $_[0]{moderator} }
sub SetUserId		{ $_[0]{moderator} = $_[1] }
sub GetText			{ $_[0]{text} }
sub SetText			{ $_[0]{text} = $_[1] }
sub GetNoteTime		{ $_[0]{notetime} }
sub GetUserName		{ $_[0]{user} }

# Like GetText, but marks it up as HTML (e.g. adds hyperlinks)
sub GetTextAsHTML
{
	my $self = shift;
	mark_up_text_as_html($self->GetText);
}

sub mark_up_text_as_html
{
	my $text = shift;
	use MusicBrainz::Server::Validation qw( encode_entities );

	my $is_url = 1;
	my $server = &DBDefs::WEB_SERVER;
	
	my $html = join "", map {

		# shorten url's that are longer 50 characters
		my $encurl = encode_entities($_);
		my $shorturl = $encurl;
		if (length($_) > 50)
		{
			$shorturl = substr($_, 0, 48);
			$shorturl = encode_entities($shorturl);
			$shorturl .= "&#8230;";
		}					
		($is_url = not $is_url)
			? qq[<a href="$encurl" title="$encurl">$shorturl</a>]
            : $encurl;
	} split /
		(
			# Something that looks like the start of a URL
			\b
			(?:https?|ftp)
			:\/\/
			.*?
			
			# Stop at one of these sequences:
			(?=
				\z # end of string
				| \s # any space
				| [,\.!\?](?:\s|\z) # punctuation then space or end
				| [\x29"'>] # any of these characters 
			)
		)
		/six, $text, -1;

	$html =~ s[\b(?:mod(?:eration)? #?|edit[#:\s]+|edit id[#:\s]+|change[#:\s]+)(\d+)\b]
			  [<a href="http://$server/show/edit/?editid=$1">edit #$1</a>]gi;

	# links to wikidocs 
	$html =~ s/doc:(\w[\/\w]*)(``)*/<a href="\/doc\/$1">$1<\/a>/gi;
	$html =~ s/\[(\p{IsUpper}[\/\w]*)\]/<a href="\/doc\/$1">$1<\/a>/g;

	$html =~ s/<\/?p[^>]*>//g;
	$html =~ s/<br[^>]*\/?>//g;
	$html =~ s/&#39;&#39;&#39;(.*?)&#39;&#39;&#39;/<strong>$1<\/strong>$2/g;
	$html =~ s/&#39;&#39;(.*?)&#39;&#39;/<em>$1<\/em>/g;
	$html =~ s/(\015\012|\012\015|\012|\015)/<br\/>/g;

	return $html;
}

sub Insert
{
	my ($self, $modid, $noteuid, $text, %opts) = @_;
   	my $sql = Sql->new($self->{DBH});

	# Make sure we have the most up-to-date status, so we get the correct
	# table (open/closed)
	my $moderation = Moderation->new($self->{DBH});
	$moderation = $moderation->CreateFromId($modid);
	my $openclosed = ($moderation->IsOpen ? "open" : "closed");


	# For moderation and vote, rows only ever get added to _open, then moved
	# to _closed - so the sequence only applies to the _open "id" column.
	# Here however rows can get added to either, and _open rows do get moved
	# to _closed; hence they must use the same sequence.  So here we
	# explicitly name the sequence as the ID value.  Redundant for _open, but
	# required for _closed.
    $sql->AutoCommit if (!$sql->IsInTransaction);
	$sql->Do(
		"INSERT INTO moderation_note_$openclosed
			(id, moderation, moderator, text)
			VALUES (NEXTVAL('moderation_note_open_id_seq'), ?, ?, ?)",
		$modid,
		$noteuid,
		$text,
	);

	# Should we e-mail the added note to the original moderator?
	return if $opts{'nosend'};

	# People we might send this note to.
	my %done;
	$done{$noteuid} = 1;

	my $ui = UserStuff->new($self->{DBH});
	my $mod_user = $ui->newFromId($moderation->GetModerator)
		or die;
	my $note_user = $ui->newFromId($noteuid)
		or die;

	{
		# Not if it's them that just added the note.
		next if $noteuid == $moderation->GetModerator;

		# Also not unless they've got a confirmed e-mail address
		next unless $mod_user->GetEmail and $mod_user->GetEmailConfirmDate;

		$note_user->SendModNoteToUser(
			mod => $moderation,
			mod_user => $mod_user,
			note_text => $text,
			revealaddress=> $opts{'revealaddress'},
		);

		$done{$moderation->GetModerator} = 1;
	}

	# Who else wants to receive this note via email?
	my @notes = $self->newFromModerationId($moderation->GetId);

	for my $note (@notes)
	{
		my $uid = $note->GetUserId;
		next if $done{$uid};
		$done{$uid} = 1;

		# Has this user got the "mail_notes_if_i_noted" preference enabled?
		my $other_user = $ui->newFromId($uid)
			or die;

		next unless $other_user->GetEmail and $other_user->GetEmailConfirmDate;

		require UserPreference;
		UserPreference::get_for_user("mail_notes_if_i_noted", $other_user)
			or next;

		$note_user->SendModNoteToFellowNoter(
			mod			=> $moderation,
			mod_user	=> $mod_user,
			other_user	=> $other_user,
			note_text	=> $text,
			revealaddress=> $opts{'revealaddress'},
		);
	}

	# Do any voters want to receive this note?
	require MusicBrainz::Server::Vote;
	my $v = MusicBrainz::Server::Vote->new($self->{DBH});
	my @votes = $v->newFromModerationId($moderation->GetId);

	for my $vote (@votes)
	{
		# Only if the user's most recent vote was not "abstain"
		next if $vote->GetSuperseded or $vote->GetVote == VOTE_ABS;

		my $uid = $vote->GetUserId;
		next if $done{$uid};
		$done{$uid} = 1;

		# Has this user got the "mail_notes_if_i_voted" preference enabled?
		my $other_user = $ui->newFromId($uid)
			or die;

		next unless $other_user->GetEmail and $other_user->GetEmailConfirmDate;

		require UserPreference;
		UserPreference::get_for_user("mail_notes_if_i_voted", $other_user)
			or next;

		$note_user->SendModNoteToFellowNoter(
			mod			=> $moderation,
			mod_user	=> $mod_user,
			other_user	=> $other_user,
			note_text	=> $text,
			revealaddress=> $opts{'revealaddress'},
		);
	}
}

*newFromModerationId = \&newFromModerationIds;
sub newFromModerationIds
{
	my ($self, @ids) = @_;
	@ids or return;
   	my $sql = Sql->new($self->{DBH});

	# NOTE: must allow at least however many we show on moderatepage
	# (see limit of mods_per_page preference, currently 25).
	splice(@ids, 0, 50) if @ids > 50;
	
	my $list = join ",", @ids;
	my $data = $sql->SelectListOfHashes(
		"SELECT	n.id, n.moderation, n.moderator, n.text, n.notetime, u.name AS user
		FROM	moderation_note_all n, moderator u
		WHERE	n.moderator = u.id
		AND		n.moderation IN ($list)
		ORDER BY n.id",
	);

	map { $self->_new_from_row($_) } @$data;
}

1;
# eof ModerationNote.pm
