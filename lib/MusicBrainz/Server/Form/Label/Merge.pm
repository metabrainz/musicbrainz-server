package MusicBrainz::Server::Form::Label::Merge;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form';

sub name { 'merge-label' }

sub merge_into
{
    my ($self, $new_label) = @_;

    $self->context->model('Label')->merge(
        $self->item,
        $new_label,
        $self->value('edit_note')
    );
}

1;
