package MusicBrainz::Server::Report::AnnotationReport;
use Moose::Role;
use MusicBrainz::Server::Data::Relationship;

with 'MusicBrainz::Server::Report::QueryReport';

requires 'entity_type';

sub query {
    my ($self) = @_;
    my $entity_type = $self->entity_type;

    my $query = "SELECT s.text, substr(s.created::text, 0, 17) AS created, e.id AS ${entity_type}_id, row_number() OVER (order by s.created DESC, e.name COLLATE musicbrainz)
                    FROM (
                        select *, row_number() over (partition by $entity_type order by created desc)
                        from ${entity_type}_annotation ea
                        join annotation an on ea.annotation = an.id
                        join $entity_type e on e.id = ea.$entity_type
                    ) s
                    join $entity_type e on e.gid = s.gid
                    where row_number = 1
                    and s.text != ''
                    order by s.created DESC, s.text";

    return $query;
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

