package MusicBrainz::Server::Data::LinkType;

use Moose;
use Sql;
use MusicBrainz::Server::Entity::LinkType;
use MusicBrainz::Server::Entity::LinkTypeAttribute;
use MusicBrainz::Server::Data::Utils qw(
    hash_to_row
    generate_gid
    placeholders
);
use MusicBrainz::Schema qw( schema );

extends 'MusicBrainz::Server::Data::FeyEntity';
with 'MusicBrainz::Server::Data::Role::EntityCache' => { prefix => 'linktype' },
     'MusicBrainz::Server::Data::Role::Subobject' => { prefix => 'type' };

sub _build_table { schema->table('link_type') }

sub _table
{
    return 'link_type';
}

sub _columns
{
    return 'id, parent, gid, name, linkphrase, entitytype0, entitytype1,
            rlinkphrase, description, priority, childorder, shortlinkphrase';
}

sub _column_mapping
{
    return {
        id                  => 'id',
        parent_id           => 'parent',
        gid                 => 'gid',
        name                => 'name',
        link_phrase         => 'linkphrase',
        entity0_type        => 'entitytype0',
        entity1_type        => 'entitytype1',
        reverse_link_phrase => 'rlinkphrase',
        description         => 'description',
        priority            => 'priority',
        child_order         => 'child_order',
        short_link_phrase   => 'shortlinkphrase',
    }
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
        my $sql = Sql->new($self->c->dbh);
        $sql->select($query, @ids);
        while (1) {
            my $row = $sql->next_row_hash_ref or last;
            my $id = $row->{link_type};
            if (exists $data->{$id}) {
                my %args = ( type_id => $row->{attribute_type} );
                $args{min} = $row->{min} if defined $row->{min};
                $args{max} = $row->{max} if defined $row->{max};
                my $attr = MusicBrainz::Server::Entity::LinkTypeAttribute->new(%args);
                $data->{$id}->add_attribute($attr);
            }
        }
        $sql->finish;
    }
}

around get_by_ids => sub
{
    my $orig = shift;
    my ($self, @ids) = @_;
    my $data = $self->$orig(@ids);
    $self->_load_attributes($data, @ids);
    return $data;
};

around get_by_id => sub
{
    my $orig = shift;
    my ($self, $id) = @_;
    my $obj = $self->$orig($id);
    if (defined $obj) {
        $self->_load_attributes({ $id => $obj }, $id);
    }
    return $obj;
};

sub get_tree
{
    my ($self, $type0, $type1) = @_;

    my $sql = Sql->new($self->c->dbh);
    $sql->select('SELECT '  .$self->_columns . ' FROM ' . $self->_table . '
                  WHERE entitytype0=? AND entitytype1=?
                  ORDER BY childorder, id', $type0, $type1);
    my %id_to_obj;
    my @objs;
    while (1) {
        my $row = $sql->next_row_hash_ref or last;
        my $obj = $self->_new_from_row($row);
        $id_to_obj{$obj->id} = $obj;
        push @objs, $obj;
    }
    $sql->finish;

    $self->_load_attributes(\%id_to_obj, keys %id_to_obj);

    my $root = MusicBrainz::Server::Entity::LinkType->new;
    foreach my $obj (@objs) {
        my $parent = $obj->parent_id ? $id_to_obj{$obj->parent_id} : $root;
        $parent->add_child($obj);
    }

    return $root;
}

sub get_attribute_type_list
{
    my ($self, $id) = @_;

    my $sql = Sql->new($self->c->dbh);
    if (defined $id) {
        $sql->select('SELECT t.id, t.name, at.link_type, at.min, at.max
                          FROM link_attribute_type t
                          LEFT JOIN link_type_attribute_type at
                              ON t.id = at.attribute_type AND at.link_type = ?
                      WHERE t.parent IS NULL ORDER BY t.childorder, t.id', $id);
    }
    else {
        $sql->select('SELECT t.id, t.name FROM link_attribute_type t
                      WHERE t.parent IS NULL ORDER BY t.childorder, t.id');
    }
    my @result;
    while (1) {
        my $row = $sql->next_row_hash_ref or last;
        push @result, {
            type   => $row->{id},
            active => $row->{link_type} ? 1 : 0,
            min    => $row->{min},
            max    => $row->{max},
            name   => $row->{name},
        };
    }
    $sql->finish;

    return \@result;
}

sub insert
{
    my ($self, $values) = @_;

    my $sql = Sql->new($self->c->dbh);
    my $row = $self->_hash_to_row($values);
    $row->{gid} = $values->{gid} || generate_gid();
    my $id = $sql->insert_row('link_type', $row, 'id');
    if (exists $values->{attributes}) {
        foreach my $attrib (@{$values->{attributes}}) {
            $sql->insert_row('link_type_attribute_type', {
                link_type      => $id,
                attribute_type => $attrib->{type},
                min            => $attrib->{min},
                max            => $attrib->{max},
            });
        }
    }
    return $self->_entity_class->new( id => $id, gid => $row->{gid} );
}

sub update
{
    my ($self, $id, $values) = @_;

    my $sql = Sql->new($self->c->dbh);
    my $row = $self->_hash_to_row($values);
    if (%$row) {
        $sql->update_row('link_type', $row, { id => $id });
    }
    if (exists $values->{attributes}) {
        $sql->do('DELETE FROM link_type_attribute_type WHERE link_type = ?', $id);
        foreach my $attrib (@{$values->{attributes}}) {
            $sql->insert_row('link_type_attribute_type', {
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

    my $sql = Sql->new($self->c->dbh);
    $sql->do('DELETE FROM link_type_attribute_type WHERE link_type = ?', $id);
    $sql->do('DELETE FROM link_type WHERE id = ?', $id);
}

sub _hash_to_row
{
    my ($self, $values) = @_;

    return hash_to_row($values, {
        parent          => 'parent_id',
        entitytype0     => 'entity0_type',
        entitytype1     => 'entity1_type',
        childorder      => 'child_order',
        name            => 'name',
        description     => 'description',
        linkphrase      => 'link_phrase',
        rlinkphrase     => 'reverse_link_phrase',
        shortlinkphrase => 'short_link_phrase',
        priority        => 'priority',
    });
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
