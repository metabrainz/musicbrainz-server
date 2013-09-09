package MusicBrainz::Server::Report::SetInDifferentRG;
use Moose;
use namespace::autoclean;

with 'MusicBrainz::Server::Report::ReleaseGroupReport',
     'MusicBrainz::Server::Report::FilterForEditor::ReleaseGroupID';

sub query {
    "
        SELECT DISTINCT
			rg.id AS release_group_id,
            row_number() OVER (ORDER BY musicbrainz_collate(rg.name))
		FROM release_group rg
		    JOIN release rel ON rel.release_group = rg.id
		WHERE rel.id IN (
			SELECT r0.id
			FROM l_release_release l
				JOIN release r0 ON l.entity0 = r0.id
				JOIN release r1 ON l.entity1 = r1.id
                JOIN link ON l.link = link.id
                JOIN link_type ON link.link_type = link_type.id
			WHERE link_type.gid in ('6d08ec1e-a292-4dac-90f3-c398a39defd5', 'fc399d47-23a7-4c28-bfcf-0607a562b644')
				AND r0.release_group <> r1.release_group
            UNION
			SELECT r1.id
			FROM l_release_release l
				JOIN release r0 ON l.entity0 = r0.id
				JOIN release r1 ON l.entity1 = r1.id
                JOIN link ON l.link = link.id
                JOIN link_type ON link.link_type = link_type.id
			WHERE link_type.gid in ('6d08ec1e-a292-4dac-90f3-c398a39defd5', 'fc399d47-23a7-4c28-bfcf-0607a562b644')
				AND r0.release_group <> r1.release_group
		)
    ";
}

1;

=head1 COPYRIGHT

Copyright (C) 2012 MetaBrainz Foundation

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
