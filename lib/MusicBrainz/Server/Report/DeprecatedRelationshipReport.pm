package MusicBrainz::Server::Report::DeprecatedRelationshipReport;
use Moose::Role;
use namespace::autoclean;
use List::AllUtils qw( any );
use MusicBrainz::Server::Data::Relationship;

with 'MusicBrainz::Server::Report::QueryReport';

requires 'entity_type';

sub query {
    my ($self) = @_;
    my $entity_type = $self->entity_type;
    my $name_sort = $entity_type ne 'url' ? 'entity.name COLLATE musicbrainz' : 'entity.url';
    my @tables = $self->c->model('Relationship')->generate_table_list($entity_type);
    my @url_table_names = map { $_->[0] } $self->c->model('Relationship')->generate_table_list('url');
    my $query = "SELECT l.name AS link_name, l.gid AS link_gid, entity.id AS ${entity_type}_id, row_number() OVER (ORDER BY l.name, $name_sort)" .
                "FROM $entity_type AS entity JOIN (";
    my $first = 1;
    foreach my $t (@tables) {
        my ($table, $type_column) = @$t;

        if ($first) {
            $first = 0;
        } else {
            $query .= ' UNION ';
        }

        $query .= "SELECT link_type.name AS name, link_type.gid AS gid, $type_column AS entity
                   FROM link_type
                   JOIN link ON link.link_type = link_type.id
                   JOIN $table l_table ON l_table.link = link.id
                   WHERE (link_type.is_deprecated OR link_type.description = '')";

        # For URL relationships, ignore ended ones (that means the link is no longer
        # valid, yet being kept for history)
        if (any { $_ =~ /^$table/ } @url_table_names) {
            $query .= ' AND link.ended IS FALSE';
        }

    }
    $query .= ') l ON l.entity = entity.id';
    return $query;
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

