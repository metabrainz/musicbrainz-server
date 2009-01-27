package MusicBrainz::Server::Form::Label::RemoveAlias;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form';

sub name { 'remove-label-alias' }

sub remove_from
{
    my ($self, $label) = @_;

    $self->context->model('Label')->remove_alias(
        $label,
        $self->item,
        $self->value('edit_note')
    );
}

1;
