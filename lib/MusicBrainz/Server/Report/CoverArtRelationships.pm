package MusicBrainz::Server::Report::CoverArtRelationships;
use Moose;

with 'MusicBrainz::Server::Report::ReleaseReport',
     'MusicBrainz::Server::Report::URLReport',
     'MusicBrainz::Server::Report::FilterForEditor::ReleaseID';

sub query {
    "
        SELECT
            r.id AS release_id,
            row_number() OVER (ORDER BY musicbrainz_collate(an.name), musicbrainz_collate(rn.name))
        FROM release r
            JOIN release_name rn ON r.name = rn.id
            JOIN l_release_url l_ru ON r.id = l_ru.entity0
            JOIN link l ON l_ru.link = l.id
            JOIN artist_credit ac on ac.id = r.artist_credit
            JOIN artist_name an on an.id = ac.name
        WHERE l.link_type = 78 AND l_ru.edits_pending = 0
    ";
}

sub template
{
    return 'report/releases_with_coverart_links.tt';
}

__PACKAGE__->meta->make_immutable;
no Moose;
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
