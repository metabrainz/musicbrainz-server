package MusicBrainz::Server::Report::MediumsWithSequenceIssues;
use Moose;
use namespace::autoclean;

extends 'MusicBrainz::Server::Report::ReleaseReport';

sub gather_data
{
	my ($self, $writer) = @_;

    # There are 3 checks going on in this query:
    # 1. The first medium should be '1'
    # 2. The last medium should match the amount of mediums
    # 3. The sum of all mediums should match a standard arithmetic progression.
    #    This is used to ensure that the list of medium positions is linear,
    #    has no gaps, and no duplicates.
    #    E.g. If the medium had mediums: 1, 2, 3, 3, 5 then
    #    the following will *not* hold:
    #    1 + 2 + 3 + 3 + 5 = 1 + 2 + 3 + 4 + 5
	$self->gather_data_from_query($writer, <<'EOSQL');
SELECT DISTINCT release.id, release.gid AS release_gid, release.artist_credit AS artist_credit_id,
  musicbrainz_collate(rel_name.name), rel_name.name
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
JOIN release_name rel_name ON rel_name.id = release.name
WHERE
     first_medium != 1
  OR last_medium != medium_count
  OR (medium_count * (1 + medium_count)) / 2 <> medium_pos_acc
ORDER BY musicbrainz_collate(rel_name.name)
EOSQL
}

sub template {
    return 'report/mediums_with_sequence_issues.tt'
}

1;
