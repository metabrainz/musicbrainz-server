package MusicBrainz::Server::Form::ReleaseEditor::MissingEntities;
use HTML::FormHandler::Moose;

extends 'MusicBrainz::Server::Form::Step';

#for my $type (qw( artist label )) {
    has_field 'artists' => (
        type => 'Repeatable',
        required => 1
    );

    has_field 'artists.name' => (
        type => 'Text',
        required => 1
    );

    has_field 'artists.sort_name' => (
        type => 'Text',
        required => 1
    );

    has_field 'artists.comment' => (
        type => 'Text',
        required => 1
    );
#}

1;
