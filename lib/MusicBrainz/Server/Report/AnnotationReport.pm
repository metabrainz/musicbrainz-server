package MusicBrainz::Server::Report::AnnotationReport;
use Moose::Role;
use MusicBrainz::Server::Data::Relationship;

with 'MusicBrainz::Server::Report::QueryReport';

requires 'entity_type';

sub query {
    my ($self) = @_;
    my $entity_type = $self->entity_type;

    my $query = "SELECT s.text, substr(s.created::text, 0, 17) AS created, e.id AS ${entity_type}_id, row_number() OVER (order by s.created DESC, musicbrainz_collate(e.name))
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

=head1 COPYRIGHT

Copyright (C) 2014 MetaBrainz Foundation

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

