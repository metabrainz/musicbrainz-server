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

use base qw( TableBase );
use Carp;

# GetId / SetId - see TableBase
sub GetModerationId	{ $_[0]{modid} }
sub SetModerationId	{ $_[0]{modid} = $_[1] }
sub GetUserId		{ $_[0]{uid} }
sub SetUserId		{ $_[0]{uid} = $_[1] }
sub GetText			{ $_[0]{text} }
sub SetText			{ $_[0]{text} = $_[1] }
sub GetUserName		{ $_[0]{user} }

# Like GetText, but marks it up as HTML (e.g. adds hyperlinks)
sub GetTextAsHTML
{
	my $self = shift;
	use HTML::Mason::Tools qw( html_escape );
	my $html = html_escape($self->GetText);

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
	@_ == 4 or croak;
	my ($self, $moderation, $noteuid, $text) = @_;
   	my $sql = Sql->new($self->{DBH});

	my $modid = $moderation->GetId;

	$sql->Do(
		"INSERT INTO moderationnote (modid, uid, text) VALUES (?, ?, ?)",
		$modid,
		$noteuid,
		$text,
	);

	# Should we e-mail the added note to the original moderator?
	# Not if it's them that just added the note.
	return if $noteuid == $moderation->GetModerator;

	my $ui = UserStuff->new($self->{DBH});
	my $mod_user = $ui->newFromId($moderation->GetModerator)
		or die;
	# Also not unless they've got a confirmed e-mail address
	return unless $mod_user->GetEmail and $mod_user->GetEmailConfirmDate;

	my $note_user = $ui->newFromId($noteuid)
		or die;

	$note_user->SendModNoteToUser($moderation, $text, $mod_user);
}

*newFromModerationId = \&newFromModerationIds;
sub newFromModerationIds
{
	my ($self, $minmodid, $maxmodid) = @_;
   	my $sql = Sql->new($self->{DBH});

	$maxmodid = $minmodid
		unless defined $maxmodid;
	($minmodid, $maxmodid) = ($maxmodid, $minmodid)
		if $maxmodid < $minmodid;

	my $data = $sql->SelectListOfHashes(
		"SELECT	n.id, n.modid, n.uid, n.text, u.name AS user
		FROM	moderationnote n, moderator u
		WHERE	n.uid = u.id
		AND		n.modid BETWEEN ? AND ?
		ORDER BY n.id",
		$minmodid, $maxmodid,
	);

	map { $self->_new_from_row($_) } @$data;
}

1;
# eof ModerationNote.pm
