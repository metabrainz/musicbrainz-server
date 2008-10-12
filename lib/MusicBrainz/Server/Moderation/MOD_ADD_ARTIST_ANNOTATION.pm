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
#   $Id$
#____________________________________________________________________________

package MusicBrainz::Server::Moderation::MOD_ADD_ARTIST_ANNOTATION;

use strict;
use warnings;

use base 'Moderation';

use ModDefs;
use MusicBrainz::Server::Annotation ':type';

sub Name { "Add Artist Annotation" }
sub id   { 30 }

sub edit_conditions
{
    return {
        ModDefs::QUALITY_LOW => {
            duration     => 0,
            votes        => 0,
            expireaction => ModDefs::EXPIRE_ACCEPT,
            autoedit     => 1,
            name         => $_[0]->Name,
        },  
        ModDefs::QUALITY_NORMAL => {
            duration     => 0,
            votes        => 0,
            expireaction => ModDefs::EXPIRE_ACCEPT,
            autoedit     => 1,
            name         => $_[0]->Name,
        },
        ModDefs::QUALITY_HIGH => {
            duration     => 0,
            votes        => 0,
            expireaction => ModDefs::EXPIRE_REJECT,
            autoedit     => 1,
            name         => $_[0]->Name,
        },
    }
}

sub PreInsert
{
	my ($self, %opts) = @_;

	my $artistid = $opts{'artistid'} or die;
	my $text = $opts{'text'} || '';
	my $changelog = $opts{'changelog'} || '';

	my %new = (
		Text => $text,
		ChangeLog => $changelog,
	);

	$self->artist($artistid);
	$self->SetNew($self->ConvertHashToNew(\%new));
	$self->table('artist');
	$self->SetColumn('annotation.text');
	$self->row_id($artistid);
}

sub IsAutoEdit 
{ 
    1 
}

sub PreDisplay
{
	my $this = shift;
	
	# load annotation data
	my $an = MusicBrainz::Server::Annotation->new($this->{DBH});
	$an->moderation($this->id());
	if ($an->LoadFromId())
	{
		my $log = $an->change_log;
		$log = "(no change log)"
			unless ($log =~ /\S/);
		$this->{'changelog'} = $log;
		$this->{'annotid'} = $an->id;
	}
}

sub ApprovedAction
{
	my $self = shift;

	my $new = $self->ConvertNewToHash($self->GetNew());
	my $changelog = $new->{ChangeLog};
	my $text = $new->{Text};

	require MusicBrainz::Server::Annotation;
	my $an = MusicBrainz::Server::Annotation->new($self->{DBH});

	$an->moderator($self->moderator());
	$an->moderation($self->id());
	$an->type(ARTIST_ANNOTATION);
	$an->artist($self->row_id());
	$an->text($text);
	$an->change_log($changelog);
	$an->Insert();

	return &ModDefs::STATUS_APPLIED;
}

1;
# eof MOD_ADD_ARTIST_ANNOTATION.pm
