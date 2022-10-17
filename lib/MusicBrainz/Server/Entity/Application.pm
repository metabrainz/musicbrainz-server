package MusicBrainz::Server::Entity::Application;
use Moose;
use namespace::autoclean;

use MusicBrainz::Server::Constants qw( $OAUTH_WEB_APP_REDIRECT_URI_RE );
use MusicBrainz::Server::Data::Utils qw( boolean_to_json );
use MusicBrainz::Server::Entity::Types;

extends 'MusicBrainz::Server::Entity';
with 'MusicBrainz::Server::Entity::Role::Name';

has 'owner' => (
    isa => 'Editor',
    is  => 'rw',
);

has 'owner_id' => (
    isa => 'Int',
    is  => 'rw',
);

has 'oauth_id' => (
    isa => 'Str',
    is  => 'rw',
);

has 'oauth_secret' => (
    isa => 'Str',
    is  => 'rw',
);

has 'oauth_redirect_uri' => (
    isa => 'Maybe[Str]',
    is  => 'rw',
);

sub is_server
{
    my ($self) = @_;

    return defined $self->oauth_redirect_uri
        && $self->oauth_redirect_uri =~ $OAUTH_WEB_APP_REDIRECT_URI_RE;
}

sub oauth_type
{
    my ($self) = @_;

    return $self->is_server ? 'web' : 'installed';
}

around TO_JSON => sub {
    my ($orig, $self) = @_;

    return {
        %{ $self->$orig },
        is_server           => boolean_to_json($self->is_server),
        oauth_id            => $self->oauth_id,
        oauth_redirect_uri  => $self->oauth_redirect_uri,
        oauth_secret        => $self->oauth_secret,
        oauth_type          => $self->oauth_type,
    };
};

no Moose;
__PACKAGE__->meta->make_immutable;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
