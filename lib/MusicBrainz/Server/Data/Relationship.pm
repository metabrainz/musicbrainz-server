package MusicBrainz::Server::Data::Relationship;

use Moose;
use namespace::autoclean;
use Readonly;
use Sql;
use Carp qw( carp croak );
use MusicBrainz::Server::Entity::Relationship;
use MusicBrainz::Server::Data::Artist;
use MusicBrainz::Server::Data::Area;
use MusicBrainz::Server::Data::Instrument;
use MusicBrainz::Server::Data::Label;
use MusicBrainz::Server::Data::Link;
use MusicBrainz::Server::Data::LinkType;
use MusicBrainz::Server::Data::Place;
use MusicBrainz::Server::Data::Recording;
use MusicBrainz::Server::Data::ReleaseGroup;
use MusicBrainz::Server::Data::URL;
use MusicBrainz::Server::Data::Work;
use MusicBrainz::Server::Data::Utils qw(
    placeholders
    ref_to_type
    type_to_model
);
use Scalar::Util 'weaken';

no if $] >= 5.018, warnings => "experimental::smartmatch";

extends 'MusicBrainz::Server::Data::Entity';

Readonly my @TYPES => qw(
    area
    artist
    instrument
    label
    place
    recording
    release
    release_group
    series
    url
    work
);

my %TYPES = map { $_ => 1} @TYPES;

sub all_link_types
{
    return @TYPES;
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::Relationship';
}

sub _new_from_row
{
    my ($self, $row, $obj, $matching_entity_type) = @_;
    my $entity0 = $row->{entity0};
    my $entity1 = $row->{entity1};
    my %info = (
        id => $row->{id},
        link_id => $row->{link},
        edits_pending => $row->{edits_pending},
        entity0_id => $entity0,
        entity1_id => $entity1,
        last_updated => $row->{last_updated},
        link_order => $row->{link_order},
    );

    my $weaken;
    if (defined $obj) {
        if ($matching_entity_type == 0 && $entity0 == $obj->id) {
            $weaken = 'entity0';
            $info{entity0} = $obj;
            $info{direction} = $MusicBrainz::Server::Entity::Relationship::DIRECTION_FORWARD;
        }
        elsif ($matching_entity_type == 1 && $entity1 == $obj->id) {
            $weaken = 'entity1';
            $info{entity1} = $obj;
            $info{direction} = $MusicBrainz::Server::Entity::Relationship::DIRECTION_BACKWARD;
        }
        else {
            carp "Neither relationship end-point matched the object.";
        }
    }

    my $rel = MusicBrainz::Server::Entity::Relationship->new(%info);
    # XXX MASSIVE MASSIVE HACK.
    weaken($rel->{$weaken}) if $obj;

    return $rel;
}

sub _check_types
{
    my ($self, $type0, $type1) = @_;

    croak 'Invalid types'
        unless exists $TYPES{$type0} && exists $TYPES{$type1} && $type0 le $type1;
}

sub get_by_id
{
    my ($self, $type0, $type1, $id) = @_;
    $self->_check_types($type0, $type1);

    my $query = "SELECT * FROM l_${type0}_${type1} WHERE id = ?";
    my $row = $self->sql->select_single_row_hash($query, $id)
        or return undef;

    return $self->_new_from_row($row);
}

sub get_by_ids
{
    my ($self, $type0, $type1, @ids) = @_;
    $self->_check_types($type0, $type1);

    my $query = "SELECT * FROM l_${type0}_${type1} WHERE id IN (" . placeholders(@ids) . ")";
    my $rows = $self->sql->select_list_of_hashes($query, @ids) or return undef;

    return { map { $_->{id} => $self->_new_from_row($_) } @$rows };
}

sub _load
{
    my ($self, $type, $target_types, @objs) = @_;
    my @target_types = @$target_types;
    my @types = map { [ sort($type, $_) ] } @target_types;
    my @rels;
    foreach my $t (@types) {
        my $target_type = $type eq $t->[0] ? $t->[1] : $t->[0];
        my %objs_by_id = map { $_->id => $_ }
            grep { @{ $_->relationships_by_type($target_type) } == 0 } @objs;
        my @ids = keys %objs_by_id;
        next unless @ids;

        my $type0 = $t->[0];
        my $type1 = $t->[1];
        my (@cond, @params, $target, $target_id, $query);
        if ($type eq $type0) {
            push @cond, "entity0 IN (" . placeholders(@ids) . ")";
            push @params, @ids;
            $target = $type1;
            $target_id = 'entity1';
        }
        if ($type eq $type1) {
            push @cond, "entity1 IN (" . placeholders(@ids) . ")";
            push @params, @ids;
            $target = $type0;
            $target_id = 'entity0';
        }

        my $select = "l_${type0}_${type1}.* FROM l_${type0}_${type1}
                      JOIN link l ON link = l.id";
        my $order = 'l.begin_date_year, l.begin_date_month, l.begin_date_day,
                     l.end_date_year,   l.end_date_month,   l.end_date_day,
                     l.ended';

        if ($target eq 'url') {
            $query = "
            SELECT $select
              JOIN $target ON $target_id = ${target}.id
            WHERE " . join(" OR ", @cond) . "
            ORDER BY $order, url";
        } else {
            $query = "
            SELECT $select
              JOIN $target ON $target_id = ${target}.id
            WHERE " . join(" OR ", @cond) . "
            ORDER BY $order, musicbrainz_collate(name)";
        }

        for my $row (@{ $self->sql->select_list_of_hashes($query, @params) }) {
            my $entity0 = $row->{entity0};
            my $entity1 = $row->{entity1};
            if ($type eq $type0 && exists $objs_by_id{$entity0}) {
                my $obj = $objs_by_id{$entity0};
                my $rel = $self->_new_from_row($row, $obj, 0);
                $obj->add_relationship($rel);
                push @rels, $rel;
            }
            if ($type eq $type1 && exists $objs_by_id{$entity1}) {
                my $obj = $objs_by_id{$entity1};
                my $rel = $self->_new_from_row($row, $obj, 1);
                $obj->add_relationship($rel);
                push @rels, $rel;
            }
        }
    }
    return @rels;
}

sub load_entities
{
    my ($self, @rels) = @_;
    my %ids_by_type;
    foreach my $rel (@rels) {
        if ($rel->entity0_id && !defined($rel->entity0)) {
            my $type = $rel->link->type->entity0_type;
            $ids_by_type{$type} = [] if !exists($ids_by_type{$type});
            push @{$ids_by_type{$type}}, $rel->entity0_id;
        }
        if ($rel->entity1_id && !defined($rel->entity1)) {
            my $type = $rel->link->type->entity1_type;
            $ids_by_type{$type} = [] if !exists($ids_by_type{$type});
            push @{$ids_by_type{$type}}, $rel->entity1_id;
        }
    }

    my %data_by_type;
    foreach my $type (keys %ids_by_type) {
        my @ids = @{$ids_by_type{$type}};
        $data_by_type{$type} =
            $self->c->model(type_to_model($type))->get_by_ids(@ids);
    }

    foreach my $rel (@rels) {
        if ($rel->entity0_id && !defined($rel->entity0)) {
            my $type = $rel->link->type->entity0_type;
            my $obj = $data_by_type{$type}->{$rel->entity0_id};
            $rel->entity0($obj) if defined($obj);
        }
        if ($rel->entity1_id && !defined($rel->entity1)) {
            my $type = $rel->link->type->entity1_type;
            my $obj = $data_by_type{$type}->{$rel->entity1_id};
            $rel->entity1($obj) if defined($obj);
        }
    }

    my @load_ac = grep { $_->meta->find_method_by_name('artist_credit') } map { values %$_ } values %data_by_type;
    $self->c->model('ArtistCredit')->load(@load_ac);

    my @places = values %{$data_by_type{'place'}};
    my @areas = values %{$data_by_type{'area'}};
    $self->c->model('Area')->load(@places);
    $self->c->model('Area')->load_containment(@areas, map { $_->area } @places);
}

sub load_subset
{
    my ($self, $types, @objs) = @_;
    my %objs_by_type;
    return unless @objs; # nothing to do
    foreach my $obj (@objs) {
        if (my $type = ref_to_type($obj)) {
            $objs_by_type{$type} = [] if !exists($objs_by_type{$type});
            push @{$objs_by_type{$type}}, $obj;
        }
    }

    my @rels;
    foreach my $type (keys %objs_by_type) {
        push @rels, $self->_load($type, $types, @{$objs_by_type{$type}});
    }

    $self->c->model('Link')->load(@rels);
    $self->c->model('LinkType')->load(map { $_->link } @rels);
    $self->load_entities(@rels);

    return @rels;
}

sub load
{
    my ($self, @objs) = @_;
    return $self->load_subset(\@TYPES, @objs);
}

sub _generate_table_list
{
    my ($type, @end_types) = @_;
    # Generate a list of all possible type combinations
    my @types;
    @end_types = @TYPES unless @end_types;
    foreach my $t (@end_types) {
        if ($type le $t) {
            push @types, ["l_${type}_${t}", 'entity0', 'entity1'];
        }
        if ($type ge $t) {
            push @types, ["l_${t}_${type}", 'entity1', 'entity0'];
        }
    }
    return @types;
}

sub all_pairs
{
    my $self = shift;

    # Generate a list of all possible type combinations
    my @all;
    for my $l0 (@TYPES) {
        for my $l1 (@TYPES) {
            next if $l1 lt $l0;
            push @all, [ $l0, $l1 ];
        }
    }
    return @all;
}

sub merge_entities
{
    my ($self, $type, $target_id, @source_ids) = @_;

    # Delete relationships where the start is the same as the end
    # (after merging)
    my @ids = ($target_id, @source_ids);
    $self->sql->do(
        "DELETE FROM l_${type}_${type} WHERE
             (entity0 IN (" . placeholders(@ids) . ')
          AND entity1 IN (' . placeholders(@ids) . '))',
        @ids, @ids);

    foreach my $t (_generate_table_list($type)) {
        my ($table, $entity0, $entity1) = @$t;

        # First, MBS-3669:
        # Delete relationships where:
        # a.) there is no date set (no begin or end date, and the ended flag is off), and
        # b.) there is no relationship on the same pre-merge entity which
        #     *does* have a date, since this indicates the quasi-duplication
        #     may be intentional
        $self->sql->do("
        DELETE FROM $table WHERE id IN (
            SELECT id
            FROM (
              SELECT
                a.id, $entity0, rank()
                  OVER (
                    PARTITION BY $entity1, link_type, attributes, text_values
                    ORDER BY (begin_date_year IS NULL AND begin_date_month IS NULL AND begin_date_day IS NULL AND
                              end_date_year IS NULL AND end_date_month IS NULL AND end_date_day IS NULL AND NOT ended) ASC
                  ) > 1 AS redundant
              FROM (
                SELECT id, link, entity0, entity1, array_agg(attribute_type ORDER BY attribute_type) attributes,
                       array_agg(row(attribute_type, text_value) ORDER BY attribute_type, text_value) text_values
                FROM $table
                LEFT JOIN link_attribute la USING (link)
                LEFT JOIN link_attribute_text_value USING (link, attribute_type)
                WHERE $entity0 IN (" .placeholders($target_id, @source_ids) .")
                GROUP BY id, link, entity0, entity1
              ) a
              JOIN link ON (link.id = a.link)
            ) b
            WHERE redundant
              AND NOT EXISTS (SELECT TRUE FROM $table same_entity_dated JOIN link ON same_entity_dated.link = link.id
                                         WHERE (begin_date_year IS NOT NULL OR begin_date_month IS NOT NULL OR begin_date_day IS NOT NULL OR
                                                end_date_year IS NOT NULL OR end_date_month IS NOT NULL OR end_date_day IS NOT NULL OR
                                                ended)
                                           AND same_entity_dated.$entity0 = b.$entity0
                                           AND same_entity_dated.id <> b.id)
        )", $target_id, @source_ids);
        # Having deleted those duplicates, continue with merging by link ID

        # We want to keep a single row for each link type, and foreign entity.
        $self->sql->do(
            "DELETE FROM $table
            WHERE $entity0 IN (" . placeholders($target_id, @source_ids) . ")
              AND id NOT IN (
                  SELECT DISTINCT ON ($entity1, link) id
                    FROM $table
                   WHERE $entity0 IN (" . placeholders($target_id, @source_ids) . ")
              )",
            $target_id, @source_ids, $target_id, @source_ids
        );

        # Move all remaining relationships
        $self->sql->do("
            UPDATE $table SET $entity0 = ?
            WHERE $entity0 IN (" . placeholders($target_id, @source_ids) . ")
        ", $target_id, $target_id, @source_ids);
    }
}

sub delete_entities
{
    my ($self, $type, @ids) = @_;

    foreach my $t (_generate_table_list($type)) {
        my ($table, $entity0, $entity1) = @$t;
        $self->sql->do("
            DELETE FROM $table a
            WHERE $entity0 IN (" . placeholders(@ids) . ")
        ", @ids);
    }
}

sub exists
{
    my ($self, $type0, $type1, $values) = @_;
    $self->_check_types($type0, $type1);
    return $self->sql->select_single_value(
        "SELECT 1 FROM l_${type0}_${type1}
          WHERE entity0 = ? AND entity1 = ? AND link = ?",
        $values->{entity0_id}, $values->{entity1_id},
        $self->c->model('Link')->find({
            link_type_id => $values->{link_type_id},
            begin_date => $values->{begin_date},
            end_date => $values->{end_date},
            ended => $values->{ended},
            attributes => $values->{attributes},
            attribute_text_values => $values->{attribute_text_values},
        })
    );
}

sub _check_series_type {
    my ($self, $series_id, $link_type_id, $entity_type) = @_;

    my $link_type = $self->c->model('LinkType')->get_by_id($link_type_id);
    return if $link_type->orderable_direction == 0;

    my $series = $self->c->model('Series')->get_by_id($series_id);
    $self->c->model('SeriesType')->load($series);

    if ($series->type->entity_type ne $entity_type) {
        die "Incorrect entity type for part of series relationship";
    }
}

sub insert
{
    my ($self, $type0, $type1, $values) = @_;
    $self->_check_types($type0, $type1);

    $self->_check_series_type($values->{entity0_id}, $values->{link_type_id}, $type1) if $type0 eq "series";
    $self->_check_series_type($values->{entity1_id}, $values->{link_type_id}, $type0) if $type1 eq "series";

    my $row = {
        link => $self->c->model('Link')->find_or_insert({
            link_type_id => $values->{link_type_id},
            begin_date => $values->{begin_date},
            end_date => $values->{end_date},
            ended => $values->{ended},
            attributes => $values->{attributes},
            attribute_text_values => $values->{attribute_text_values},
        }),
        entity0 => $values->{entity0_id},
        entity1 => $values->{entity1_id},
    };
    my $id = $self->sql->insert_row("l_${type0}_${type1}", $row, 'id');

    if ($type0 eq "series") {
        $self->c->model('Series')->automatically_reorder($values->{entity0_id});
    }

    if ($type1 eq "series") {
        $self->c->model('Series')->automatically_reorder($values->{entity1_id});
    }

    return $self->_entity_class->new( id => $id );
}

sub update
{
    my ($self, $type0, $type1, $id, $values) = @_;
    $self->_check_types($type0, $type1);

    my %link = map {
        $_ => $values->{$_};
    } qw( link_type_id begin_date end_date attributes ended attribute_text_values );

    my $old = $self->sql->select_single_row_hash(
        "SELECT link, entity0, entity1 FROM l_${type0}_${type1} WHERE id = ?", $id
    );

    my $new = {};
    $new->{entity0} = $values->{entity0_id} if $values->{entity0_id};
    $new->{entity1} = $values->{entity1_id} if $values->{entity1_id};

    my $series0 = $type0 eq "series";
    my $series1 = $type1 eq "series";
    my $series0_changed = $series0 && $new->{entity0} && $old->{entity0} != $new->{entity0};
    my $series1_changed = $series1 && $new->{entity1} && $old->{entity1} != $new->{entity1};

    $self->_check_series_type($new->{entity0}, $link{link_type_id}, $type1) if $series0_changed;
    $self->_check_series_type($new->{entity1}, $link{link_type_id}, $type0) if $series1_changed;

    $new->{link} = $self->c->model('Link')->find_or_insert(\%link);
    $self->sql->update_row("l_${type0}_${type1}", $new, { id => $id });

    $self->c->model('Series')->automatically_reorder($old->{entity0}) if $series0_changed;
    $self->c->model('Series')->automatically_reorder($old->{entity1}) if $series1_changed;

    $self->c->model('Series')->automatically_reorder($new->{entity0})
        if $series0_changed || ($series0 && $old->{link} != $new->{link});

    $self->c->model('Series')->automatically_reorder($new->{entity1})
        if $series1_changed || ($series1 && $old->{link} != $new->{link});
}

sub delete
{
    my ($self, $type0, $type1, @ids) = @_;
    $self->_check_types($type0, $type1);

    my $series_col;
    $series_col = "entity0" if $type0 eq "series";
    $series_col = "entity1" if $type1 eq "series";

    my $series_ids = $self->sql->select_list_of_hashes(
        "SELECT $series_col FROM l_${type0}_${type1} WHERE id = any(?)", \@ids
    ) if $series_col;

    $self->sql->do("DELETE FROM l_${type0}_${type1}
                    WHERE id IN (" . placeholders(@ids) . ")", @ids);

    if ($series_ids) {
        $self->c->model('Series')->automatically_reorder($_)
            for map { $_->{$series_col} } @$series_ids;
    }
}

sub adjust_edit_pending
{
    my ($self, $type0, $type1, $adjust, @ids) = @_;
    $self->_check_types($type0, $type1);

    my $query = "UPDATE l_${type0}_${type1}
                 SET edits_pending = numeric_larger(0, edits_pending + ?)
                 WHERE id IN (" . placeholders(@ids) . ")";
    $self->sql->do($query, $adjust, @ids);
}

sub reorder {
    my ($self, $type0, $type1, %ordering) = @_;

    my @ids = keys %ordering;

    # Given a list of relationship ids, extract their unordered entities
    # (i.e. a series is unordered, its releases are), plus the link_type ids
    # they use.
    #
    # Then select *all* relationships that use any of those (entity, link_type)
    # pairs in a relationship, which gives us are orderable groups.
    #
    # If more than one group is returned, something is wrong, since this
    # function is only intended to be able to order one group.

    my $groups = $self->sql->select_list_of_hashes(
        "SELECT DISTINCT (CASE WHEN olt.direction = 1
                               THEN r.entity0
                               ELSE r.entity1 END) AS source,
                         lt.id AS link_type
         FROM l_${type0}_${type1} r
         JOIN link l ON l.id = r.link
         JOIN link_type lt ON lt.id = l.link_type
         JOIN orderable_link_type olt ON olt.link_type = lt.id
         WHERE r.id = any(?)",
        \@ids
    );

    die "Can only reorder one group of relationships" if @$groups != 1;

    $self->sql->do(
        "WITH pos (relationship, link_order) AS (
            VALUES " . join(', ', ('(?::INTEGER, ?::INTEGER)') x @ids) . "
        )
        UPDATE l_${type0}_${type1} SET link_order = pos.link_order
        FROM pos WHERE pos.relationship = id",
        %ordering
    );
}

=method lock_and_do

Lock the corresponding relationship table for $type0-$type in ROW EXCLUSIVE
mode, and run a block of code.

=cut

sub lock_and_do {
    my ($self, $type0, $type1, $code) = @_;

    my ($t0, $t1) = sort($type0, $type1);
    Sql::run_in_transaction(sub {
        $code->();
    }, $self->c->sql);
}

=method editor_can_edit

Returns true if the editor is allowed to edit a $type0-$type1 rel

=cut

sub editor_can_edit
{
    my ($self, $editor, $type0, $type1) = @_;

    return 0 unless $editor;

    my $type = join "_", sort($type0, $type1);
    if ($type ~~ [qw(area_area area_url)]) {
        return $editor->is_location_editor;
    } elsif ($type ~~ [qw(area_instrument instrument_instrument instrument_url)]) {
        return $editor->is_relationship_editor;
    } else {
        return 1;
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 NAME

MusicBrainz::Server::Data::Relationship

=head1 COPYRIGHT

Copyright (C) 2009 Lukas Lalinsky

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
