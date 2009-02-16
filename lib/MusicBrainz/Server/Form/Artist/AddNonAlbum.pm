package MusicBrainz::Server::Form::Artist::AddNonAlbum;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form';

sub name { 'add-nat' }

sub profile
{
    shift->with_mod_fields({
        required => {
            track => {
                type => '+MusicBrainz::Server::Form::Field::Track',

                # Don't require a track number for non album tracks
                with_track_number => 0,
            }
        },
    });
}

sub add_track
{
    my $self = shift;

    my $track = new MusicBrainz::Server::Track;
    $track->name($self->value('track')->{name});
    $track->length($self->value('track')->{duration} || 0);

    my $artist = $self->item;

    $self->context->model('Track')->add_non_album_track(
        $artist,
        $track,
        $self->value('edit_note')
    );
}

1;
