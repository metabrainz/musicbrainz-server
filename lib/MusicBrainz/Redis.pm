package MusicBrainz::Redis;

use Encode;
use Moose;
use Redis;

has '_connection' => (
    is => 'rw',
    isa => 'Redis',
);

has '_namespace' => (
    is => 'rw',
    isa => 'Str',
);

sub BUILD {
    my ($self, $args) = @_;

    $self->_connection(Redis->new(
        encoding => undef,
        reconnect => 5,
        server => $args->{server},
    ));

    if (defined $args->{database}) {
        $self->_connection->select($args->{database});
    }

    $self->_namespace($args->{namespace});
}

sub _prepare_key {
    my ($self, $key) = @_;

    encode('utf-8', $self->_namespace . $key);
}

sub _encode_value { $_[1] }

sub _decode_value { $_[1] }

sub get {
    my ($self, $key) = @_;

    my $value = $self->_connection->get($self->_prepare_key($key));
    return $self->_decode_value($value) if defined $value;
    return;
}

sub get_multi {
    my ($self, @keys) = @_;

    my @values = $self->_connection->mget(map { $self->_prepare_key($_) } @keys);
    my $i = 0;
    my %result;
    for my $key (@keys) {
        my $value = $values[$i++];
        $result{$key} = $self->_decode_value($value) if defined $value;
    }
    return \%result;
}

sub set_add {
    my ($self, $key, @values) = @_;

    $self->_connection->sadd(
        $self->_prepare_key($key),
        map { $self->_encode_value($_) } @values,
    );
    return;
}

sub set_members {
    my ($self, $key) = @_;

    return map {
        $self->_decode_value($_)
    } $self->_connection->smembers($self->_prepare_key($key));
}

sub set {
    my ($self, $key, $value, $exptime) = @_;

    my @args = ($self->_prepare_key($key), $self->_encode_value($value));
    push @args, 'EX', $exptime if defined $exptime;
    $self->_connection->set(@args);
    return;
}

sub set_multi {
    my ($self, @items) = @_;

    for (@items) {
        my ($key, $value, $exptime) = @$_;
        my @args = ($self->_prepare_key($key), $self->_encode_value($value));
        push @args, 'EX', $exptime if defined $exptime;
        $self->_connection->set(@args, sub {});
    }
    $self->_connection->wait_all_responses;
    return;
}

sub delete {
    my ($self, $key) = @_;

    $self->_connection->del($self->_prepare_key($key));
    return;
}

sub remove {
    my ($self, $key) = @_;

    $self->delete($self->_prepare_key($key));
}

sub delete_multi {
    my ($self, @keys) = @_;

    $self->_connection->del(map { $self->_prepare_key($_) } @keys);
    return;
}

sub exists {
    my ($self, $key) = @_;

    $self->_connection->exists($self->_prepare_key($key));
}

sub expire {
    my ($self, $key, $seconds) = @_;

    $self->_connection->expire($self->_prepare_key($key), $seconds);
    return;
}

sub expire_at {
    my ($self, $key, $timestamp) = @_;

    $self->_connection->expireat($self->_prepare_key($key), $timestamp);
    return;
}

sub disconnect {
    my ($self) = @_;

    $self->_connection->quit;
}

sub clear {
    my ($self) = @_;

    $self->_connection->flushdb;
}

__PACKAGE__->meta->make_immutable;

no Moose;

1;

=head1 COPYRIGHT

Copyright (C) 2016 MetaBrainz Foundation

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
