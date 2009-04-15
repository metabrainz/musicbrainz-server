package MusicBrainz::Server::Form::ReleaseEditor::TrackCount;

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

sub validate_track_count
{
    my ($self, $field) = @_;

    $field->add_error('Track count must be at least 1')
        if $field->value < 1;
}

1;
