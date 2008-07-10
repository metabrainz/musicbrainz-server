package MusicBrainz::Server::Form::User::EditProfile;

use strict;
use warnings;

use base 'Form::Processor';

sub name { 'user_edit_profile' }

sub profile {
    return {
        optional => {
            email => 'Email',
            homepage => 'URL',
            biography => 'TextArea'
        }
    };
}

1;
