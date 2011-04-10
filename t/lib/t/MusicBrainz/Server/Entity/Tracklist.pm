package t::MusicBrainz::Server::Entity::Tracklist;
use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::Entity::Recording;
use MusicBrainz::Server::Entity::Tracklist;
use MusicBrainz::Server::Entity::Track;

test all => sub {

my $tracklist = MusicBrainz::Server::Entity::Tracklist->new();

my $rec1 = MusicBrainz::Server::Entity::Recording->new(name => 'Recording 1');
my $rec2 = MusicBrainz::Server::Entity::Recording->new(name => 'Recording 2');

$tracklist->add_track(MusicBrainz::Server::Entity::Track->new(position => 1, name => 'Track 1', recording => $rec1));
$tracklist->add_track(MusicBrainz::Server::Entity::Track->new(position => 2, name => 'Track 2', recording => $rec2));
$tracklist->add_track(MusicBrainz::Server::Entity::Track->new(position => 3, name => 'Track 1 (foo)', recording => $rec1));

ok( @{$tracklist->tracks} == 3 );

};

1;
