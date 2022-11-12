package t::MusicBrainz::Server::Constants;
use strict;
use warnings;

use Test::Routine;
use Test::Deep qw( cmp_bag );

use MusicBrainz::Server::Constants qw( entities_with );

test 'Test entities_with' => sub {
    cmp_bag([entities_with('artist_credits')],
            ['recording', 'release', 'release_group', 'track'],
            'entities_with for artist credits returns all four values');
    cmp_bag([entities_with([['artist_credits'],['mbid', 'relatable']])],
            ['recording', 'release', 'release_group'],
            'entities_with for artist credits + relatable MBID returns proper three values');
};
