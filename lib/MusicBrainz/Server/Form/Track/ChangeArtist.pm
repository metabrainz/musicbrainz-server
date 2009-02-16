package MusicBrainz::Server::Form::Track::ChangeArtist;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form';

sub name { 'change-track-artist' }

sub change_artist
{
    my ($self, $new_artist) = @_;

    $self->context->model('Track')->change_artist(
	$self->item,
	$new_artist,
	$self->value('edit_note')
    );
}

1;
