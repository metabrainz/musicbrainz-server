package MusicBrainz::Server::Data::Relationship;

use Moose;
use namespace::autoclean -also => [qw( _generate_table_list )];
use Readonly;
use Sql;
use Carp qw( carp croak );
use MusicBrainz::Server::Entity::Relationship;
use MusicBrainz::Server::Data::Artist;
use MusicBrainz::Server::Data::Area;
use MusicBrainz::Server::Data::Label;
use MusicBrainz::Server::Data::Link;
use MusicBrainz::Server::Data::LinkType;
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

extends 'MusicBrainz::Server::Data::Entity';

Readonly my @TYPES => qw(
    area
    artist
    label
    recording
    release
    release_group
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
        last_updated => $row->{last_updated}
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
        } elsif ($target eq 'area') {
            $query = "
            SELECT $select
              JOIN $target ON $target_id = ${target}.id
            WHERE " . join(" OR ", @cond) . "
            ORDER BY $order, musicbrainz_collate(name)";
        } else {
            my $name_table =
                $target eq 'recording'     ? 'track_name'   :
                $target eq 'release_group' ? 'release_name' :
                                             "${target}_name";
            $query = "
            SELECT $select
              JOIN $target ON $target_id = ${target}.id
              JOIN $name_table name ON name.id = ${target}.name
            WHERE " . join(" OR ", @cond) . "
            ORDER BY $order, musicbrainz_collate(name.name)";
        }

        $self->sql->select($query, @params);
        while (1) {
            my $row = $self->sql->next_row_hash_ref or last;
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
        $self->sql->finish;
    }
    return @rels;
}

sub load_entities
{
    my ($self, @rels) = @_;
    my %ids_by_type;
    foreach my $rel (@rels) {
        my $linktype = $rel->link->type->name;
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
                    PARTITION BY $entity1, link_type, attributes
                    ORDER BY (begin_date_year IS NULL AND begin_date_month IS NULL AND begin_date_day IS NULL AND
                              end_date_year IS NULL AND end_date_month IS NULL AND end_date_day IS NULL AND NOT ended) ASC
                  ) > 1 AS redundant
              FROM (
                SELECT id, link, entity0, entity1, array_agg(attribute_type ORDER BY attribute_type) attributes
                FROM $table
                LEFT JOIN link_attribute USING (link)
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
        })
    );
}

sub insert
{
    my ($self, $type0, $type1, $values) = @_;
    $self->_check_types($type0, $type1);

    my $row = {
        link => $self->c->model('Link')->find_or_insert({
            link_type_id => $values->{link_type_id},
            begin_date => $values->{begin_date},
            end_date => $values->{end_date},
            ended => $values->{ended},
            attributes => $values->{attributes},
        }),
        entity0 => $values->{entity0_id},
        entity1 => $values->{entity1_id},
    };
    my $id = $self->sql->insert_row("l_${type0}_${type1}", $row, 'id');

    return $self->_entity_class->new( id => $id );
}

sub update
{
    my ($self, $type0, $type1, $id, $values) = @_;
    $self->_check_types($type0, $type1);

    my %link = map {
        $_ => $values->{$_};
    } qw( link_type_id begin_date end_date attributes ended );

    my $row = {};
    $row->{link} = $self->c->model('Link')->find_or_insert(\%link);
    $row->{entity0} = $values->{entity0_id} if $values->{entity0_id};
    $row->{entity1} = $values->{entity1_id} if $values->{entity1_id};

    $self->sql->update_row("l_${type0}_${type1}", $row, { id => $id });
}

sub delete
{
    my ($self, $type0, $type1, @ids) = @_;
    $self->_check_types($type0, $type1);

    $self->sql->do("DELETE FROM l_${type0}_${type1}
              WHERE id IN (" . placeholders(@ids) . ")", @ids);
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

=method lock_and_do

Lock the corresponding relationship table for $type0-$type in ROW EXCLUSIVE
mode, and run a block of code.

=cut

sub lock_and_do {
    my ($self, $type0, $type1, $code) = @_;

    my ($t0, $t1) = sort ($type0, $type1);
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
    my @types = sort ($type0, $type1);
    my $is_area_url = $types[0] eq 'area' && $types[1] eq 'url';
    my $is_area_area = $types[0] eq 'area' && $types[1] eq 'area';
    return (!$is_area_url && !$is_area_area) || $editor->is_location_editor;
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
