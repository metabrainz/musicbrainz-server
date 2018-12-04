package MusicBrainz::Server::Report::ReleaseLabelSameArtist;
use Moose;

with 'MusicBrainz::Server::Report::ReleaseReport',
     'MusicBrainz::Server::Report::FilterForEditor::ReleaseID';

sub query {
    q{
      SELECT DISTINCT
        r.id AS release_id,
        row_number() OVER (ORDER BY r.artist_credit, r.name)
      FROM
        release AS r
        INNER JOIN artist AS a ON a.id = r.artist_credit
        INNER JOIN artist_credit_name AS acn ON acn.artist_credit = r.artist_credit
        INNER JOIN release_label AS rl ON rl.release=r.id
        INNER JOIN label AS l ON rl.label=l.id
      WHERE
        l.name = acn.name
      OR
        l.name = a.name
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2018 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
