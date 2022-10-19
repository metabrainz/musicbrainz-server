package t::MusicBrainz::Server::Entity::Work;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::Entity::Work;
use MusicBrainz::Server::Entity::WorkType;
use MusicBrainz::Server::Entity::WorkAlias;

test all => sub {

my $work = MusicBrainz::Server::Entity::Work->new();

is( $work->type_name, undef );
$work->type(MusicBrainz::Server::Entity::WorkType->new(id => 1, name => 'Composition'));
is( $work->type_name, 'Composition' );

$work->edits_pending(2);
is( $work->edits_pending, 2 );

};

1;
