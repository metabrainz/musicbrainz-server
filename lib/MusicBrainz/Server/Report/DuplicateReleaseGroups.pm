package MusicBrainz::Server::Report::DuplicateReleaseGroups;
use Moose;

with 'MusicBrainz::Server::Report::ReleaseGroupReport',
     'MusicBrainz::Server::Report::FilterForEditor::ReleaseGroupID';

sub query {
    "
WITH normalised_names AS (
    SELECT musicbrainz_unaccent(lower(regexp_replace(rg.name, ' \((disc [0-9]+|bonus disc)(: .*)?\)\$', ''))) AS normalised_name, rg.artist_credit
    FROM release_group rg
    GROUP BY musicbrainz_unaccent(lower(regexp_replace(rg.name, ' \((disc [0-9]+|bonus disc)(: .*)?\)\$', ''))), rg.comment, rg.artist_credit
    HAVING COUNT(*) > 1
)

SELECT q.rgid AS release_group_id, q.key, row_number() OVER (ORDER BY musicbrainz_collate(ac), key, rgid, rgname) FROM (

    SELECT release_group.id rgid, artist_credit.name ac, release_group.name rgname, nn.normalised_name||nn.artist_credit AS key
    FROM normalised_names nn
    JOIN release_group ON nn.normalised_name = musicbrainz_unaccent(lower(regexp_replace(release_group.name, ' \((disc [0-9]+|bonus disc)(: .*)?\)\$', '')))
    AND nn.artist_credit = release_group.artist_credit
    JOIN artist_credit ON artist_credit.id = release_group.artist_credit
    GROUP BY musicbrainz_collate(artist_credit.name), nn.normalised_name||nn.artist_credit, artist_credit.name, release_group.id, release_group.name

) q
    ";
}

__PACKAGE__->meta->make_immutable;
no Moose;
;

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
