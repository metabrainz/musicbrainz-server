package MusicBrainz::Server::Data::Role::QueryToList;

use strict;
use warnings;

use Moose::Role;

sub query_to_list {
    my ($self, $query, $args, $builder) = @_;

    $builder //= $self->can('_new_from_row');

    map {
        $builder->($self, $_)
    } @{ $self->c->sql->select_list_of_hashes($query, @$args) };
}

sub query_to_list_limited {
    my ($self, $query, $args, $limit, $offset, $builder, %opts) = @_;

    $builder //= $self->can('_new_from_row');

    my @args = @$args;
    my $count = @args;

    if (defined $offset) {
        if ($opts{dollar_placeholders}) {
            $query .= ' OFFSET $' . (++$count);
        } else {
            $query .= ' OFFSET ?';
        }
        push @args, $offset;
    }

    my $wrapping_query = qq{
        WITH x AS ($query)
        SELECT x.*, c.count AS total_row_count
        FROM x, (SELECT count(*) from x) c
    };

    if (defined $limit) {
        if ($opts{dollar_placeholders}) {
            $wrapping_query .= ' LIMIT $' . (++$count);
        } else {
            $wrapping_query .= ' LIMIT ?';
        }
        push @args, $limit;
    }

    my $hits = 0;
    my @rows = map {
        $hits = delete $_->{total_row_count};
        $builder->($self, $_);
    } @{$self->c->sql->select_list_of_hashes($wrapping_query, @args)};

    $hits += ($offset // 0);

    (\@rows, $hits);
}

no Moose::Role;

1;

=head1 COPYRIGHT

This file is part of MusicBrainz, the open internet music database.
Copyright (C) 2015 MetaBrainz Foundation
Licensed under the GPL version 2, or (at your option) any later version:
http://www.gnu.org/licenses/gpl-2.0.txt

=cut
