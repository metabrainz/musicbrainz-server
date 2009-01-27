package MusicBrainz::Server::Form::Label::EditAlias;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form::Alias';

sub name { 'edit-label-alias' }

sub edit_for
{
    my ($self, $label) = @_;

    $self->context->model('Label')->edit_alias(
        $label,
        $self->item,
        $self->value('alias'),
        $self->value('edit_note'),
    );
}

1;
