package MusicBrainz::Server::Report::DuplicateReleaseGroups;
use Moose;

with 'MusicBrainz::Server::Report::ReleaseGroupReport',
     'MusicBrainz::Server::Report::FilterForEditor::ReleaseGroupID';

sub query {
    q{
WITH normalised_names AS (
    SELECT musicbrainz_unaccent(regexp_replace(lower(rg.name), ' \((disc [0-9]+|bonus disc)(: .*)?\)$', '')) AS normalised_name, rg.artist_credit
    FROM release_group rg
    GROUP BY musicbrainz_unaccent(regexp_replace(lower(rg.name), ' \((disc [0-9]+|bonus disc)(: .*)?\)$', '')), rg.comment, rg.artist_credit
    HAVING COUNT(*) > 1
)

SELECT q.rgid AS release_group_id, q.key, row_number() OVER (ORDER BY ac COLLATE musicbrainz, key, rgid, rgname) FROM (

    SELECT release_group.id rgid, artist_credit.name ac, release_group.name rgname, nn.normalised_name||nn.artist_credit AS key
    FROM normalised_names nn
    JOIN release_group ON nn.normalised_name = musicbrainz_unaccent(regexp_replace(lower(release_group.name), ' \((disc [0-9]+|bonus disc)(: .*)?\)$', ''))
    AND nn.artist_credit = release_group.artist_credit
    JOIN artist_credit ON artist_credit.id = release_group.artist_credit
    GROUP BY artist_credit.name COLLATE musicbrainz, nn.normalised_name||nn.artist_credit, artist_credit.name, release_group.id, release_group.name

) q
    };
}

__PACKAGE__->meta->make_immutable;
no Moose;
;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
