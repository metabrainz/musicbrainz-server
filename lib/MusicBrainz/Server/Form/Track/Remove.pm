package MusicBrainz::Server::Form::Track::Remove;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form';

sub name { 'remove_track' }

sub remove_from_release
{
    my ($self, $release) = @_;

    $self->context->model('Track')->remove_from_release(
	$self->item,
	$release,
	$self->value('edit_note'),
    );
}

1;
