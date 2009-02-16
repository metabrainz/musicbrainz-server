package MusicBrainz::Server::Form::Search::External;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form';

sub name { 'search-external' }

sub profile
{
    return {
        required => {
            type  => 'Select',
            query => 'Text'
        },
        optional => {
            limit           => 'Select',
            enable_advanced => 'Checkbox',
        },
    }
}

sub options_type
{
    return [
        'artist'     => 'Artists',
        'label'      => 'Labels',
        'release'    => 'Releases',
        'track'      => 'Tracks',
        'annotation' => 'Annotations',
        'freedb'     => 'FreeDB',
        'editor'     => 'Editor',
    ];
}

sub options_limit
{
    return map { $_ => "Up to $_" } (25, 50, 100);
}

1;
