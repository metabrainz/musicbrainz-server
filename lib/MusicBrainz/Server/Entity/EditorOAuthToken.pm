package MusicBrainz::Server::Entity::EditorOAuthToken;
use Moose;
use namespace::autoclean;

use DateTime;
use MusicBrainz::Server::Constants qw( :access_scope );
use MusicBrainz::Server::Types qw( DateTime );
use MusicBrainz::Server::Translation qw( N_l );
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

has 'mac_key' => (
    isa => 'Maybe[Str]',
    is => 'rw',
);

has 'mac_time_diff' => (
    isa => 'Maybe[Int]',
    is => 'rw',
);

has 'expire_time' => (
    isa => DateTime,
    is => 'rw',
    coerce => 1
);

has 'scope' => (
    isa => 'Int',
    is => 'rw',
);

has 'granted' => (
    isa => DateTime,
    is => 'rw',
    coerce => 1
);

our %ACCESS_SCOPE_PERMISSIONS = (
    $ACCESS_SCOPE_PROFILE        => N_l('View your public account information'),
    $ACCESS_SCOPE_EMAIL          => N_l('View your email address'),
    $ACCESS_SCOPE_TAG            => N_l('View and modify your private tags'),
    $ACCESS_SCOPE_RATING         => N_l('View and modify your private ratings'),
    $ACCESS_SCOPE_COLLECTION     => N_l('View and modify your private collections'),
    $ACCESS_SCOPE_SUBMIT_PUID    => N_l('Submit new PUIDs to the database'),
    $ACCESS_SCOPE_SUBMIT_ISRC    => N_l('Submit new ISRCs to the database'),
    $ACCESS_SCOPE_SUBMIT_BARCODE => N_l('Submit new barcodes to the database'),
);

sub permissions
{
    my ($self, $scope) = @_;

    $scope ||= $self->scope;

    my @perms;
    for my $i (keys %ACCESS_SCOPE_PERMISSIONS) {
        if (($scope & $i) == $i) {
            push @perms, $ACCESS_SCOPE_PERMISSIONS{$i};
        }
    }

    return \@perms;
}

sub is_expired
{
    my ($self) = @_;

    return $self->expire_time < DateTime->now;
}

sub is_offline
{
    my ($self) = @_;

    return defined $self->refresh_token;
}

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
access_token and (optionally) refresh_token set. Attribute expire_time
now refers to the expiration time of the access token. The access token
can be of two types:

* Bearer - In this case the secret attribute is undefined and the token
  can be used only over secure connections. The access token should be
  treated as a password.

* MAC - The secret attribute is defined as well, and the access token
  can be transmitted plain text, because all requests have to be signed
  with the shared secret.

The refresh_token is only set when the application asked for offline access.
When it's set, the application can ask to update the access_token and 
reset its expiration time. When refresh_token is not set, the access token is
can't be reused after it's expired.

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
