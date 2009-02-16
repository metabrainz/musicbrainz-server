package MusicBrainz::Server::Form::Artist::Merge;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form';

sub name { 'merge-artist' }

sub merge_into
{
    my ($self, $new_artist) = @_;

    $self->context->model('Artist')->merge(
        $self->item,
        $new_artist,
        $self->value('edit_note')
    );
}

1;
