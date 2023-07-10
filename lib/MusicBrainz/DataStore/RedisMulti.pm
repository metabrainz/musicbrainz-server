package MusicBrainz::DataStore::RedisMulti;

use Moose;
use namespace::autoclean;
use DBDefs;
use MusicBrainz::DataStore::Redis;

# If the `DataStore::RedisMulti` module is active, then
# `DATASTORE_REDIS_ARGS` may return an array ref of connection details.
# (How do you know if it's active? grep for
# `DataStore::RedisMulti->new`. We may revert back to plain-old
# `DataStore::Redis` if multiple instances aren't needed.)
#
# This module is useful when Redis service needs to be migrated to a
# new server. We'll attempt to read from each connection in order
# (returning the first non-empty result), and also distribute writes to
# all connections. This allows time to copy any keys that don't exist
# on the new instance from the old instance.

has '_redis_instances' => (
    is => 'rw',
    isa => 'ArrayRef[MusicBrainz::DataStore::Redis]',
);

with 'MusicBrainz::DataStore';

around BUILDARGS => sub {
    my $orig = shift;
    my $class = shift;

    if (@_) {
        return $class->$orig(@_);
    }

    my $args = DBDefs->DATASTORE_REDIS_ARGS;
    if (ref($args) eq 'HASH') {
        $args = [$args];
    } elsif (ref($args) ne 'ARRAY') {
        die 'DATASTORE_REDIS_ARGS must return a HASH or ARRAY ref.';
    }

    $class->$orig({
        _redis_instances => [map { MusicBrainz::DataStore::Redis->new($_) } @$args],
    });
};

sub _is_non_empty_hash_ref { ref($_[0]) eq 'HASH' && %{ $_[0] } }

sub _is_defined { defined $_[0] }

sub _is_truthy { $_[0] }

sub _is_non_empty_list { scalar(@_) }

sub _exec_all { 0 }

sub _exec_method_wantarray {
    my ($self, $method, $done, @args) = @_;

    my @ret;
    for my $instance (@{ $self->_redis_instances }) {
        @ret = $instance->$method(@args);
        last if $done->(@ret);
    }
    return @ret;
}

sub _exec_method_wantscalar {
    my ($self, $method, $done, @args) = @_;

    my @ret = $self->_exec_method_wantarray($method, $done, @args);
    return $ret[0];
}

sub clear {
    shift->_exec_method_wantscalar('clear', \&_exec_all, @_);
}

sub delete_multi {
    shift->_exec_method_wantscalar('delete_multi', \&_exec_all, @_);
}

sub delete {
    shift->_exec_method_wantscalar('delete', \&_exec_all, @_);
}

sub disconnect {
    shift->_exec_method_wantscalar('disconnect', \&_exec_all, @_);
}

sub exists {
    shift->_exec_method_wantscalar('exists', \&_is_truthy, @_);
}

sub get_multi {
    shift->_exec_method_wantscalar('get_multi', \&_is_non_empty_hash_ref, @_);
}

sub get {
    shift->_exec_method_wantscalar('get', \&_is_defined, @_);
}

sub remove {
    shift->delete(@_);
}

sub set_add {
    shift->_exec_method_wantscalar('set_add', \&_exec_all, @_);
}

sub set_members {
    shift->_exec_method_wantarray('set_members', \&_is_non_empty_list, @_);
}

sub set_multi {
    shift->_exec_method_wantscalar('set_multi', \&_exec_all, @_);
}

sub set {
    shift->_exec_method_wantscalar('set', \&_exec_all, @_);
}

sub expire {
    shift->_exec_method_wantscalar('expire', \&_exec_all, @_);
}

sub expire_at {
    shift->_exec_method_wantscalar('expire_at', \&_exec_all, @_);
}

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2022 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

1;
