package MusicBrainz::Server::Form::Release::ConvertToMultipleArtists;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form';

sub profile
{
    return {
        optional => {
            edit_note => 'TextArea',
            various_release_artist => 'Checkbox',
            change_track_artists   => 'Checkbox',
        }
    };
}

1;
