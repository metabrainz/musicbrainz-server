package MusicBrainz::Server::Data::Series;

use Moose;
use namespace::autoclean;
use MusicBrainz::Server::Constants qw( $SERIES_ORDERING_TYPE_AUTOMATIC );
use MusicBrainz::Server::Data::Utils qw(
    generate_gid
    hash_to_row
    type_to_model
    query_to_list_limited
    merge_table_attributes
);
use MusicBrainz::Server::Data::Utils::Cleanup qw( used_in_relationship );
use MusicBrainz::Server::Data::Utils::Uniqueness qw( assert_uniqueness_conserved );
use MusicBrainz::Server::Entity::Series;
use MusicBrainz::Server::Entity::SeriesType;

extends 'MusicBrainz::Server::Data::CoreEntity';
with 'MusicBrainz::Server::Data::Role::Annotation' => { type => 'series' };
with 'MusicBrainz::Server::Data::Role::Name';
with 'MusicBrainz::Server::Data::Role::Browse';
with 'MusicBrainz::Server::Data::Role::Alias' => { type => 'series' };
with 'MusicBrainz::Server::Data::Role::CoreEntityCache' => { prefix => 'series' };
with 'MusicBrainz::Server::Data::Role::Editable' => { table => 'series' };
with 'MusicBrainz::Server::Data::Role::Merge';
with 'MusicBrainz::Server::Data::Role::DeleteAndLog';
with 'MusicBrainz::Server::Data::Role::Subscription' => {
    table => 'editor_subscribe_series',
    column => 'series',
    active_class => 'MusicBrainz::Server::Entity::Subscription::Series',
    deleted_class => 'MusicBrainz::Server::Entity::Subscription::DeletedSeries'
};

sub _table {
    return 'series';
}

sub _columns {
    return 'id, gid, name, comment, type, ordering_attribute, ' .
           'ordering_type, edits_pending, last_updated';
}

sub _column_mapping {
    return {
        id => 'id',
        gid => 'gid',
        name => 'name',
        comment => 'comment',
        type_id => 'type',
        ordering_attribute_id => 'ordering_attribute',
        ordering_type_id => 'ordering_type',
        edits_pending => 'edits_pending',
        last_updated => 'last_updated',
    };
}

sub _id_column {
    return 'series.id';
}

sub _gid_redirect_table {
    return 'series_gid_redirect';
}

sub _entity_class {
    return 'MusicBrainz::Server::Entity::Series';
}

sub _hash_to_row {
    my ($self, $series) = @_;

    my $row = hash_to_row($series, {
        type => 'type_id',
        ordering_attribute => 'ordering_attribute_id',
        ordering_type => 'ordering_type_id',
        name => 'name',
        comment => 'comment',
    });

    return $row;
}

sub _merge_impl {
    my ($self, $new_id, @old_ids) = @_;

    $self->alias->merge($new_id, @old_ids);
    $self->subscription->merge_entities($new_id, @old_ids);
    $self->annotation->merge($new_id, @old_ids);
    $self->c->model('Edit')->merge_entities('series', $new_id, @old_ids);
    $self->c->model('Relationship')->merge_entities('series', $new_id, @old_ids);

    merge_table_attributes(
        $self->sql => (
            table => 'series',
            columns => [ qw( type ) ],
            old_ids => \@old_ids,
            new_id => $new_id
        )
    );

    # FIXME: relationship ordering

    $self->_delete_and_redirect_gids('series', $new_id, @old_ids);

    return 1;
}

sub insert {
    my ($self, @series) = @_;

    my $class = $self->_entity_class;
    my @created;

    for my $series (@series) {
        my $row = $self->_hash_to_row($series);
        $row->{gid} = $series->{gid} || generate_gid();

        my $created = $class->new(
            name => $series->{name},
            id => $self->sql->insert_row('series', $row, 'id'),
            gid => $row->{gid}
        );

        push @created, $created;
    }

    return @series > 1 ? @created : $created[0];
}

sub update {
    my ($self, $series_id, $update) = @_;

    my $row = $self->_hash_to_row($update);

    assert_uniqueness_conserved($self, series => $series_id, $update);

    my $old_ordering_type = $self->sql->select_single_value(
        "SELECT ordering_type FROM series WHERE id = ?", $series_id
    );

    $self->sql->update_row('series', $row, { id => $series_id }) if %$row;

    if ($old_ordering_type != $SERIES_ORDERING_TYPE_AUTOMATIC &&
            $row->{ordering_type} == $SERIES_ORDERING_TYPE_AUTOMATIC) {
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

sub get_entities {
    my ($self, $series, $limit, $offset) = @_;

    my $entity_type = $series->type->entity_type;
    my $model = $self->c->model(type_to_model($entity_type));

    my $query = "
      SELECT e.*, es.text_value AS ordering_attribute_value
      FROM (SELECT " . $model->_columns . " FROM " . $model->_table . ") e
      JOIN (SELECT * FROM ${entity_type}_series) es ON e.id = es.$entity_type
      WHERE es.series = ?
      ORDER BY es.link_order, musicbrainz_collate(e.name) ASC
      OFFSET ?";

    my $form_row = sub {
        my $row = shift;
        my $ordering_attribute_value = delete $row->{ordering_attribute_value};

        return {
            entity => $model->_new_from_row($row),
            ordering_attribute_value => $ordering_attribute_value,
        };
    };

    return query_to_list_limited(
        $self->c->sql, $offset, $limit, $form_row, $query, $series->id, $offset || 0
    );
}

sub find_by_subscribed_editor
{
    my ($self, $editor_id, $limit, $offset) = @_;
    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                    JOIN editor_subscribe_series s ON series.id = s.series
                 WHERE s.editor = ?
                 ORDER BY musicbrainz_collate(series.name), series.id
                 OFFSET ?";
    return query_to_list_limited(
        $self->c->sql, $offset, $limit, sub { $self->_new_from_row(@_) },
        $query, $editor_id, $offset || 0);
}

sub automatically_reorder {
    my ($self, $series_id) = @_;

    return unless $self->c->sql->select_single_value(
        'SELECT true FROM series WHERE id = ? AND ordering_type = ?',
        $series_id, $SERIES_ORDERING_TYPE_AUTOMATIC
    );

    my $entity_type = $self->c->sql->select_single_value('
        SELECT entity_type FROM series_type st
        JOIN series s ON s.type = st.id WHERE s.id = ?',
        $series_id
    );

    my $relationship_table = $entity_type lt "series"
        ? "l_${entity_type}_series" : "l_series_${entity_type}";

    my $pairs = $self->c->sql->select_list_of_hashes("
        SELECT relationship, text_value FROM ${entity_type}_series WHERE series = ?",
        $series_id
    );

    my %relationships_by_text_value = map {
        $_->{text_value} => $_->{relationship}
    } @$pairs;

    my @sorted_values = map { $_->[0] } sort {
        my ($a_parts, $b_parts) = ($a->[1], $b->[1]);

        my $max = @$a_parts <= @$b_parts ? @$a_parts : @$b_parts;
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

    for (my $i = 0; $i < @sorted_values; $i++) {
        push @from_values, "(?, ?)";
        push @from_args, $relationships_by_text_value{$sorted_values[$i]}, $i+1;
    }

    return unless @from_args;

    $self->c->sql->do("
        UPDATE $relationship_table SET link_order = x.link_order::integer
        FROM (VALUES " . join(", ", @from_values) . ") AS x (relationship, link_order)
        WHERE id = x.relationship::integer",
        @from_args
    );
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2014 MetaBrainz Foundation

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
