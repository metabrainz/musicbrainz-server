package MusicBrainz::DataStore::Redis;
use Moose;
use DBDefs;
use Encode;
use Redis;
use JSON;

with 'MusicBrainz::DataStore';

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
    lazy => 1,
    default => sub {
        my $self = shift;
        my $connection = Redis->new(%{ $self->redis_new_args });
        $connection->select( $self->database );
        return $connection;
    }
);

has '_json' => (
    is => 'ro',
    default => sub {
        JSON->new->allow_nonref->allow_blessed->convert_blessed->ascii;
    }
);

sub _prepare_key {
    my ($self, $key) = @_;
    return encode('utf-8', $self->prefix . $key);
}

sub _decode_value {
    my ($self, $value) = @_;
    return defined $value ? $self->_json->decode($value) : undef;
}

sub get {
    my ($self, $key) = @_;

    my $value = $self->_connection->get($self->_prepare_key($key));

    return $self->_decode_value($value);
}

sub mget {
    my ($self, @keys) = @_;

    map { $self->_decode_value($_) }
    $self->_connection->mget(map { $self->_prepare_key($_) } @keys);
}

sub set {
    my ($self, $key, $value) = @_;

    return $self->_connection->set(
        $self->_prepare_key($key), $self->_json->encode($value));
}

sub exists {
    my ($self, $key) = @_;

    return $self->_connection->exists($self->_prepare_key($key));
}

sub del {
    my ($self, $key) = @_;

    return $self->_connection->del($self->_prepare_key($key));
}

=method expire

Expire the specified key in $s seconds

=cut

sub expire {
    my ($self, $key, $s) = @_;

    return $self->_connection->expire($self->_prepare_key($key), $s);
}

sub expireat {
    my ($self, $key, $timestamp) = @_;

    return $self->_connection->expireat($self->_prepare_key($key), $timestamp);
}

sub _flushdb {
    my ($self) = @_;

    return $self->_connection->flushdb();
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

