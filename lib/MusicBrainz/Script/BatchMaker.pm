package MusicBrainz::Script::BatchMaker;

use Moose;

has entity_table => (
    is => 'ro',
    isa => 'Str',
    required => 1,
);

has batch_size => (
    is => 'ro',
    isa => 'Int',
    required => 1,
);

has c => (
    handles => ['sql'],
    is => 'ro',
    isa => 'MusicBrainz::Server::Context',
    required => 1,
);

=head2 get_batch_info

Takes an entity table name and figures out how to divide the table into
batches, where each batch contains no more than `batch_size` ids.

=cut

sub get_batch_info {
    my ($self) = @_;

    my @batches;
    my $entity_table = $self->entity_table;

    # Find the counts in each potential batch of `batch_size`.
    my $raw_batches = $self->sql->select_list_of_hashes(
        qq{SELECT batch, count(id)
             FROM (SELECT id, ceil(id / ?::float) AS batch
                     FROM $entity_table) q
            GROUP BY batch
            ORDER BY batch ASC},
        $self->batch_size,
    );

    return \@batches unless @{$raw_batches};

    # Exclude the last batch, which should always be its own sitemap.
    #
    # Since sitemaps do a bit of a bundling thing to reach as close to 50,000
    # URLs as possible, it'd be possible that right after a rollover past
    # 50,000 IDs, the new one would be folded into the otherwise-most-recent
    # batch. Since the goal is that each URL only ever starts in its actual
    # batch number and then moves down over time, this ensures that the last
    # batch is always its own sitemap, even if it's few enough it could
    # theoretically be part of the previous one.

    if (scalar @$raw_batches > 1) {
        my $batch = {batches => [], count => 0};
        for my $raw_batch (@{ $raw_batches }[0..scalar @$raw_batches-2]) {
            # Add this potential batch to the previous one if the sum will
            # come out less than `batch_size`. Otherwise create a new batch
            # and push the previous one onto the list.
            if ($batch->{count} + $raw_batch->{count} <= $self->batch_size) {
                $batch->{count} += $raw_batch->{count};
                push @{$batch->{batches}}, $raw_batch->{batch};
            } else {
                push @batches, $batch;
                $batch = {
                    batches => [$raw_batch->{batch}],
                    count => $raw_batch->{count},
                };
            }
        }
        push @batches, $batch;
    }

    # Add last batch.
    my $last_batch = $raw_batches->[scalar @$raw_batches - 1];
    push @batches, {
        batches => [$last_batch->{batch}],
        count => $last_batch->{count},
    };

    return \@batches;
}

sub get_batch {
    my ($self, $batch_info, $sql) = @_;

    my @columns = @{$sql->{columns} // []};
    die unless @columns;

    my $entity_table = $self->entity_table;
    my $columns = join q(, ), @columns;
    my $tables = $entity_table . ($sql->{join} ? ' ' . $sql->{join} : '');
    my $conditions =
        "ceil($entity_table.id / ?::float) = any(?)" .
        ($sql->{conditions} ? ' AND (' . $sql->{conditions} . ')' : '');

    my $query =
        qq{SELECT $columns
             FROM $tables
            WHERE $conditions};

    return $self->sql->select_list_of_hashes(
        $query,
        $self->batch_size,
        $batch_info->{batches},
    );
}

no Moose;

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014-2017 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
