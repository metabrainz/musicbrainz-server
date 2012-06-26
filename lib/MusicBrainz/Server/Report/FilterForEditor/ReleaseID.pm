package MusicBrainz::Server::Report::FilterForEditor::ReleaseID;
use Moose::Role;

with 'MusicBrainz::Server::Report::FilterForEditor';

sub filter_sql {
    my ($self, $editor_id) = @_;

    return (
        "JOIN release ON release.id = release_id
         JOIN artist_credit_name ON release.artist_credit = artist_credit_name.artist_credit
         JOIN editor_subscribe_artist esa ON esa.artist = artist_credit_name.artist
         WHERE esa.editor = ?",
        $editor_id
    );
}

1;
