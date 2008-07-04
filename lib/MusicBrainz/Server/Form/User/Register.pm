package MusicBrainz::Server::Form::User::Register;

use strict;
use warnings;

use base 'Form::Processor';

sub name { "register"; }

sub profile {
    return {
        required => {
            username => 'Text',
            password => {
                type => 'Password',
                min_length => 1
            },
            confirm_password => {
                type => 'Password',
                min_length => 1
            },
        },
        optional => {
            email => 'Email'
        }
    };
}

sub validate_confirm_password {
    my ($self, $field) = @_;

    $field->add_error("Both provided passwords must be equal")
        if $field->value ne $self->value('password');
}

1;
