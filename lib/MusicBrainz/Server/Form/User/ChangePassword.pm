package MusicBrainz::Server::Form::User::ChangePassword;

use HTML::FormHandler::Moose;
use MusicBrainz::Server::Translation qw( l ln );

extends 'MusicBrainz::Server::Form';

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
};

1;

=head1 COPYRIGHT

Copyright (C) 2009 Lukas Lalinsky

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut
