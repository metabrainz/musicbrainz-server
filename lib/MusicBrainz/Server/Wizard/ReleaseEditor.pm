package MusicBrainz::Server::Wizard::ReleaseEditor;
use Moose;
use HTML::FormHandler;

extends 'MusicBrainz::Server::Wizard';

has '+name' => ( default => 'release_editor' );

sub pages
{
    return [
        {
            name => 'information',
            title => 'Release Information',
            template => 'release/edit/information.tt',
            form => 'ReleaseEditor::Information'
        },
        {
            name => 'tracklist',
            title => 'Tracklist',
            template => 'release/edit/tracklist.tt',
            form => 'ReleaseEditor::Tracklist'
        },
        {
            name => 'preview',
            title => 'Preview',
            template => 'release/edit/preview.tt',
            form => 'ReleaseEditor::Preview'
        },
        {
            name => 'editnote',
            title => 'Edit Note',
            template => 'release/edit/editnote.tt',
            form => 'ReleaseEditor::EditNote'
        },
    ];
}

sub skip
{
    my ($self, $page) = @_;

    return 0;
}

1;
