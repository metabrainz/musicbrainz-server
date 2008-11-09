package MusicBrainz::Server::Form::Release::Remove;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form::Confirm';

sub remove
{
    my ($self) = @_;

    $self->context->model('Release')->remove(
        $self->item,
        $self->value('edit_note')
    );
}

1;
