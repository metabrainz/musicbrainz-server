#!/home/httpd/musicbrainz/mb_server/cgi-bin/perl -w
# vi: set ts=4 sw=4 :
#____________________________________________________________________________
#
#   MusicBrainz -- the open internet music database
#
#   Copyright (C) 2004 Robert Kaye
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

package MusicBrainz::Server::Moderation::MOD_ADD_ALBUM_ANNOTATION;

use ModDefs;
use MusicBrainz::Server::Annotation ':type';
use base 'Moderation';

sub Name { "Add Album Annotation" }
(__PACKAGE__)->RegisterHandler;

sub PreInsert
{
	my ($self, %opts) = @_;

	my $albumid = $opts{'albumid'} or die;
	my $artistid = $opts{'artistid'} or die;
	my $text = $opts{'text'} || '';
	my $changelog = $opts{'changelog'} || '';

	my %new = (
		Text => $text,
		ChangeLog => $changelog,
	);

	$self->SetArtist($artistid);
	$self->SetNew($self->ConvertHashToNew(\%new));
	$self->SetTable('album');
	$self->SetColumn('annotation.text');
	$self->SetRowId($albumid);
}

sub ApprovedAction
{
	my $self = shift;

	my $new = $self->ConvertNewToHash($self->GetNew());
	my $changelog = $new->{ChangeLog};
	my $text = $new->{Text};

	require MusicBrainz::Server::Annotation;
	my $an = MusicBrainz::Server::Annotation->new($self->{DBH});

	$an->SetModerator($self->GetModerator());
	$an->SetModeration($self->GetId());
	$an->SetType(ALBUM_ANNOTATION);
	$an->SetAlbum($self->GetRowId());
	$an->SetText($text);
	$an->SetChangeLog($changelog);
	$an->Insert();

	return &ModDefs::STATUS_APPLIED;
}

sub IsAutoMod
{
	return 1;
}

1;
# eof MOD_ADD_ALBUM_ANNOTATION.pm
