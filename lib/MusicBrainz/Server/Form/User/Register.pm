package MusicBrainz::Server::Form::User::Register;

use HTML::FormHandler::Moose;
use MusicBrainz::Server::Form::Utils qw( validate_username );
use MusicBrainz::Server::Translation qw( l N_l );

extends 'MusicBrainz::Server::Form';

with 'MusicBrainz::Server::Form::Role::CSRFToken';

has '+name' => ( default => 'register' );

my $text_too_long_message = N_l('The value of this field cannot be longer than {max} characters, but you entered {actual}.');

sub localize_method_with_text_maxlength {
    my ($self, $message, @args) = @_;
    
    if ($message eq $text_too_long_message) {
        return l($message, { max => $args[0], actual => $args[1] });
    }

    return l($message);
}

has_field 'username' => (
    type      => 'Text',
    required  => 1,
    maxlength => 64,
    validate_method => \&validate_username,
    messages  => {
        text_maxlength => $text_too_long_message,
    },
    localize_meth => \&localize_method_with_text_maxlength,
);

has_field 'password' => (
    type      => 'Password',
    required  => 1,
    minlength => 1,
    maxlength => 64,
    messages  => {
        required => N_l('Please enter a password in this field'),
        text_maxlength => $text_too_long_message,
    },
    localize_meth => \&localize_method_with_text_maxlength,
);

has_field 'confirm_password' => (
    type           => 'PasswordConf',
    password_field => 'password',
    required       => 1,
    minlength      => 1,
    messages       => { pass_conf_not_matched => N_l('The password confirmation does not match the password') },
    localize_meth => sub { my ($self, @message) = @_; return l(@message); }
);

has_field 'email' => (
    type      => 'Email',
    maxlength => 64,
    required => 1
);

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
