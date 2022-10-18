package MusicBrainz::Server::Report::FilterForEditor::LabelID;
use Moose::Role;
use namespace::autoclean;

with 'MusicBrainz::Server::Report::FilterForEditor';

sub filter_sql {
    my ($self, $editor_id) = @_;

    return (
        'JOIN editor_subscribe_label esl ON esl.label = label_id
         WHERE esl.editor = ?',
        $editor_id
    );
}

1;
