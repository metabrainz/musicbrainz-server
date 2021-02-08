package MusicBrainz::Server::Data::Role::QueryToList;

use strict;
use warnings;

use Digest::MD5 qw( md5 );
use Moose::Role;
use Readonly;

Readonly my $HITS_CACHE_TIMEOUT => 60 * 30; # 30 minutes

sub query_to_list {
    my ($self, $query, $args, $builder) = @_;

    $builder //= $self->can('_new_from_row');

    map {
        $builder->($self, $_)
    } @{ $self->c->sql->select_list_of_hashes($query, @$args) };
}

sub query_to_list_limited {
    my ($self, $query, $args, $limit, $offset, $builder, %opts) = @_;

    my @args = @$args;
    my $arg_count = @args;

    my $hits;
    my $hits_cache_key;
    if ($opts{cache_hits}) {
        # Running count(*) over the entire query for every page is
        # expensive, so we cache the number of hits for 30 minutes if
        # the option is specified. The count doesn't have to be exact,
        # just close enough that we can estimate the number of pages.
        # In all likelihood, the number of pages isn't going to change
        # that often for certain lists unless a large number of
        # entities are added or removed. Other lists, like for voting
        # on edits, are likely to change more frequently.
        $hits_cache_key =
            'query_to_list_limited:' .
            md5(join "\0",
                $query,
                map { ref($_) eq 'ARRAY' ? (@$_) : $_ } @args);
        $hits = $self->c->cache->get($hits_cache_key);
    }

    $builder //= $self->can('_new_from_row');

    if (defined $offset) {
        if ($opts{dollar_placeholders}) {
            $query .= ' OFFSET $' . (++$arg_count);
        } else {
            $query .= ' OFFSET ?';
        }
        push @args, $offset;
    }

    if (!defined $hits) {
        $query = qq{
            WITH x AS ($query)
            SELECT x.*, c.count AS total_row_count
            FROM x, (SELECT count(*) from x) c
        };
    }

    if (defined $limit) {
        if ($opts{dollar_placeholders}) {
            $query .= ' LIMIT $' . (++$arg_count);
        } else {
            $query .= ' LIMIT ?';
        }
        push @args, $limit;
    }

    my $total_row_count;
    my @rows = map {
        my $row = $_;
        $total_row_count = delete $row->{total_row_count};
        $builder->($self, $row);
    } @{$self->c->sql->select_list_of_hashes($query, @args)};

    if (!defined $hits) {
        $hits = ($total_row_count // 0) + ($offset // 0);
        if ($opts{cache_hits}) {
            $self->c->cache->set($hits_cache_key, $hits, $HITS_CACHE_TIMEOUT);
        }
    }

    (\@rows, ($hits // 0));
}

no Moose::Role;

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
