package MusicBrainz::Server::Form::Artist::EditAlias;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form::Alias';

sub name { 'edit-artist-alias' }

sub edit_for
{
    my ($self, $artist) = @_;

    $self->context->model('Artist')->update_alias(
        $artist,
        $self->item,
        $self->value('alias'),
        $self->value('edit_note')
    );
}

1;
