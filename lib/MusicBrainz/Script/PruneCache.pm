package MusicBrainz::Script::PruneCache;

=head1 DESCRIPTION

This script can be used to clear entities last updated within `interval`
seconds from Redis. It's suitable for running after replication.

=cut

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2016 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

use DateTime::Duration;
use DateTime::Format::Pg;
use DBDefs;
use Moose;
use MusicBrainz::Server::Constants qw( %ENTITIES entities_with );

with 'MooseX::Runnable';
with 'MooseX::Getopt';
with 'MusicBrainz::Script::Role::Context';

has interval => (
    isa => 'Int',
    is => 'ro',
    default => sub { 7200 },
    traits => ['Getopt'],
);

has verbose => (
    isa => 'Bool',
    is => 'ro',
    default => 0,
);

sub prune_entity {
    my ($self, $entity_type) = @_;

    my $entity_properties = $ENTITIES{$entity_type};
    my $data = $self->c->model($entity_properties->{model});
    my $interval = DateTime::Format::Pg->format_interval(
        DateTime::Duration->new(seconds => $self->interval)
    );
    my $cache_prefix = $data->_type;

    Sql::run_in_transaction(sub {
        if ($entity_properties->{last_updated_column}) {
            my $ids = $self->c->sql->select_single_column_array(
                'SELECT ' . $data->_id_column .
                '  FROM ' . $data->_table .
                ' WHERE last_updated >= (now() - interval ?)',
                $interval,
            );
            if (@$ids) {
                if ($self->verbose) {
                    my $count = scalar(@$ids);
                    my $id_string = $count > 1 ? 'ids' : 'id';
                    print "Deleting $count $id_string from $cache_prefix:*\n";
                }
                $data->_delete_from_cache(@$ids);
            }
        }

        if ($data->can('_delete_all_from_cache')) {
            if ($self->verbose) {
                print "Deleting $cache_prefix:all\n";
            }
            $data->_delete_all_from_cache;
        }
    }, $self->c->sql);
}

sub run {
    my ($self) = @_;

    for my $entity_type (entities_with('cache')) {
        $self->prune_entity($entity_type);
    }

    return 0;
}

1;
