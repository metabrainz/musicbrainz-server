use strict;
use warnings;
use Test::More tests => 4;
use_ok 'MusicBrainz::Server::Entity::Recording';

my $rec = MusicBrainz::Server::Entity::Recording->new(id => 1, name => 'Recording 1');

is ( $rec->id, 1 );
is ( $rec->name, 'Recording 1' );

$rec->edits_pending(2);
is( $rec->edits_pending, 2 );
