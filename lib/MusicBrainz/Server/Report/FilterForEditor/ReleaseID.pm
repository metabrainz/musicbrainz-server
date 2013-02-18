package MusicBrainz::Server::Report::FilterForEditor::ReleaseID;
use Moose::Role;

with 'MusicBrainz::Server::Report::FilterForEditor';

sub filter_sql {
    my ($self, $editor_id) = @_;

    return (
        "JOIN release ON release.id = release_id
         JOIN artist_credit_name ON release.artist_credit = artist_credit_name.artist_credit
         JOIN release_label ON release_label.release = release.id
         LEFT JOIN editor_subscribe_artist esa ON esa.artist = artist_credit_name.artist
         LEFT JOIN editor_subscribe_label esl ON esl.label = release_label.label
         WHERE (esa.editor IS NOT DISTINCT FROM ?) OR (esl.editor IS NOT DISTINCT FROM ?)",
        $editor_id, $editor_id
    );
}

1;
