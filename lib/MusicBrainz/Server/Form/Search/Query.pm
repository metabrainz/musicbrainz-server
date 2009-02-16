package MusicBrainz::Server::Form::Search::Query;

use base 'MusicBrainz::Server::Form';

use strict;
use warnings;

sub name { 'search-query' }

sub profile
{
    return {
        required => {
            query => 'Text',
        },
    };
}

1;
