package MusicBrainz::Server::Form::Search::Artist;

use base 'MusicBrainz::Server::Form';

use strict;
use warnings;

sub profile
{
    return {
        required => {
            query => 'Text',
        },
    };
}

1;
