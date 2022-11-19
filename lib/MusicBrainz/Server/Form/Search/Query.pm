package MusicBrainz::Server::Form::Search::Query;
use strict;
use warnings;

use HTML::FormHandler::Moose;
extends 'MusicBrainz::Server::Form';

has '+name' => ( default => 'search-query' );

has_field 'query' => (
    type => 'Text',
    required => 1
);

1;
