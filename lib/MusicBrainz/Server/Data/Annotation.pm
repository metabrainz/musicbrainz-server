package MusicBrainz::Server::Data::Annotation;
use Moose;

use MusicBrainz::Server::Entity::Annotation;
use MusicBrainz::Server::Data::Utils qw( placeholders );

extends 'MusicBrainz::Server::Data::Entity';

has [qw( type table )] => (
    is => 'rw',
    isa => 'Str',
    required => 1
);

sub _table
{
    my $self = shift;
    return $self->table . ' ea
            JOIN annotation a ON ea.annotation=a.id';
}

sub _columns
{
    return 'id, editor AS editor_id, text, changelog,
            created AS creation_date';
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::Annotation';
}

sub get_latest
{
    my ($self, $id) = @_;
    my $query = "SELECT " . $self->_columns .
                " FROM " . $self->_table .
                " WHERE " . $self->type . " = ?" .
                " ORDER BY created DESC LIMIT 1";
    my $sql = Sql->new($self->c->mb->dbh);
    my $row = $sql->SelectSingleRowHash($query, $id)
        or return undef;
    return $self->_new_from_row($row);
}

sub load_latest
{
    my ($self, @objs) = @_;
    for my $obj (@objs) {
        next unless $obj->does('MusicBrainz::Server::Entity::AnnotationRole');
        my $annotation = $self->get_latest($obj->id) or next;
        $obj->latest_annotation($annotation);
    }
}

sub delete
{
    my ($self, @ids) = @_;
    my $query = "DELETE FROM " . $self->table .
                " WHERE " . $self->type . " IN (" . placeholders(@ids) . ")" .
                " RETURNING annotation";
    my $sql = Sql->new($self->c->dbh);
    my $annotations = $sql->SelectSingleColumnArray($query, @ids);
    return 1 unless scalar @$annotations;
    $query = "DELETE FROM annotation WHERE id IN (" . placeholders(@$annotations) . ")";
    $sql->Do($query, @$annotations);
    return 1;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;

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

