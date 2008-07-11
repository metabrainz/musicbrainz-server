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

sub cross_validate {
    my $self = shift;

    my ($pass, $confirm) = ( $self->field('password'),
                             $self->field('confirm_password') );

    $confirm->add_error("Both provided passwords must be equal")
        if $confirm->value ne $pass->value;
}

1;
