package MusicBrainz::Server::Entity::Application;
use Moose;
use namespace::autoclean;

use MusicBrainz::Server::Constants qw( $OAUTH_WEB_APP_REDIRECT_URI_RE );
use MusicBrainz::Server::Data::Utils qw( boolean_to_json );
use MusicBrainz::Server::Entity::Types;

extends 'MusicBrainz::Server::Entity';

has 'owner' => (
    isa => 'Editor',
    is  => 'rw',
);

has 'owner_id' => (
    isa => 'Int',
    is  => 'rw',
);

has 'name' => (
    isa => 'Str',
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
        name                => $self->name,
        oauth_id            => $self->oauth_id,
        oauth_redirect_uri  => $self->oauth_redirect_uri,
        oauth_secret        => $self->oauth_secret,
        oauth_type          => $self->oauth_type,
    };
};

no Moose;
__PACKAGE__->meta->make_immutable;
1;

=head1 COPYRIGHT

Copyright (C) 2012 Lukas Lalinsky

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
