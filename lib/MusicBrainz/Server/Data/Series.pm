package MusicBrainz::Server::Data::Series;

use List::AllUtils qw( max );
use Moose;
use namespace::autoclean;
use MusicBrainz::Server::Constants qw(
    $SERIES_ORDERING_TYPE_AUTOMATIC
    $SERIES_ORDERING_ATTRIBUTE
);
use MusicBrainz::Server::Data::Utils qw(
    hash_to_row
    type_to_model
    merge_table_attributes
    load_subobjects
    order_by
);
use MusicBrainz::Server::Data::Utils::Cleanup qw( used_in_relationship );
use MusicBrainz::Server::Data::Utils::Uniqueness qw( assert_uniqueness_conserved );
use MusicBrainz::Server::Entity::Series;
use MusicBrainz::Server::Entity::SeriesType;

extends 'MusicBrainz::Server::Data::CoreEntity';
with 'MusicBrainz::Server::Data::Role::Annotation' => { type => 'series' };
with 'MusicBrainz::Server::Data::Role::Alias' => { type => 'series' };
with 'MusicBrainz::Server::Data::Role::CoreEntityCache';
with 'MusicBrainz::Server::Data::Role::Editable' => { table => 'series' };
with 'MusicBrainz::Server::Data::Role::LinksToEdit' => { table => 'series' };
with 'MusicBrainz::Server::Data::Role::Merge';
with 'MusicBrainz::Server::Data::Role::Tag' => { type => 'series' };
with 'MusicBrainz::Server::Data::Role::DeleteAndLog' => { type => 'series' };
with 'MusicBrainz::Server::Data::Role::Subscription' => {
    table => 'editor_subscribe_series',
    column => 'series',
    active_class => 'MusicBrainz::Server::Entity::Subscription::Series',
    deleted_class => 'MusicBrainz::Server::Entity::Subscription::DeletedSeries'
};
with 'MusicBrainz::Server::Data::Role::Collection';

sub _type { 'series' }

sub _columns {
    return 'series.id, series.gid, series.name, series.comment, ' .
           'series.type, ordering_type, series.edits_pending, series.last_updated';
}

sub _column_mapping {
    return {
        id => 'id',
        gid => 'gid',
        name => 'name',
        unaccented_name => 'unaccented_name',
        comment => 'comment',
        type_id => 'type',
        ordering_type_id => 'ordering_type',
        edits_pending => 'edits_pending',
        last_updated => 'last_updated',
    };
}

sub _id_column {
    return 'series.id';
}

sub _hash_to_row {
    my ($self, $series) = @_;

    my $row = hash_to_row($series, {
        type => 'type_id',
        ordering_type => 'ordering_type_id',
        name => 'name',
        comment => 'comment',
    });

    return $row;
}

sub _order_by {
    my ($self, $order) = @_;
    my $order_by = order_by($order, "name", {
        "name" => sub {
            return "name COLLATE musicbrainz"
        },
        "type" => sub {
            return "type, name COLLATE musicbrainz"
        }
    });

    return $order_by
}

sub _merge_impl {
    my ($self, $new_id, @old_ids) = @_;

    $self->alias->merge($new_id, @old_ids);
    $self->tags->merge($new_id, @old_ids);
    $self->annotation->merge($new_id, @old_ids);
    $self->c->model('Collection')->merge_entities('series', $new_id, @old_ids);
    $self->c->model('Edit')->merge_entities('series', $new_id, @old_ids);
    $self->c->model('Relationship')->merge_entities('series', $new_id, \@old_ids);

    merge_table_attributes(
        $self->sql => (
            table => 'series',
            columns => [ qw( type ) ],
            old_ids => \@old_ids,
            new_id => $new_id
        )
    );

    # FIXME: merge duplicate items (relationships) somehow?

    $self->_delete_and_redirect_gids('series', $new_id, @old_ids);

    my $ordering_type = $self->c->sql->select_single_value(
        'SELECT ordering_type FROM series WHERE id = ?', $new_id
    );

    if ($ordering_type == $SERIES_ORDERING_TYPE_AUTOMATIC) {
        $self->c->model('Series')->automatically_reorder($new_id);
    }

    return 1;
}

sub load
{
    my ($self, @objs) = @_;
    load_subobjects($self, 'series', @objs);
}

sub _insert_hook_prepare {
    my ($self) = @_;
    return {
        ordering_attribute_id => $self->sql->select_single_value(
            'SELECT id FROM link_attribute_type WHERE gid = ?', $SERIES_ORDERING_ATTRIBUTE
        ),
    };
}

around _insert_hook_make_row => sub {
    my ($orig, $self, $entity, $extra_data) = @_;
    my $row = $self->$orig($entity, $extra_data);
    $row->{ordering_attribute} = $extra_data->{ordering_attribute_id};
    return $row;
};

sub update {
    my ($self, $series_id, $update) = @_;

    my $row = $self->_hash_to_row($update);

    assert_uniqueness_conserved($self, series => $series_id, $update);

    my $series = $self->c->model('Series')->get_by_id($series_id);
    $self->c->model('SeriesType')->load($series);

    if (defined($row->{type})) {
        my $existing_entity_type = $series->type->item_entity_type;
        my $new_series_type = $self->c->model('SeriesType')->get_by_id($row->{type});
        my $new_entity_type = $new_series_type->item_entity_type;

        if ($existing_entity_type ne $new_entity_type) {
            my ($items, $hits) = $self->c->model('Series')->get_entities($series, 1, 0);

            die "Cannot change the entity type of a non-empty series" if scalar(@$items);
        }
    }

    $self->sql->update_row('series', $row, { id => $series_id }) if %$row;

    if ($series->ordering_type_id != $SERIES_ORDERING_TYPE_AUTOMATIC &&
            ($row->{ordering_type} // 0) == $SERIES_ORDERING_TYPE_AUTOMATIC) {
        $self->c->model('Series')->automatically_reorder($series_id);
    }

    return 1;
}

sub is_empty {
    my ($self, $series_id) = @_;

    my $used_in_relationship = used_in_relationship($self->c, series => $series_id);
    return $self->sql->select_single_value("SELECT NOT ($used_in_relationship)");
}

sub can_delete { 1 }

sub delete
{
    my ($self, @ids) = @_;
    @ids = grep { $self->can_delete($_) } @ids;

    # No deleting relationship-related stuff because it should probably fail if it's trying to do that
    $self->c->model('Collection')->delete_entities('series', @ids);
    $self->annotation->delete(@ids);
    $self->alias->delete_entities(@ids);
    $self->tags->delete(@ids);
    $self->subscription->delete(@ids);
    $self->remove_gid_redirects(@ids);
    $self->delete_returning_gids(@ids);
    return 1;
}

sub get_entities {
    my ($self, $series, $limit, $offset) = @_;

    my $entity_type = $series->type->item_entity_type;
    my $model = $self->c->model(type_to_model($entity_type));

    my $query = "
      SELECT e.*, es.text_value AS ordering_key
      FROM (SELECT " . $model->_columns . " FROM " . $model->_table . ") e
      JOIN (SELECT * FROM ${entity_type}_series) es ON e.id = es.$entity_type
      WHERE es.series = ?
      ORDER BY es.link_order, e.name COLLATE musicbrainz ASC";

    $model->query_to_list_limited($query, [$series->id], $limit, $offset, sub {
        my ($model, $row) = @_;

        my $ordering_key = delete $row->{ordering_key};
        {
            entity => $model->_new_from_row($row),
            ordering_key => $ordering_key,
        };
    });
}

sub find_by_subscribed_editor
{
    my ($self, $editor_id, $limit, $offset) = @_;
    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                    JOIN editor_subscribe_series s ON series.id = s.series
                 WHERE s.editor = ?
                 ORDER BY series.name COLLATE musicbrainz, series.id";
    $self->query_to_list_limited($query, [$editor_id], $limit, $offset);
}

sub automatically_reorder {
    my ($self, $series_id) = @_;

    return unless $self->c->sql->select_single_value(
        'SELECT TRUE FROM series WHERE id = ? AND ordering_type = ?',
        $series_id, $SERIES_ORDERING_TYPE_AUTOMATIC
    );

    my $entity_type = $self->c->sql->select_single_value('
        SELECT entity_type FROM series_type st
        JOIN series s ON s.type = st.id WHERE s.id = ?',
        $series_id
    );

    my $type0 = $entity_type lt 'series' ? $entity_type : 'series';
    my $type1 = $entity_type lt 'series' ? 'series' : $entity_type;
    my $target_prop = $type0 eq 'series' ? 'entity1' : 'entity0';

    my $series_items = $self->c->sql->select_list_of_hashes("
        SELECT relationship, link_order, text_value
          FROM ${entity_type}_series
         WHERE series = ?",
        $series_id
    );
    return unless @$series_items;

    my $relationships = $self->c->model('Relationship')->get_by_ids(
        $type0,
        $type1,
        map { $_->{relationship} } @$series_items
    );
    my @relationships = values %$relationships;
    $self->c->model('Link')->load(@relationships);
    $self->c->model('LinkType')->load(map { $_->link } @relationships);
    $self->c->model('Relationship')->load_entities(@relationships);

    my %relationships_by_text_value;
    my %relationships_by_link_order;
    for my $item (@$series_items) {
        my $relationship = $relationships->{$item->{relationship}};
        push @{ $relationships_by_text_value{$item->{text_value}} }, $relationship;
        push @{ $relationships_by_link_order{$item->{link_order}} }, $relationship;
    }

    my @sorted_values = map { $_->[0] } sort {
        my ($a_parts, $b_parts) = ($a->[1], $b->[1]);

        my $max = max(scalar @$a_parts, scalar @$b_parts);
        my $order = 0;

        # Use <= and replace undef values with the empty string, so that
        # A1 sorts before A1B1.
        for (my $i = 0; $i <= $max; $i++) {
            my ($a_part, $b_part) = ($a_parts->[$i] // '', $b_parts->[$i] // '');

            my ($a_num, $b_num) = map { $_ =~ /^\d+$/ } ($a_part, $b_part);

            $order = $a_num && $b_num ? ($a_part <=> $b_part) : ($a_part cmp $b_part);
            last if $order;
        }

        $order;
    } map { [$_, [split /(\d+)/, $_]] } keys %relationships_by_text_value;

    my @from_args;
    my @from_values;
    my $link_order = 1;
    my $prev_text_value = '';
    my $target_model = $self->c->model(type_to_model($entity_type));
    my $target_ordering = sub { 0 };

    if ($target_model->can('series_ordering')) {
        $target_ordering = sub { $target_model->series_ordering(@_) };
    }

    my $item_ordering = sub {
        my ($a, $b) = @_;

        $a->link->begin_date <=> $b->link->begin_date ||
        $a->link->end_date <=> $b->link->end_date ||
        $target_ordering->($a, $b) ||
        $a->$target_prop->name cmp $b->$target_prop->name
    };

    for my $text_value (@sorted_values) {
        # for each group of relationships with the same text attribute value,
        # sort by begin/end date.
        my @group = sort { $item_ordering->($a, $b) } @{ $relationships_by_text_value{$text_value} };

        my $prev_relationship;
        for my $relationship (@group) {
            # increment link_order when the item sort order changes
            if ($prev_relationship && $item_ordering->($prev_relationship, $relationship)) {
                $link_order++;
            }

            my ($conflicting_relationship) = grep {
                $_->$target_prop->id == $relationship->$target_prop->id
            } @{ $relationships_by_link_order{$link_order} // [] };

            unless ($conflicting_relationship) {
                push @from_values, "(?, ?)";
                push @from_args, $relationship->id, $link_order;
                push @{$relationships_by_link_order{$link_order}}, $relationship;
            }

            $prev_relationship = $relationship;
        }

        # increment link_order when the text value changes
        if ($text_value ne $prev_text_value) {
            $link_order++;
            $prev_text_value = $text_value;
        }
    }

    return unless @from_args;

    $self->c->sql->do("
        UPDATE l_${type0}_${type1} SET link_order = x.link_order::integer
        FROM (VALUES " . join(", ", @from_values) . ") AS x (relationship, link_order)
        WHERE id = x.relationship::integer",
        @from_args
    );
}

sub reorder_for_entities {
    my ($self, $type, @ids) = @_;

    my $series = $self->sql->select_single_column_array(
        "SELECT DISTINCT series FROM ${type}_series WHERE $type = any(?)", \@ids
    );

    $self->automatically_reorder($_) for @$series;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
