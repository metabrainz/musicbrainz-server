package MusicBrainz::Server::Form::Confirm;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form';

sub profile
{
    return {
        required => {
            edit_note => 'TextArea',
        }
    };
}

1;
