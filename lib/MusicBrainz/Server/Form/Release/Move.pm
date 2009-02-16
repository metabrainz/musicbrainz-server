package MusicBrainz::Server::Form::Release::Move;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form';

sub name { 'move-release' }

sub profile
{
    shift->with_mod_fields({
        optional => {
            move_tracks => 'Checkbox',
        }
    });
}

sub move
{
    my ($self, $from, $to) = @_;

    $self->context->model('Release')->change_artist(
        $self->item,
        $from,
        $to,
        $self->value('edit_note'),
        change_track_artist => $self->value('move_tracks'),
    );
}

1;
