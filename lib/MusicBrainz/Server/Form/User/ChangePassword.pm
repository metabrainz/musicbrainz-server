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

sub validate_confirm_new_password {
    my ($self, $field) = @_;

    $field->add_error("The new password fields must match")
        if $field->value ne $self->value('new_password');
}

1;
