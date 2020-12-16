package MusicBrainz::Server::Form::User::Register;

use HTML::FormHandler::Moose;
use MusicBrainz::Server::Form::Utils qw( validate_username );
use MusicBrainz::Server::Translation qw( l N_l );

extends 'MusicBrainz::Server::Form';

with 'MusicBrainz::Server::Form::Role::CSRFToken';

has '+name' => ( default => 'register' );

has_field 'username' => (
    type      => 'Text',
    required  => 1,
    maxlength => 64,
    validate_method => \&validate_username,
);

has_field 'password' => (
    type      => 'Password',
    required  => 1,
    minlength => 1,
    maxlength => 64,
    messages  => { required => N_l('Please enter a password in this field') },
    localize_meth => sub { my ($self, @message) = @_; return l(@message); }
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
