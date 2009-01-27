package MusicBrainz::Server::Form::Tag::Tags;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form';

sub name { 'add-tags' }

sub profile
{
    return {
        optional => {
            tags => 'TextArea',
        },
    };
}

1;
