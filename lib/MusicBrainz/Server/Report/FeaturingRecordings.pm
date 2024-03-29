package MusicBrainz::Server::Report::FeaturingRecordings;
use Moose;
use utf8;

with 'MusicBrainz::Server::Report::RecordingReport',
     'MusicBrainz::Server::Report::FilterForEditor::RecordingID';

sub query {
    q{
        SELECT
            r.id AS recording_id,
            row_number() OVER (ORDER BY ac.name COLLATE musicbrainz, r.name COLLATE musicbrainz)
        FROM recording r
            JOIN artist_credit ac ON r.artist_credit = ac.id
        WHERE
            r.name COLLATE musicbrainz ~* E' \\\\(((f|w)/|(feat|ｆｅａｔ|ft|συμμ)(\\\\.|．)|(duet with|συμμετέχει|featuring|ｆｅａｔｕｒｉｎｇ) )'
    };
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation
Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

