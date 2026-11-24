package MusicBrainz::Server::Authentication::User;
use Moose;
use namespace::autoclean;
use Readonly;

use MusicBrainz::Server::Authentication::Utils qw( can_user_login );

extends 'MusicBrainz::Server::Entity::Editor';

has 'auth_realm' => (
    isa => 'Str',
    is => 'rw',
);

Readonly our %supported_features => (
    session => 1,
);

sub supports
{
    my ($self, @spec) = @_;
    for (@spec) {
        return 0 unless exists $supported_features{$_};
    }
    return 1;
}

sub get
{
    my ($self, $key) = @_;
    return $self->can($key) ? $self->$key : undef;
}

sub is_authorized
{
    my ($self) = @_;
    return can_user_login($self);
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
