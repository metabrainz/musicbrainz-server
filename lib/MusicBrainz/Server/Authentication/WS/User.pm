package MusicBrainz::Server::Authentication::WS::User;
use Moose;

use MusicBrainz::Server::Entity::Types;

extends 'MusicBrainz::Server::Entity::Editor';

has 'auth_realm' => (
    isa => 'Str',
    is => 'rw'
);

has 'oauth_token' => (
    isa => 'EditorOAuthToken',
    is => 'rw'
);

sub supported_features
{
    return { oauth => 1 };
}

sub is_authorized
{
    my ($self, $scope) = @_;

    # Username/password login with full access
    return 1 unless defined $self->oauth_token;

    # Scoped OAuth-based login
    return 1 if ($scope & $self->oauth_token->scope) == $scope;

    return 0;
}

sub new_from_editor
{
    my ($class, $editor) = @_;

    return undef
        unless $editor;

    return Class::MOP::Class->initialize($class)->rebless_instance($editor);
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
