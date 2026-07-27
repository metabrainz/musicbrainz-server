package MusicBrainz::Server::Authentication::WebService::OAuth2User;

use strict;
use warnings;

use Moose;
use namespace::autoclean;

use MusicBrainz::Server::Entity::Types;

extends 'MusicBrainz::Server::Authentication::User';

has 'oauth_token' => (
    isa => 'EditorOAuthToken',
    is => 'rw',
);

around is_authorized => sub {
    my ($orig, $self, $scope) = @_;

    # Scoped OAuth-based login
    return $self->$orig && (
        defined $scope &&
        ($scope & $self->oauth_token->scope) == $scope
    );
};

__PACKAGE__->meta->make_immutable;

no Moose;

1;
