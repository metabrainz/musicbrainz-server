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

package MusicBrainz::Server::ModerationNote;

use base qw( TableBase );
use Carp;

# GetId / SetId - see TableBase
sub GetModerationId	{ $_[0]{moderation} }
sub SetModerationId	{ $_[0]{moderation} = $_[1] }
sub GetUserId		{ $_[0]{moderator} }
sub SetUserId		{ $_[0]{moderator} = $_[1] }
sub GetText			{ $_[0]{text} }
sub SetText			{ $_[0]{text} = $_[1] }
sub GetUserName		{ $_[0]{user} }

# Like GetText, but marks it up as HTML (e.g. adds hyperlinks)
sub GetTextAsHTML
{
	my $self = shift;
	use MusicBrainz qw( encode_entities );
	my $html = encode_entities($self->GetText);

	my @site_names = (qw(
		musicbrainz.org
		www.musicbrainz.org
	), &DBDefs::WEB_SERVER);
	
	my $site_names = "(?:" . join("|", map { quotemeta($_) } @site_names) . ")";
	$html =~ s[
		\b
		http://$site_names/
		(?:
			showalbum\.html\?albumid=\d+
			| showartist\.html\?artistid=\d+
			| showaliases\.html\?artistid=\d+
			| showtrack\.html\?trackid=\d+
			| showmod\.html\?modid=\d+
		)
		\b
	][<a href="$&">$&</a>]ix;

	$html;
}

sub Insert
{
	my ($self, $moderation, $noteuid, $text, %opts) = @_;
   	my $sql = Sql->new($self->{DBH});

	my $modid = $moderation->GetId;

	# Make sure we have the most up-to-date status, so we get the correct
	# table (open/closed)
	$moderation->Refresh;
	my $openclosed = ($moderation->IsOpen ? "open" : "closed");

	# For moderation and vote, rows only ever get added to _open, then moved
	# to _closed - so the sequence only applies to the _open "id" column.
	# Here however rows can get added to either, and _open rows do get moved
	# to _closed; hence they must use the same sequence.  So here we
	# explicitly name the sequence as the ID value.  Redundant for _open, but
	# required for _closed.
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
			mod			=> $moderation,
			mod_user	=> $mod_user,
			note_text	=> $text,
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
		"SELECT	n.id, n.moderation, n.moderator, n.text, u.name AS user
		FROM	moderation_note_all n, moderator u
		WHERE	n.moderator = u.id
		AND		n.moderation IN ($list)
		ORDER BY n.id",
	);

	map { $self->_new_from_row($_) } @$data;
}

1;
# eof ModerationNote.pm
