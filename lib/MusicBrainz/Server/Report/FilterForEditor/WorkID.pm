package MusicBrainz::Server::Report::FilterForEditor::WorkID;
use Moose::Role;

with 'MusicBrainz::Server::Report::FilterForEditor';

sub filter_sql {
    my ($self, $editor_id) = @_;

    return (
        "JOIN l_artist_work ON l_artist_work.entity1 = work_id
         JOIN editor_subscribe_artist esa ON esa.artist = l_artist_work.entity0
         WHERE esa.editor = ?",
        $editor_id
    );
}

1;
