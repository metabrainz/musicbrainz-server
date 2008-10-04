package MusicBrainz::Server::Form::Relate::Url;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form';

sub profile
{
    return {
        required => {
            url  => 'URL',
            type => 'Select',
        },
        optional => {
            description => 'TextArea',
            edit_note   => 'TextArea',
        }
    }
}

sub options_type
{
    (0 => '[Please select a type]')
}

1;
