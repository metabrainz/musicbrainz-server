package MusicBrainz::Server::Form::Search::Search;
use HTML::FormHandler::Moose;
extends 'HTML::FormHandler';

use MusicBrainz::Server::Translation qw( l );

has_field 'query' => (
    type => 'Text',
    required => 1,
);

has_field 'type' => (
    type => 'Select',
    required => 1
);

has_field 'direct' => (
    type => 'Boolean',
);

has_field 'advanced' => (
    type => 'Boolean',
);

has_field 'limit' => (
    type                => '+MusicBrainz::Server::Form::Field::Integer',
    input_without_param => 25,
    range_start         => 1,
    range_end           => 100,
);

sub options_type
{
    return [
        'all'           => l('All'),
        'artist'        => l('Artist'),
        'release_group' => l('Release Group'),
        'release'       => l('Release'),
        'recording'     => l('Recording'),
        'work'          => l('Work'),
        'label'         => l('Label'),
        'annotation'    => l('Annotation'),
        'cdstub'        => l('CD Stub'),
        'editor'        => l('Editor'),
        'freedb'        => l('FreeDB'),
        'tag'           => l('Tag'),
    ];
}

1;
