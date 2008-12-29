package MusicBrainz::Server::Form::User::Contact;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form';

sub profile
{
    return {
        required => {
            subject => 'Text',
            body    => 'TextArea',
        },
        optional => {
            reveal_address => 'Checkbox',
            send_to_self   => 'Checkbox'
        }
    };
}

1;
