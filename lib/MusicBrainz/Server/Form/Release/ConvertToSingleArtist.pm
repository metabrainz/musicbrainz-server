package MusicBrainz::Server::Form::Release::ConvertToSingleArtist;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form';

sub convert
{
    my ($self, $new_artist) = @_;

    $self->context->model('Release')->convert(
        $self->item,
        $new_artist,
        $self->value('edit_note'),
    );
}

1;
