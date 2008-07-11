package MusicBrainz::Server::Form::User::ChangePassword;

use strict;
use warnings;

use base 'Form::Processor';

sub name { 'user_changePass' }

sub profile {
    return {
        required => {
            old_password => 'Password',
            new_password => 'Password',
            confirm_new_password => 'Password',
        },
    };
}

sub cross_validate {
    my ($self) = @_;

    my ($new, $confirm) = ( $self->field('new_password'),
                            $self->field('confirm_new_password') );

    $confirm->add_error("The new password fields must match")
        if $confirm->value ne $new->value;
}

1;
