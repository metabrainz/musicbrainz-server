package MusicBrainz::Server::Form::Track;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form';

sub profile
{
    {
        required => {
            name   => 'Text',
            number => '+MusicBrainz::Server::Form::Field::TrackNumber',
        },
        optional => {
            duration  => '+MusicBrainz::Server::Form::Field::Time',
            edit_note => 'TextArea',
        }
    }
}

1;
