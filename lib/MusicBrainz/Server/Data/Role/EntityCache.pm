package MusicBrainz::Server::Data::Role::EntityCache;

use DBDefs;
use Moose::Role;
use namespace::autoclean;
use List::AllUtils qw( uniq );
use MusicBrainz::Server::Validation qw( is_database_row_id );
use Readonly;

requires '_type';

=head1 Cache invalidation and locking

In order to prevent stale entities from being repopulated in the cache after
another process invalidates those entries (MBS-7241), we track which entity
IDs were recently invalidated in our Redis store. (In production, MBS uses
two Redis instances: one as an LRU cache for entity data, and another as a
persistent data store, mainly for login sessions.) As an example, consider
the following sequence of events:

 1. Request A updates artist ID=123 and calls _delete_from_cache(123). In our
    persistent Redis store, we set `artist:recently_invalidated:123` to '1'.
    In our Redis cache, we delete `artist:123`. (While cache addition is
    delayed until after the relevant transaction commits, cache deletion is
    performed immediately.)

 2. Request B starts before request A's database transaction commits, and
    attempts to load artist ID=123. Since it's not in the cache, we read it
    from the database, seeing the "old" version.

 3. Request B commits, and adds the stale artist to the cache at
    `artist:123`.

 4. Immediately after adding it to the cache, we check for the presence of an
    `artist:recently_invalidated:123` key in the Redis store. If it exists,
    we remove the stale `artist:123` entry we just added to the cache.

The `recently_invalidated` keys have their TTLs set to the "max request time"
determined by `DBDefs::DETERMINE_MAX_REQUEST_TIME`. The idea behind this is
that if the request times out, any database handles used in the request will
be closed and all transactions will be rolled back. In case the max request
time is undefined or 0 (indicating no limit), we set the TTL to
`$RECENTLY_INVALIDATED_TTL`, which defaults to 10 minutes.

Originally, MBS-7241 was resolved by using using database-level locks
(`pg_advisory_xact_lock`). Lock contention and deadlocks (MBS-11345,
MBS-12314, ...) were a persistent issue with that approach. We also hit
limits on the number of locks being held in a single transaction (MBS-10497).

=cut

Readonly our $RECENTLY_INVALIDATED_TTL => 600;

Readonly our $MAX_CACHE_ENTRIES => 500;

has _cache_prefix => (
    is => 'ro',
    isa => 'Str',
    lazy => 1,
    default => sub { shift->_type . ':' },
);

has _recently_invalidated_prefix => (
    is => 'ro',
    isa => 'Str',
    lazy => 1,
    default => sub { shift->_cache_prefix . 'recently_invalidated:' },
);

around get_by_ids => sub {
    my ($orig, $self, @ids) = @_;
    @ids = grep { is_database_row_id($_) } @ids;
    return {} unless @ids;
    my %ids = map { $_ => 1 } @ids;
    my $cache_prefix = $self->_cache_prefix;
    my @keys = map { $cache_prefix . $_ } keys %ids;
    my $cache = $self->c->cache($self->_type);
    my %cached_data = %{ $cache->get_multi(@keys) };
    my %result;
    foreach my $key (keys %cached_data) {
        my @key = split /:/, $key;
        my $id = $key[1];
        $result{$id} = $cached_data{$key};
        delete $ids{$id};
    }
    if (%ids) {
        my @ids_to_fetch = keys %ids;
        my $data = $self->$orig(@ids_to_fetch) || {};
        my @ids_to_cache = keys %$data;
        foreach my $id (@ids_to_cache) {
            $result{$id} = $data->{$id};
        }
        if (scalar(@ids_to_cache) > $MAX_CACHE_ENTRIES) {
            @ids_to_cache = @ids_to_cache[0..$MAX_CACHE_ENTRIES];
        }
        $self->_add_to_cache($cache, $data, \@ids_to_cache);
    }
    return \%result;
};

after update => sub {
    my ($self, $id) = @_;
    $self->_delete_from_cache($id);
};

after delete => sub {
    my ($self, @ids) = @_;
    $self->_delete_from_cache(@ids);
};

sub _create_cache_entries {
    my ($self, $data, $ids) = @_;

    my $cache_prefix = $self->_cache_prefix;
    my $ttl = DBDefs->ENTITY_CACHE_TTL;

    return map {
        [$cache_prefix . $_, $data->{$_}, ($ttl ? $ttl : ())]
    } @$ids;
}

sub _add_to_cache {
    my ($self, $cache, $data, $ids) = @_;

    my @entries = $self->_create_cache_entries($data, $ids);
    return unless @entries;

    my $sql = $self->c->sql;
    if ($sql->is_in_transaction) {
        $sql->add_post_txn_callback(sub {
            $self->_add_to_cache_impl($cache, \@entries, $ids);
        });
    } else {
        $self->_add_to_cache_impl($cache, \@entries, $ids);
    }
}

sub _add_to_cache_impl {
    my ($self, $cache, $entries, $ids) = @_;

    $cache->set_multi(@$entries);

    # Check if any entities we've just cached were recently invalidated.
    # If so, delete them. This must be performed after the cache
    # addition, but means there may be *very* brief intervals (between
    # the `set_multi` call above and the `delete_multi` call below) where
    # we return stale entities from the cache.
    my $invalidated_prefix = $self->_recently_invalidated_prefix;
    # Map keys like `MB:artist:recently_invalidated:123` to the entity ID
    # they refer to (`123`).
    my %possible_recently_invalidated_id_map = map {
        my $key = $invalidated_prefix . $_;
        ($key => $_)
    } grep { is_database_row_id($_) } @$ids;
    # Check which of these keys actually exist in our Redis store,
    # indicating which entity IDs were recently-invalidated in the cache.
    my @recently_invalidated_ids = map {
        $possible_recently_invalidated_id_map{$_}
    } keys %{ $self->c->store->get_multi(
        keys %possible_recently_invalidated_id_map,
    ) };
    if (@recently_invalidated_ids) {
        my $cache_prefix = $self->_cache_prefix;
        # Delete the recently-invalidated entity IDs from the cache at
        # their corresponding key locations, e.g., `MB:artist:123`.
        $cache->delete_multi(
            map { $cache_prefix . $_ } @recently_invalidated_ids,
        );
    }
}

sub _delete_from_cache {
    my ($self, @ids) = @_;

    @ids = uniq grep { defined } @ids;
    return unless @ids;

    my $c = $self->c;
    my $cache = $c->cache($self->_type);
    my $cache_prefix = $self->_cache_prefix;

    my $max_request_time = $c->max_request_time;
    if (!defined($max_request_time) || $max_request_time == 0) {
        $max_request_time = $RECENTLY_INVALIDATED_TTL;
    }
    my $invalidated_prefix = $self->_recently_invalidated_prefix;
    my @invalidated_flags = map { $invalidated_prefix . $_ } grep {
        is_database_row_id($_)
    } @ids;
    $c->store->set_multi(map {
        [$_, 1, $max_request_time + 1]
    } @invalidated_flags);

    my @keys = map { $cache_prefix . $_ } @ids;
    my $method = @keys > 1 ? 'delete_multi' : 'delete';
    $cache->$method(@keys);
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky
Copyright (C) 2016 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
