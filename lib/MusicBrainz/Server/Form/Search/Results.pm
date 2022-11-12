package MusicBrainz::Server::Form::Search::Results;
use strict;
use warnings;

use HTML::FormHandler::Moose;
extends 'MusicBrainz::Server::Form';

has '+name' => ( default => 'results' );

has_field 'selected_id' => (
    type => '+MusicBrainz::Server::Form::Field::Integer',
    required => 1,
);

1;
