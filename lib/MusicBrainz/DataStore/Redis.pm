package MusicBrainz::DataStore::Redis;
use Moose;
use DBDefs;
use Redis;
use JSON;

extends 'MusicBrainz::DataStore';

has 'prefix' => (
    is => 'ro',
    default => sub { return DBDefs->DATASTORE_REDIS_ARGS->{prefix}; }
);

has 'database' => (
    is => 'ro',
    isa => 'Int',
    default => 0
);

has 'redis_new_args' => (
    is => 'ro',
    default => sub { return DBDefs->DATASTORE_REDIS_ARGS->{redis_new_args}; }
);

has '_connection' => (
    is => 'rw',
    isa => 'Redis',
);

has '_json' => (
    is => 'ro',
    default => sub { return JSON->new->allow_nonref->ascii; }
);

sub BUILD {
    my $self = shift;

    $self->_connection( Redis->new(%{ $self->redis_new_args }) );
    $self->_connection->select( $self->database );
};

override get => sub {
    my ($self, $key) = @_;

    my $value = $self->_connection->get ($self->prefix.$key);

    return defined $value ? $self->_json->decode ($value) : undef;
};

override set => sub {
    my ($self, $key, $value) = @_;

    return $self->_connection->set (
        $self->prefix.$key, $self->_json->encode ($value));
};

override exists => sub {
    my ($self, $key) = @_;

    return $self->_connection->exists ($self->prefix.$key);
};

override del => sub {
    my ($self, $key) = @_;

    return $self->_connection->del ($self->prefix.$key);
};

=method add

Expire the specified key at (unix) $timestamp.

=cut

override expire => sub {
    my ($self, $key, $timestamp) = @_;

    return $self->_connection->expireat ($self->prefix.$key, $timestamp);
};

override incr => sub {
    my ($self, $key, $increment) = @_;

    return $self->_connection->incrby ($self->prefix.$key, $increment // 1);
};

=method add

Store the $value on the server under the $key, but only if the key
doesn't exists on the server.

=cut

override add => sub {
    my ($self, $key, $value) = @_;

    return $self->_connection->setnx ($self->prefix.$key, $self->_json->encode ($value));
};


sub _flushdb {
    my ($self) = @_;

    return $self->_connection->flushdb ();
}

=head1 LICENSE

Copyright (C) 2013 MetaBrainz Foundation

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

1;

