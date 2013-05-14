package MusicBrainz::Server::Data::LinkType;

use Moose;
use namespace::autoclean;
use Sql;
use MusicBrainz::Server::Entity::ExampleRelationship;
use MusicBrainz::Server::Entity::LinkType;
use MusicBrainz::Server::Entity::LinkTypeAttribute;
use MusicBrainz::Server::Data::Utils qw(
    load_subobjects
    hash_to_row
    generate_gid
    placeholders
);
use MusicBrainz::Server::Translation;

extends 'MusicBrainz::Server::Data::Entity';
with 'MusicBrainz::Server::Data::Role::GetByGID';
with 'MusicBrainz::Server::Data::Role::EntityCache' => { prefix => 'linktype' };

sub _table
{
    return 'link_type';
}

sub _columns
{
    return 'id, parent AS parent_id, gid, name, link_phrase,
            entity_type0 AS entity0_type, entity_type1 AS entity1_type,
            reverse_link_phrase, description, priority,
            child_order, long_link_phrase';
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::LinkType';
}

sub _load_attributes
{
    my ($self, $data, @ids) = @_;

    if (@ids) {
        my $query = "
            SELECT *
            FROM link_type_attribute_type
            WHERE link_type IN (" . placeholders(@ids) . ")
            ORDER BY link_type";
        $self->sql->select($query, @ids);
        while (1) {
            my $row = $self->sql->next_row_hash_ref or last;
            my $id = $row->{link_type};
            if (exists $data->{$id}) {
                my %args = ( type_id => $row->{attribute_type} );
                $args{min} = $row->{min} if defined $row->{min};
                $args{max} = $row->{max} if defined $row->{max};
                my $attr = MusicBrainz::Server::Entity::LinkTypeAttribute->new(%args);
                $data->{$id}->add_attribute($attr);
            }
        }
        $self->sql->finish;
    }
}

sub get_by_ids
{
    my ($self, @ids) = @_;
    my $data = MusicBrainz::Server::Data::Entity::get_by_ids($self, @ids);
    $self->_load_attributes($data, @ids);
    return $data;
}

sub get_by_id
{
    my ($self, $id) = @_;
    my $obj = MusicBrainz::Server::Data::Entity::get_by_id($self, $id);
    if (defined $obj) {
        $self->_load_attributes({ $id => $obj }, $id);
    }
    return $obj;
}

around get_by_gid => sub
{
    my ($orig, $self) = splice(@_, 0, 2);
    my ($gid) = @_;
    my $obj = $self->$orig($gid);
    if (defined $obj) {
        $self->_load_attributes({ $obj->id => $obj }, $obj->id);
    }
    return $obj;
};

sub load
{
    my ($self, @objs) = @_;
    load_subobjects($self, 'type', @objs);
}

sub get_tree
{
    my ($self, $type0, $type1) = @_;

    $self->sql->select('SELECT '  .$self->_columns . ' FROM ' . $self->_table . '
                  WHERE entity_type0=? AND entity_type1=?
                  ORDER BY child_order, id', $type0, $type1);
    my %id_to_obj;
    my @objs;
    while (1) {
        my $row = $self->sql->next_row_hash_ref or last;
        my $obj = $self->_new_from_row($row);
        $id_to_obj{$obj->id} = $obj;
        push @objs, $obj;
    }
    $self->sql->finish;

    $self->_load_attributes(\%id_to_obj, keys %id_to_obj);

    my $root = MusicBrainz::Server::Entity::LinkType->new;
    foreach my $obj (@objs) {
        my $parent = $obj->parent_id ? $id_to_obj{$obj->parent_id} : $root;
        $parent->add_child($obj);
    }

    return $root;
}

sub get_full_tree
{
    my ($self) = @_;

    $self->sql->select('SELECT '  .$self->_columns . ' FROM ' . $self->_table . '
                  ORDER BY entity_type0, entity_type1, child_order, id');
    my %id_to_obj;
    my @objs;
    while (1) {
        my $row = $self->sql->next_row_hash_ref or last;
        my $obj = $self->_new_from_row($row);
        $id_to_obj{$obj->id} = $obj;
        push @objs, $obj;
    }
    $self->sql->finish;

    $self->_load_attributes(\%id_to_obj, keys %id_to_obj);

    my %roots;
    foreach my $obj (@objs) {
        my $type_key = join('-', $obj->entity0_type, $obj->entity1_type);
        $roots{ $type_key } ||= MusicBrainz::Server::Entity::LinkType->new(
            name => l('{t0}-{t1} relationships', { t0 => $obj->entity0_type,
                                                   t1 => $obj->entity1_type }),
            entity0_type => $obj->entity0_type,
            entity1_type => $obj->entity1_type,
        );

        my $parent = $obj->parent_id ? $id_to_obj{$obj->parent_id} : $roots{ $type_key };
        $parent->add_child($obj);
    }

    return grep { $_->all_children != 0 } map { $roots{$_} } sort keys %roots;
}

sub get_attribute_type_list
{
    my ($self, $id) = @_;

    if (defined $id) {
        $self->sql->select('SELECT t.id, t.name, at.link_type, at.min, at.max
                          FROM link_attribute_type t
                          LEFT JOIN link_type_attribute_type at
                              ON t.id = at.attribute_type AND at.link_type = ?
                      WHERE t.parent IS NULL ORDER BY t.child_order, t.id', $id);
    }
    else {
        $self->sql->select('SELECT t.id, t.name FROM link_attribute_type t
                      WHERE t.parent IS NULL ORDER BY t.child_order, t.id');
    }
    my @result;
    while (1) {
        my $row = $self->sql->next_row_hash_ref or last;
        push @result, {
            type   => $row->{id},
            active => $row->{link_type} ? 1 : 0,
            min    => $row->{min},
            max    => $row->{max},
            name   => $row->{name},
        };
    }
    $self->sql->finish;

    return \@result;
}

sub insert
{
    my ($self, $values) = @_;

    my $row = $self->_hash_to_row($values);
    $row->{gid} = $values->{gid} || generate_gid();
    my $id = $self->sql->insert_row('link_type', $row, 'id');
    $self->sql->insert_row(
        'documentation.link_type_documentation',
        {
            documentation => $values->{documentation} // '',
            id => $id
        }
    );
    if (exists $values->{attributes}) {
        foreach my $attrib (@{$values->{attributes}}) {
            $self->sql->insert_row('link_type_attribute_type', {
                link_type      => $id,
                attribute_type => $attrib->{type},
                min            => $attrib->{min},
                max            => $attrib->{max},
            });
        }
    }
    return $self->_entity_class->new( id => $id, gid => $row->{gid} );
}

sub set_examples {
    my ($self, $id, $examples) = @_;

    my $link_table = $self->sql->select_single_value(
        "SELECT 'l_' || entity_type0 || '_' || entity_type1
         FROM link_type
         WHERE id = ?",
        $id
    );

    my $documentation_link_table = sprintf "documentation.%s_example",
        $link_table;

    $self->sql->do(
        "DELETE FROM $documentation_link_table
         WHERE id IN (
             SELECT l.id
             FROM $documentation_link_table
             JOIN $link_table l USING (id)
             JOIN link ON (link.id = l.link)
             WHERE link.link_type = ?
         )",
        $id
    );

    for my $example (@$examples) {
        $self->sql->insert_row(
            $documentation_link_table,
            {
                name => $example->{name},
                id => $example->{relationship}{id},
                published => 1
            }
        );
    }
}

sub update
{
    my ($self, $id, $values) = @_;

    my $row = $self->_hash_to_row($values);
    if (%$row) {
        $self->sql->update_row('link_type', $row, { id => $id });
    }
    if (exists $values->{documentation}) {
        $self->sql->update_row(
            'documentation.link_type_documentation',
            { documentation => $values->{documentation} },
            { id => $id }
        );
    }

    if (exists $values->{examples}) {
        $self->set_examples($id, $values->{examples});
    }

    if (exists $values->{attributes}) {
        $self->sql->do('DELETE FROM link_type_attribute_type WHERE link_type = ?', $id);
        foreach my $attrib (@{$values->{attributes}}) {
            $self->sql->insert_row('link_type_attribute_type', {
                link_type      => $id,
                attribute_type => $attrib->{type},
                min            => $attrib->{min},
                max            => $attrib->{max},
            });
        }
    }
}

sub delete
{
    my ($self, $id) = @_;

    $self->sql->do('DELETE FROM documentation.link_type_documentation WHERE id = ?', $id);
    $self->sql->do('DELETE FROM link_type_attribute_type WHERE link_type = ?', $id);
    $self->sql->do('DELETE FROM link_type WHERE id = ?', $id);
}

sub _hash_to_row
{
    my ($self, $values) = @_;

    return hash_to_row($values, {
        parent          => 'parent_id',
        entity_type0     => 'entity0_type',
        entity_type1     => 'entity1_type',
        child_order      => 'child_order',
        name            => 'name',
        description     => 'description',
        link_phrase      => 'link_phrase',
        reverse_link_phrase     => 'reverse_link_phrase',
        long_link_phrase => 'long_link_phrase',
        priority        => 'priority',
    });
}

sub in_use {
    my ($self, $link_type_id) = @_;
    return $self->sql->select_single_value(
        'SELECT TRUE FROM link WHERE link_type = ? LIMIT 1',
        $link_type_id
    );
}

sub load_documentation {
    my ($self, @link_types) = @_;

    my $link_type_ids = [ map { $_->id } @link_types ];

    my %documentation_strings = map { @$_ } @{
        $self->sql->select_list_of_lists(
            'SELECT id, documentation
             FROM documentation.link_type_documentation
             WHERE id = any(?)', $link_type_ids
         );
    };

    my $all_examples_query =
        sprintf 'SELECT * FROM (%s) s WHERE link_type = any(?)',
            join(
                ' UNION ALL ',
                map {
                    my ($a, $b) = @$_;
                    my $t = "l_${a}_${b}";
                    "SELECT link_type, l.id, ex.name, ex.published, entity_type0,
                       entity_type1
                     FROM documentation.${t}_example ex
                     JOIN $t l USING (id)
                     JOIN link ON (l.link = link.id)
                     JOIN link_type ON (link.link_type = link_type.id)"
                }
                $self->c->model('Relationship')->all_pairs
            );

    my %examples;
    for my $example (@{
        $self->sql->select_list_of_hashes($all_examples_query, $link_type_ids)
    }) {
        push @{ $examples{ $example->{link_type} } //= [] },
            MusicBrainz::Server::Entity::ExampleRelationship->new(
                name => $example->{name},
                published => $example->{published},
                relationship => $self->c->model('Relationship')->get_by_id(
                    $example->{entity_type0}, $example->{entity_type1},
                    $example->{id}
                )
            )
    }

    my @relationships = map { $_->relationship } map { @$_ } values %examples;
    $self->c->model('Link')->load(@relationships);
    $self->c->model('LinkType')->load(map { $_->link } @relationships);
    $self->c->model('Relationship')->load_entities(@relationships);

    for my $link_type (@link_types) {
        my $id = $link_type->id;
        $link_type->documentation($documentation_strings{$id} // '');
        $link_type->examples($examples{$id} // []);
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

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
