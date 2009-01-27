package MusicBrainz::Server::Form::Search::Simple;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form';

sub name { 'simple-search' }

sub profile {
    return {
        required => {
            type => 'Select',
            query => 'Text'
        }
    }
}

sub options_type {
    map { lc $_ => $_ } qw(Artist Label Release Track Editor);
}

1;
