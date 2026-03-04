package MusicBrainz::Server::Report::FilterForEditor::RecordingID;
use Moose::Role;
use namespace::autoclean;

with 'MusicBrainz::Server::Report::FilterForEditor';

sub filter_sql {
    my ($self, $editor_id) = @_;

    return (
        'JOIN recording ON recording.id = recording_id
         JOIN artist_credit_name acn ON recording.artist_credit = acn.artist_credit
         JOIN artist a ON acn.artist = a.id
         JOIN (
             SELECT a2.name AS artist_name, r2.name AS recording_name
             FROM recording r2
             JOIN artist_credit_name acn2 ON r2.artist_credit = acn2.artist_credit
             JOIN artist a2 ON acn2.artist = a2.id
             JOIN editor_subscribe_artist esa ON esa.artist = a2.id
             WHERE esa.editor = ?
             GROUP BY a2.name, r2.name
         ) AS subscribed_items ON a.name = subscribed_items.artist_name
                               AND recording.name = subscribed_items.recording_name',
        $editor_id,
    );
}

1;
