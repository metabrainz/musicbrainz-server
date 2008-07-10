package MusicBrainz::Server::Form::User::ForgotPassword;

use strict;
use warnings;

use base 'Form::Processor';

sub name { 'user_forgot' }

sub profile {
    return {
        required => {
        },
        optional => {
            username => 'Text',
            email => 'Email',
        }
    };
}

1;
