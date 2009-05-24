package MusicBrainz::Server::Form::Search::Direct;
use HTML::FormHandler::Moose;
extends 'HTML::FormHandler';

has_field 'query' => (
    type => 'Text',
    required => 1,
);

has_field 'type' => (
    type => 'Multiple',
    required => 1
);

sub options_type
{
    return [
        'artist'        => 'Artist',
        'label'         => 'Label',
        'recording'     => 'Recording',
        'release'       => 'Release',
        'release_group' => 'Release Group',
        'work'          => 'Work',
    ];
}

1;
