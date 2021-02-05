package MusicBrainz::Server::Entity::EditorOAuthToken;
use Moose;
use namespace::autoclean;

use aliased 'DateTime' => 'DT';
use MusicBrainz::Server::Constants qw( :access_scope );
use MusicBrainz::Server::Types qw( DateTime );
use MusicBrainz::Server::Translation qw( N_l );
use MusicBrainz::Server::Data::Utils qw( boolean_to_json datetime_to_iso8601 );
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

has 'code_challenge' => (
    isa => 'Maybe[Str]',
    is => 'rw',
);

has 'code_challenge_method' => (
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

our @ACCESS_SCOPE_PERMISSIONS = (
    $ACCESS_SCOPE_PROFILE,
    $ACCESS_SCOPE_EMAIL,
    $ACCESS_SCOPE_TAG,
    $ACCESS_SCOPE_RATING,
    $ACCESS_SCOPE_COLLECTION,
    $ACCESS_SCOPE_SUBMIT_ISRC,
    $ACCESS_SCOPE_SUBMIT_BARCODE,
);

sub permissions
{
    my ($self, $scope) = @_;

    $scope ||= $self->scope;

    my @perms;
    for my $i (@ACCESS_SCOPE_PERMISSIONS) {
        if (($scope & $i) == $i) {
            push @perms, $i;
        }
    }

    return \@perms;
}

sub is_expired
{
    my ($self) = @_;

    return $self->expire_time < DT->now;
}

sub is_offline
{
    my ($self) = @_;

    return defined $self->refresh_token;
}

around TO_JSON => sub {
    my ($orig, $self) = @_;

    return {
        %{ $self->$orig },
        application => $self->application,
        editor      => defined $self->editor ? $self->editor->TO_JSON : undef,
        granted     => datetime_to_iso8601($self->granted),
        is_offline  => boolean_to_json($self->is_offline),
        permissions => $self->permissions,
        scope       => $self->scope,
    };
};

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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
