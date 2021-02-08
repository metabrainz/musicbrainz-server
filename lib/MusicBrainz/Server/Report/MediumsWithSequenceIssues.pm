package MusicBrainz::Server::Report::MediumsWithSequenceIssues;
use Moose;
use namespace::autoclean;

with 'MusicBrainz::Server::Report::ReleaseReport',
     'MusicBrainz::Server::Report::FilterForEditor::ReleaseID';

sub query
{
    # There are 3 checks going on in this query:
    # 1. The first medium should be '1'
    # 2. The last medium should match the amount of mediums
    # 3. The sum of all mediums should match a standard arithmetic progression.
    #    This is used to ensure that the list of medium positions is linear,
    #    has no gaps, and no duplicates.
    #    E.g. If the medium had mediums: 1, 2, 3, 3, 5 then
    #    the following will *not* hold:
    #    1 + 2 + 3 + 3 + 5 = 1 + 2 + 3 + 4 + 5
    <<'EOSQL'
SELECT DISTINCT release.id AS release_id,
  release.name,
  row_number() OVER (ORDER BY release.name COLLATE musicbrainz)
FROM (
    SELECT
      medium.release,
      min(medium.position) AS first_medium,
      max(medium.position) AS last_medium,
      count(medium.position) AS medium_count,
      sum(medium.position) AS medium_pos_acc
    FROM
      medium
    GROUP BY medium.release
) s
JOIN release ON release.id = s.release
WHERE
     first_medium != 1
  OR last_medium != medium_count
  OR (medium_count * (1 + medium_count)) / 2 <> medium_pos_acc
EOSQL
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky
Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
