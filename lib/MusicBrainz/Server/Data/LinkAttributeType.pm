package MusicBrainz::Server::Data::LinkAttributeType;

use Moose;
use namespace::autoclean;
use Sql;
use Encode;
use List::MoreUtils qw( uniq );
use MusicBrainz::Server::Entity::LinkType;
use MusicBrainz::Server::Entity::LinkAttributeType;
use MusicBrainz::Server::Data::Utils qw(
    load_subobjects
    hash_to_row
    generate_gid
    placeholders
    non_empty
);

extends 'MusicBrainz::Server::Data::Entity';
with 'MusicBrainz::Server::Data::Role::EntityCache';
with 'MusicBrainz::Server::Data::Role::GetByGID';
with 'MusicBrainz::Server::Data::Role::OptionsTree';

sub _type { 'link_attribute_type' }

sub _table
{
    return 'link_attribute_type ' .
        'LEFT JOIN (' .
            'SELECT id AS root_id, gid AS root_gid, name AS root_name ' .
            'FROM link_attribute_type' .
        ') AS lat_root ON lat_root.root_id = link_attribute_type.root ' .
        'LEFT JOIN (' .
            'SELECT id AS parent_id, gid AS parent_gid, name AS parent_name ' .
            'FROM link_attribute_type' .
        ') AS lat_parent ON lat_parent.parent_id = link_attribute_type.parent ' .
        'LEFT JOIN (' .
            'SELECT instrument.gid AS instrument_gid, ' .
                'instrument.comment AS instrument_comment, ' .
                'instrument_type.id AS instrument_type_id, ' .
                'instrument_type.name AS instrument_type_name ' .
            'FROM instrument ' .
            'LEFT JOIN instrument_type ON instrument.type = instrument_type.id' .
        ') AS ins ON ins.instrument_gid = link_attribute_type.gid';
}

sub _columns
{
    return 'id, parent, child_order, gid, name, description, root, ' .
           'lat_root.root_name, ' .
           'lat_root.root_gid, ' .
           'lat_parent.parent_name, ' .
           'lat_parent.parent_gid, ' .
           'COALESCE(
                (SELECT TRUE FROM link_text_attribute_type
                 WHERE attribute_type = link_attribute_type.id),
                false
            ) AS free_text, ' .
           'COALESCE(
                (SELECT TRUE FROM link_creditable_attribute_type
                 WHERE attribute_type = link_attribute_type.id),
                false
            ) AS creditable, ' .
           "COALESCE(ins.instrument_comment, '') AS instrument_comment, " .
           'ins.instrument_type_id, ' .
           "COALESCE(ins.instrument_type_name, '') AS instrument_type_name";
}

sub _column_mapping
{
    return {
        id          => 'id',
        gid         => 'gid',
        parent_id   => 'parent',
        root_id     => 'root',
        root_gid    => 'root_gid',
        child_order => 'child_order',
        name        => 'name',
        description => 'description',
        free_text   => 'free_text',
        creditable  => 'creditable',
        parent => sub {
            my ($row) = @_;
            if ($row->{parent}) {
                MusicBrainz::Server::Entity::LinkAttributeType->new({
                    id => $row->{parent},
                    gid => $row->{parent_gid},
                    name => $row->{parent_name},
                    root_id => $row->{root},
                    root_gid => $row->{root_gid},
                });
            }
        },
        root => sub {
            my ($row) = @_;
            MusicBrainz::Server::Entity::LinkAttributeType->new({
                id => $row->{root},
                gid => $row->{root_gid},
                name => $row->{root_name},
                root_id => $row->{root},
                root_gid => $row->{root_gid},
            });
        },
        instrument_comment => 'instrument_comment',
        instrument_type_id => 'instrument_type_id',
        instrument_type_name => 'instrument_type_name',
    };
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::LinkAttributeType';
}

sub load {
    my ($self, @objs) = @_;

    load_subobjects($self, ['type', 'root'], @objs);
}

sub find_root
{
    my ($self, $id) = @_;

    my $query = 'SELECT root FROM ' . $self->_table . ' WHERE id = ?';
    return $self->sql->select_single_value($query, $id);
}

sub insert
{
    my ($self, $values) = @_;

    my $row = $self->_hash_to_row($values);
    $row->{id} = $self->sql->select_single_value("SELECT nextval('link_attribute_type_id_seq')");
    $row->{gid} = $values->{gid} || generate_gid();
    $row->{root} = $row->{parent} ? $self->find_root($row->{parent}) : $row->{id};
    $self->sql->insert_row('link_attribute_type', $row);
    return $self->_entity_class->new( id => $row->{id}, gid => $row->{gid} );
}

sub _update_root
{
    my ($self, $sql, $parent, $root) = @_;
    my $ids = $self->sql->select_single_column_array('SELECT id FROM link_attribute_type
                                             WHERE parent = ?', $parent);
    if (@$ids) {
        $self->sql->do('UPDATE link_attribute_type SET root = ?
                  WHERE id IN ('.placeholders(@$ids).')', $root, @$ids);
        foreach my $id (@$ids) {
            $self->_update_root($sql, $id, $root);
        }
    }
}

sub update
{
    my ($self, $id, $values) = @_;

    my $row = $self->_hash_to_row($values);
    if (%$row) {
        if ($row->{parent}) {
            $row->{root} = $self->find_root($row->{parent});
            $self->_update_root($self->sql, $id, $row->{root});
        }
        $self->sql->update_row('link_attribute_type', $row, { id => $id });
    }
}

sub delete
{
    my ($self, $id) = @_;

    $self->sql->do('DELETE FROM link_attribute_type WHERE id = ?', $id);
}

sub _hash_to_row
{
    my ($self, $values) = @_;

    return hash_to_row($values, {
        parent          => 'parent_id',
        child_order      => 'child_order',
        name            => 'name',
        description     => 'description',
    });
}

sub get_by_gid
{
    my ($self, $gid) = @_;
    my @result = $self->_get_by_keys('gid', $gid);
    if (scalar(@result)) {
        return $result[0];
    }
    else {
        return undef;
    }
}

sub in_use
{
    my ($self, $id) = @_;
    return $self->sql->select_single_value(
        'SELECT 1 FROM link_attribute WHERE link_attribute.attribute_type = ? LIMIT 1',
        $id);
}

sub merge_instrument_attributes {
    my ($self, $target_id, @source_ids) = @_;

    my ($target, @sources) = @{
        $self->sql->select_single_column_array(
            'WITH id_mapping AS (
                SELECT link_attribute_type.id AS attribute_id, instrument.id AS entity_id
                  FROM instrument
                  JOIN link_attribute_type ON link_attribute_type.gid = instrument.gid
            )
            SELECT attribute_id FROM id_mapping WHERE entity_id = ? OR entity_id = any(?)
            ORDER BY entity_id = ? DESC', $target_id, \@source_ids, $target_id
        );
    };
    my $new_links = $self->sql->select_list_of_hashes('
        SELECT link.id AS id, link_type AS link_type_id,
               begin_date_year, begin_date_month, begin_date_day,
               end_date_year, end_date_month, end_date_day, ended,
               array_agg(la.attribute_type) attributes,
               array_agg(latv.text_value) attribute_text_values,
               array_agg(lac.credited_as) attribute_credits,
               link_type.entity_type0, link_type.entity_type1
          FROM link
          JOIN link_attribute la ON la.link = link.id
          LEFT JOIN link_attribute_text_value latv ON (latv.link = la.link AND latv.attribute_type = la.attribute_type)
          LEFT JOIN link_attribute_credit lac ON (lac.link = la.link AND lac.attribute_type = la.attribute_type)
          JOIN link_type ON link.link_type = link_type.id
          WHERE link.id IN (
              SELECT link FROM link_attribute WHERE attribute_type = any(?)
          )
      GROUP BY link.id, link_type,
               begin_date_year, begin_date_month, begin_date_day,
               end_date_year, end_date_month, end_date_day, ended,
               entity_type0, entity_type1
      ORDER BY link.id ASC',
        \@sources);

    my %source_attributes = map { $_ => 1 } @sources;
    my @old_link_ids;
    for my $new_link (@$new_links) {
        my $old_link_id = delete $new_link->{id};
        push(@old_link_ids, $old_link_id);
        my $entity_type0 = delete $new_link->{entity_type0};
        my $entity_type1 = delete $new_link->{entity_type1};
        for my $date_type (qw( begin_date end_date )) {
            $new_link->{$date_type} = {
                year => delete $new_link->{$date_type . '_year'},
                month => delete $new_link->{$date_type . '_month'},
                day => delete $new_link->{$date_type . '_day'},
            };
        }

        my @attributes = @{ delete $new_link->{attributes} };
        my @attribute_text_values = @{ delete $new_link->{attribute_text_values} };
        my @attribute_credits = @{ delete $new_link->{attribute_credits} };
        my %new_attributes;
        # @conflicting_attributes contains attributes that'll already exist
        # on the link post-merge, with different credited_as values. We choose
        # to preserve both credits by moving the source instrument credits to
        # separate links/relationships.
        my @conflicting_attributes;

        for (my $i = 0; $i < @attributes; $i++) {
            my $attribute_id = $attributes[$i];

            if ($attribute_id == $target) {
                # If there's already a link_attribute for $target, it came from
                # a source instrument attribute, which might have a different
                # credited_as value. We prefer the link attribute associated
                # with the target instrument for consistency, and handle other
                # credits that exist below.
                my $conflict = $new_attributes{$target};

                if (defined $conflict) {
                    delete $new_attributes{$target};
                    push @conflicting_attributes, $conflict;
                }
            }

            # Now use the attribute ID of the target instrument, if this is
            # currently linked to a source instrument attribute.
            if ($source_attributes{$attribute_id}) {
                $attribute_id = $target;
            }

            my $link_attribute = {
                type => {
                    id => $attribute_id,
                },
                text_value => $attribute_text_values[$i],
                credited_as => $attribute_credits[$i],
            };

            if (exists $new_attributes{$attribute_id}) {
                push @conflicting_attributes, $link_attribute;
            } else {
                $new_attributes{$attribute_id} = $link_attribute;
            }
        }

        # If the target link attribute has no credit, and there's only one
        # conflicting attribute that does, just copy the credit into the target
        # attribute and don't bother adding a separate link.
        if (@conflicting_attributes == 1) {
            my $conflict = $conflicting_attributes[0];
            my $new_attribute = $new_attributes{$target};

            if (!non_empty($new_attribute->{credited_as}) && non_empty($conflict->{credited_as})) {
                $new_attribute->{credited_as} = $conflict->{credited_as};
                @conflicting_attributes = ();
            }
        }

        $new_link->{attributes} = [values %new_attributes];

        my $new_link_id = $self->c->model('Link')->find_or_insert($new_link);
        my $relationships = $self->sql->select_list_of_hashes(<<~"EOSQL", $new_link_id, $old_link_id, $new_link_id);
            UPDATE l_${entity_type0}_${entity_type1} r1 SET link = ? WHERE link = ? AND NOT EXISTS (
                SELECT 1
                FROM l_${entity_type0}_${entity_type1} r2
                WHERE r2.link = ?
                AND r2.entity0 = r1.entity0
                AND r2.entity1 = r1.entity1
                AND r2.link_order = r1.link_order
            )
            RETURNING *
            EOSQL

        # Delete leftover duplicate relationships already using $new_link_id.
        $self->sql->do("DELETE FROM l_${entity_type0}_${entity_type1} WHERE link = ?", $old_link_id);

        for my $conflict (@conflicting_attributes) {
            for my $relationship (@$relationships) {
                my @new_relationship = ($entity_type0, $entity_type1, {
                    link_type_id => $new_link->{link_type_id},
                    begin_date => $new_link->{begin_date},
                    end_date => $new_link->{end_date},
                    ended => $new_link->{ended},
                    attributes => [$conflict],
                    entity0_id => $relationship->{entity0},
                    entity1_id => $relationship->{entity1},
                    entity0_credit => $relationship->{entity0_credit},
                    entity1_credit => $relationship->{entity1_credit},
                    link_order => $relationship->{link_order},
                });

                unless ($self->c->model('Relationship')->exists(@new_relationship)) {
                    $self->c->model('Relationship')->insert(@new_relationship);
                }
            }
        }
    }

    # Constraint triggers run at the end of the transaction, so these must be done manually.
    $self->sql->do('DELETE FROM link_attribute_credit WHERE link = any(?)', \@old_link_ids);
    $self->sql->do('DELETE FROM link_attribute WHERE link = any(?)', \@old_link_ids);
    $self->sql->do('DELETE FROM link WHERE id = any(?)', \@old_link_ids);

    $self->c->model('Link')->_delete_from_cache(@old_link_ids);
}

# The entries in the Redis store for 'Link' objects also have all attributes
# loaded. Thus changing an attribute should clear all of these link objects.
for my $method (qw( delete update )) {
    before $method => sub {
        my ($self, $id) = @_;
        $self->c->model('Link')->_delete_from_cache(
            @{ $self->sql->select_single_column_array(
                'SELECT id FROM link
                 JOIN link_attribute la ON link.id = la.link
                 WHERE la.attribute_type = ?',
                $id
            ) }
        );
    };
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
