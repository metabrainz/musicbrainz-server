package t::MusicBrainz::Server::Entity::Recording;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::Entity::Recording;

test all => sub {

my $rec = MusicBrainz::Server::Entity::Recording->new(id => 1, name => 'Recording 1');

is ( $rec->id, 1 );
is ( $rec->name, 'Recording 1' );

$rec->edits_pending(2);
is( $rec->edits_pending, 2 );

};

1;
