package MusicBrainz::Server::Form::Label::AddAlias;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form::Alias';

sub name { 'add-label-alias' }

sub create_for
{
    my ($self, $label) = @_;

    $self->context->model('Label')->add_alias(
        $label,
        $self->value('alias'),
        $self->value('edit_note'),
    );
}

1;
