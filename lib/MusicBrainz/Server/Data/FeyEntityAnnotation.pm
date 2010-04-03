package MusicBrainz::Server::Data::FeyEntityAnnotation;
use Moose;

use Method::Signatures::Simple;
use MusicBrainz::Server::Entity::Annotation;
use MusicBrainz::Server::Data::Utils qw( placeholders );
use MusicBrainz::Schema qw( schema );
use namespace::autoclean;

extends 'MusicBrainz::Server::Data::FeyEntity';
with 'MusicBrainz::Server::Data::Role::Joined';

around _select => sub
{
    my $orig = shift;
    my $self = shift;
    my $annotation_table = schema->table('annotation');
    return $self->$orig
        ->select($annotation_table)
        ->from($self->table, $annotation_table);
};

sub _column_mapping
{
    return {
        id            => 'id',
        editor_id     => 'editor',
        text          => 'text',
        changelog     => 'changelog',
        creation_date => 'created'
    };
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::Annotation';
}

method get_latest ($entity_id)
{
    my $query = $self->_select
        ->where($self->_join_column, '=', $entity_id)
        ->order_by(schema->table('annotation')->column('created'), 'DESC')
        ->limit(1);

    my $row = $self->sql->select_single_row_hash(
        $query->sql($self->sql->dbh), $query->bind_params)
        or return undef;
    return $self->_new_from_row($row);
}

method load_latest (@objs)
{
    for my $obj (@objs) {
        next unless $obj->does('MusicBrainz::Server::Entity::Role::Annotation');
        my $annotation = $self->get_latest($obj->id) or next;
        $obj->latest_annotation($annotation);
    }
}

method edit ($annotation_hash)
{
    my $annotation_id = $self->sql->insert_row('annotation', {
        editor    => $annotation_hash->{editor_id},
        text      => $annotation_hash->{text},
        changelog => $annotation_hash->{changelog}
    }, 'id');
    $self->sql->insert_row($self->table, {
        $self->type => $annotation_hash->{entity_id},
        annotation  => $annotation_id
    });
    return $annotation_id;
}

method delete (@ids)
{
    my $query = "DELETE FROM " . $self->table->name .
                " WHERE " . $self->type . " IN (" . placeholders(@ids) . ")" .
                " RETURNING annotation";

    my $annotations = $self->sql->select_single_column_array($query, @ids);
    return 1 unless scalar @$annotations;
    $query = "DELETE FROM annotation WHERE id IN (" . placeholders(@$annotations) . ")";
    $self->sql->do($query, @$annotations);
    return 1;
}

method merge ($new_id, @old_ids)
{
    my $query = Fey::SQL->new_update
        ->update($self->table)
        ->set($self->_join_column, $new_id)
        ->where($self->_join_column, 'IN', @old_ids);

    $self->sql->do($query->sql($self->sql->dbh), $query->bind_params);
}

__PACKAGE__->meta->make_immutable;

=head1 NAME

MusicBrainz::Server::Data::Annotation

=head1 DESCRIPTION

Provides support for loading annotations from the database.

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

