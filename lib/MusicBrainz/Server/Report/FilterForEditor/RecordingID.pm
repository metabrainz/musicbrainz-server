package MusicBrainz::Server::Report::FilterForEditor::RecordingID;
use Moose::Role;

with 'MusicBrainz::Server::Report::FilterForEditor';

sub filter_sql {
    my ($self, $editor_id) = @_;

    return (
        'JOIN recording ON recording.id = recording_id
         JOIN artist_credit_name ON recording.artist_credit = artist_credit_name.artist_credit
         JOIN editor_subscribe_artist esa ON esa.artist = artist_credit_name.artist
         WHERE esa.editor = ?',
        $editor_id
    );
}

1;
