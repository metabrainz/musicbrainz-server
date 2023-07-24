package MusicBrainz::Server::Form::User::ChangePassword;
use strict;
use warnings;

use HTML::FormHandler::Moose;
use MusicBrainz::Server::Translation qw( l );

extends 'MusicBrainz::Server::Form';

with 'MusicBrainz::Server::Form::Role::CSRFToken';

has '+name' => ( default => 'changepassword' );

has_field 'username' => (
    type => 'Text',
    required => 1,
);

has_field 'old_password' => (
    type => 'Password',
    required => 1,
    min_length => 1,
);

has_field 'password' => (
    type => 'Password',
    required => 1,
    min_length => 1,
);

has_field 'confirm_password' => (
    type => 'PasswordConf',
    password_field => 'password',
    required => 1,
    min_length => 1,
);

after validate => sub {
    my ($self) = @_;

    my $password_field = $self->field('old_password');
    my $password = $password_field->value;

    if ($password) {
        my $username_field = $self->field('username');

        my $editor = $self->ctx->model('Editor')->get_by_name(
            $username_field->value);

        if ($editor) {
            if (!$editor->match_password($password)) {
                $password_field->add_error(
                    l('The old password is incorrect'));
            }
        }
        else {
            $username_field->add_error(
                l('An account with this name could not be found'));
        }
    }
    # To update the form with the errors when it's shown again
    $self->ctx->stash->{component_props}{form} = $self->TO_JSON;
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
