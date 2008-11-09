package MusicBrainz::Server::Form::Artist::AddAlias;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form::Alias';

sub create_for
{
    my ($self, $artist) = @_;

    $self->context->model('Artist')->add_alias(
        $self->item,
        $self->value('alias'),
        $self->value('edit_note')
    );
}

1;
