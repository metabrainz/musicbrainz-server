package MusicBrainz::Server::Report::FilterForEditor::SeriesID;
use Moose::Role;
use namespace::autoclean;

with 'MusicBrainz::Server::Report::FilterForEditor';

sub filter_sql {
    my ($self, $editor_id) = @_;

    return (
        'JOIN editor_subscribe_series ess ON ess.series = series_id
         WHERE ess.editor = ?',
        $editor_id
    );
}

1;
