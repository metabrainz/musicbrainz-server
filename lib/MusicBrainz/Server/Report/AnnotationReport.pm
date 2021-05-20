package MusicBrainz::Server::Report::AnnotationReport;
use Moose::Role;
use MusicBrainz::Server::Data::Relationship;

with 'MusicBrainz::Server::Report::QueryReport';

requires 'entity_type';

sub query {
    my ($self) = @_;
    my $entity_type = $self->entity_type;

    my $query = "SELECT s.text, substr(s.created::text, 0, 17) AS created, e.id AS ${entity_type}_id, row_number() OVER (ORDER BY s.created DESC, e.name COLLATE musicbrainz)
                    FROM (
                        SELECT *, row_number() OVER (PARTITION BY $entity_type ORDER BY created desc)
                        FROM ${entity_type}_annotation ea
                        JOIN annotation an ON ea.annotation = an.id
                        JOIN $entity_type e ON e.id = ea.$entity_type
                    ) s
                    JOIN $entity_type e ON e.gid = s.gid
                    WHERE row_number = 1
                    AND s.text != ''
                    ORDER BY s.created DESC, s.text";

    return $query;
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

