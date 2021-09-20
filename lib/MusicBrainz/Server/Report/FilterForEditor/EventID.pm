package MusicBrainz::Server::Report::FilterForEditor::EventID;
use Moose::Role;

with 'MusicBrainz::Server::Report::FilterForEditor';

sub filter_sql {
    my ($self, $editor_id) = @_;

    return (
        'JOIN l_artist_event ON l_artist_event.entity1 = event_id
         JOIN editor_subscribe_artist esa ON esa.artist = l_artist_event.entity0
         WHERE esa.editor = ?',
        $editor_id
    );
}

1;
