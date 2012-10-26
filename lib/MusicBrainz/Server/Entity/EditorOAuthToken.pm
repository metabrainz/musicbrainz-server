package MusicBrainz::Server::Entity::EditorOAuthToken;
use Moose;
use namespace::autoclean;

use MusicBrainz::Server::Types qw( DateTime );
use MusicBrainz::Server::Entity::Types;

extends 'MusicBrainz::Server::Entity';

has 'editor' => (
    isa => 'Editor',
    is => 'rw',
);

has 'editor_id' => (
    isa => 'Int',
    is => 'rw',
);

has 'application' => (
    isa => 'Application',
    is => 'rw',
);

has 'application_id' => (
    isa => 'Int',
    is => 'rw',
);

has 'authorization_code' => (
    isa => 'Maybe[Str]',
    is => 'rw',
);

has 'refresh_token' => (
    isa => 'Maybe[Str]',
    is => 'rw',
);

has 'access_token' => (
    isa => 'Maybe[Str]',
    is => 'rw',
);

has 'secret' => (
    isa => 'Maybe[Str]',
    is => 'rw',
);

has 'expire_time' => (
    isa => DateTime,
    is => 'rw',
    coerce => 1
);

has [qw( scope_profile scope_tags scope_ratings )] => (
    isa => 'Bool',
    is => 'rw',
);

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 DESCRIPTION

This class represents multiple OAuth tokens. Which type is it depends on
the set of defined attributes.

First of all, it can be an authorization code. In this case only the
authorization_code attribute is set. The expire_time attribute is set
to the time when this code expires.

After the authorization code has been exchanged for an access token,
the authorization_code attribute will be cleared and attributes
access_token and refresh_token set. Attribute expire_time now refers
to the expiration time of the access token. The access token can be
of two types:

* Bearer - In this case the secret attribute is undefined and the token
  can be used only over secure connections. The access token should be
  treated as a password.

* MAC - The secret attribute is defined as well, and the access token
  can be transmitted plain text, because all requests have to be signed
  with the shared secret.

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
