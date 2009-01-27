package MusicBrainz::Server::Form::AddRelease::TrackCount;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form';

sub name { 'add-release-track-count' }

sub profile
{
    return {
        required => {
            track_count => 'Integer',
        }
    };
}

1;
