package MusicBrainz::Server::Form::User::Login;

use strict;
use warnings;

use base 'Form::Processor';

sub name { 'Login' }

sub profile
{
    my $self = shift;

    return {
        required => {
            username => 'Text',
            password => {
                type => 'Password',
                min_length => 1
            }
        },
        optional => {
            singleIp => 'Checkbox',
            rememberMe => 'Checkbox',
        }
    }
}

1;
