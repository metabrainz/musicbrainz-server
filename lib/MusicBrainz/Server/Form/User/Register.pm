package MusicBrainz::Server::Form::User::Register;

use HTML::FormHandler::Moose;

extends 'MusicBrainz::Server::Form';

has '+name' => ( default => 'register' );

has_field 'username' => (
    type => 'Text',
    required => 1,
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

has_field 'email' => (
    type => 'Email',
);

sub validate_username
{
    my ($self, $field) = @_;

    my $username = $field->value;
    if ($username) {
        my $editor = $self->ctx->model('Editor')->get_by_name($username);
        if (defined $editor) {
            $field->add_error($self->ctx->gettext('Please choose another username, this one is already taken'));
        }
    }
}

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
