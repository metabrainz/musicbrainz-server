package MusicBrainz::Server::Form::Artist::AddNonAlbumTrack;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form::EditForm';

sub profile
{
    return {
        required => {
            track => {
                type => '+MusicBrainz::Server::Form::Field::Track',

                # Don't require a track number for non album tracks
                with_track_number => 0, 
            }
        },
        optional => {
            edit_note => 'TextArea',
        }
    }
}

sub mod_type { ModDefs::MOD_ADD_TRACK_KV }

sub build_options
{
    my $self = shift;
    my $artist = $self->item;

    return {
        artist      => $artist,
        trackname   => $self->value('track')->{name},
        tracklength => $self->value('track')->{duration} || 0,
    }
}

1;
