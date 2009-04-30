use strict;
use warnings;
use Test::More tests => 4;
use_ok 'MusicBrainz::Server::Entity::Recording';
use_ok 'MusicBrainz::Server::Entity::Tracklist';
use_ok 'MusicBrainz::Server::Entity::Track';

my $tracklist = MusicBrainz::Server::Entity::Tracklist->new();

my $rec1 = MusicBrainz::Server::Entity::Recording->new(name => 'Recording 1');
my $rec2 = MusicBrainz::Server::Entity::Recording->new(name => 'Recording 2');

$tracklist->add_track(MusicBrainz::Server::Entity::Track->new(position => 1, name => 'Track 1', recording => $rec1));
$tracklist->add_track(MusicBrainz::Server::Entity::Track->new(position => 2, name => 'Track 2', recording => $rec2));
$tracklist->add_track(MusicBrainz::Server::Entity::Track->new(position => 3, name => 'Track 1 (foo)', recording => $rec1));

ok( @{$tracklist->tracks} == 3 );
