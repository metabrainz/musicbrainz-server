use strict;
use warnings;
use Test::More tests => 4;
use_ok 'MusicBrainz::Server::Entity::Track';

my $track = MusicBrainz::Server::Entity::Track->new(id => 1, name => 'Track 1');

is ( $track->id, 1 );
is ( $track->name, 'Track 1' );

$track->edits_pending(2);
is( $track->edits_pending, 2 );
