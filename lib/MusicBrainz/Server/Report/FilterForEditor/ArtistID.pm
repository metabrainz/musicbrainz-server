package MusicBrainz::Server::Report::FilterForEditor::ArtistID;
use Moose::Role;
use namespace::autoclean;

with 'MusicBrainz::Server::Report::FilterForEditor';

sub filter_sql {
    my ($self, $editor_id) = @_;

    return (
        'JOIN editor_subscribe_artist esa ON esa.artist = report.artist_id
         WHERE esa.editor = ?',
        $editor_id
    );
}

1;
