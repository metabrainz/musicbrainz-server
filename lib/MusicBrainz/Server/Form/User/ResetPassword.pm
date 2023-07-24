package MusicBrainz::Server::Form::User::ResetPassword;
use strict;
use warnings;

use HTML::FormHandler::Moose;

extends 'MusicBrainz::Server::Form';

with 'MusicBrainz::Server::Form::Role::CSRFToken';

has '+name' => ( default => 'resetpassword' );

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

    # To update the form with any errors when it's shown again
    $self->ctx->stash->{component_props}{form} = $self->TO_JSON;
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
