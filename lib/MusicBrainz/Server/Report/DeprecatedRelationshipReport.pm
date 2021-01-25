package MusicBrainz::Server::Report::DeprecatedRelationshipReport;
use Moose::Role;
use MusicBrainz::Server::Data::Relationship;

with 'MusicBrainz::Server::Report::QueryReport';

requires 'entity_type';

sub query {
    my ($self) = @_;
    my $entity_type = $self->entity_type;
    my $name_sort = $entity_type ne 'url' ? 'entity.name COLLATE musicbrainz' : 'entity.url';
    my $extra_conditions = $entity_type eq 'url' ? ' AND link.ended IS FALSE' : '';
    my @tables = $self->c->model('Relationship')->generate_table_list($entity_type);
    my $query = "SELECT l.name AS link_name, l.gid AS link_gid, entity.id AS ${entity_type}_id, row_number() OVER (ORDER BY l.name, $name_sort)" .
                "FROM $entity_type AS entity JOIN (";
    my $first = 1;
    foreach my $t (@tables) {
        my ($table, $type_column) = @$t;
        if ($first) {
            $first = 0;
        } else {
            $query .= " UNION ";
        }
        $query .= "SELECT link_type.name AS name, link_type.gid AS gid, $type_column AS entity
                   FROM link_type
                   JOIN link ON link.link_type = link_type.id
                   JOIN $table l_table ON l_table.link = link.id
                   WHERE (link_type.is_deprecated OR link_type.description = '')
                   $extra_conditions";
    }
    $query .= ") l ON l.entity = entity.id";
    return $query;
}

1;

=head1 COPYRIGHT

Copyright (C) 2013 MetaBrainz Foundation

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

