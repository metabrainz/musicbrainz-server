package MusicBrainz::Server::Form::Search::Search;
use strict;
use warnings;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler';

use MusicBrainz::Server::Translation qw( l lp );

with 'MusicBrainz::Server::Form::Role::ToJSON';

has_field 'query' => (
    type => 'Text',
    required => 1,
);

has_field 'type' => (
    type => 'Select',
    required => 1
);

has_field 'method' => (
    type => 'Select',
    required => 1,
    default => 'indexed'
);

has_field 'limit' => (
    type                => '+MusicBrainz::Server::Form::Field::Integer',
    input_without_param => 25,
    range_start         => 1,
    range_end           => 100,
);

sub options_type
{
    my @options = (
        'artist'        => l('Artist'),
        'release_group' => l('Release Group'),
        'release'       => l('Release'),
        'recording'     => l('Recording'),
        'work'          => l('Work'),
        'label'         => l('Label'),
        'area'          => l('Area'),
        'place'         => l('Place'),
        'annotation'    => l('Annotation'),
        'cdstub'        => l('CD Stub'),
        'editor'        => l('Editor'),
        'tag'           => lp('Tag', 'noun'),
        'instrument'    => l('Instrument'),
        'series'        => lp('Series', 'singular'),
        'event'         => l('Event'),
    );

    push @options, ( 'doc' => l('Documentation') ) if DBDefs->GOOGLE_CUSTOM_SEARCH;

    return \@options;
}

sub options_method
{
    return [
        'indexed' => l('Indexed search'),
        'advanced' => l('Indexed search with advanced query syntax'),
        'direct' => l('Direct database search')
    ]
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
