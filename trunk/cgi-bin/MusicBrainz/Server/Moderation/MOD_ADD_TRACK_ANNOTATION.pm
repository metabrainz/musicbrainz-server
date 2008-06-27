#!/usr/bin/perl -w
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
#   $Id: MOD_ADD_TRACK_ANNOTATION.pm 8903 2007-03-12 07:43:40Z robert $
#____________________________________________________________________________

use strict;

package MusicBrainz::Server::Moderation::MOD_ADD_TRACK_ANNOTATION;

use ModDefs;
use MusicBrainz::Server::Annotation ':type';
use base 'Moderation';

sub Name { "Add Track Annotation" }
(__PACKAGE__)->RegisterHandler;

sub PreInsert
{
	my ($self, %opts) = @_;

	my $trackid = $opts{'trackid'} or die;
	my $artistid = $opts{'artistid'} or die;
	my $text = $opts{'text'} || '';
	my $changelog = $opts{'changelog'} || '';

	my %new = (
		Text => $text,
		ChangeLog => $changelog,
	);

	$self->SetArtist($artistid);
	$self->SetNew($self->ConvertHashToNew(\%new));
	$self->SetTable('track');
	$self->SetColumn('annotation.text');
	$self->SetRowId($trackid);
}

sub IsAutoEdit 
{ 
    1 
}

sub PostLoad
{
	my $self = shift;
		
	($self->{"trackid"}, $self->{"checkexists-track"}) = ($self->GetRowId, 1);
} 

sub PreDisplay
{
	my $this = shift;

	# load annotation data
	my $an = MusicBrainz::Server::Annotation->new($this->{DBH});
	$an->SetModeration($this->GetId());
	if ($an->LoadFromId())
	{
		my $log = $an->GetChangeLog;
		$log = "(no change log)"
			unless ($log =~ /\S/);
		$this->{'changelog'} = $log;
		$this->{'annotid'} = $an->GetId;
	}
}

sub ApprovedAction
{
	my $self = shift;

	my $new = $self->ConvertNewToHash($self->GetNew());
	my $changelog = $new->{ChangeLog};
	my $text = $new->{Text};

	print STDERR __PACKAGE__ . "Approved Annotation $text\n";

	require MusicBrainz::Server::Annotation;
	my $an = MusicBrainz::Server::Annotation->new($self->{DBH});

	$an->SetModerator($self->GetModerator());
	$an->SetModeration($self->GetId());
	$an->SetType(TRACK_ANNOTATION);
	$an->SetTrack($self->GetRowId());
	$an->SetText($text);
	$an->SetChangeLog($changelog);
	$an->Insert();

	return &ModDefs::STATUS_APPLIED;
}

1;
# eof MOD_ADD_TRACK_ANNOTATION.pm
