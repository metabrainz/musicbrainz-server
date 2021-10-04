package MusicBrainz::Server::Report::RecordingTrackDifferentName;
use Moose;

use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );

with 'MusicBrainz::Server::Report::RecordingReport',
     'MusicBrainz::Server::Report::FilterForEditor::RecordingID';

sub statement_timeout { '120s' }

sub query {
    '
        SELECT
            r.id AS recording_id, t.id AS track_id,
            row_number() OVER (ORDER BY r.name COLLATE musicbrainz, t.name COLLATE musicbrainz)
        FROM
            recording r
            JOIN track t 
            ON r.id = t.recording
        WHERE (SELECT COUNT(*) FROM track WHERE recording = r.id) = 1
          AND r.name != t.name
    '
}

sub inflate_rows
{
    my ($self, $items) = @_;

    my $tracks = $self->c->model('Track')->get_by_ids(
        map { $_->{track_id} } @$items
    );

    return [
        map +{
            %$_,
            track => to_json_object($tracks->{ $_->{track_id} }),
        }, @$items
    ];
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;


=head1 COPYRIGHT AND LICENSE

Copyright (C) 2019 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
