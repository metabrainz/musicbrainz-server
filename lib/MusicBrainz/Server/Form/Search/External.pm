package MusicBrainz::Server::Form::Search::External;

use strict;
use warnings;

use base 'Form::Processor';

sub name { 'search_external' }

sub profile {
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

sub options_type {
    return [
        'annotation' => 'Annotations',
        'artist'     => 'Artists',
        'freedb'     => 'FreeDB',
        'label'      => 'Labels',
        'release'    => 'Releases',
        'track'      => 'Tracks',
    ];
}

sub options_limit {
    return map { $_ => "Up to $_" } (25, 50, 100);
}

1;
