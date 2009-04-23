use strict;
use warnings;
use Test::More tests => 4;
use_ok 'MusicBrainz::Server::Entity::Track';
use_ok 'MusicBrainz::Server::Entity::Tracklist';
use_ok 'MusicBrainz::Server::Entity::TracklistTrack';

my $tracklist = MusicBrainz::Server::Entity::Tracklist->new();

my $track1 = MusicBrainz::Server::Entity::Track->new(name => 'Track 1');
my $track2 = MusicBrainz::Server::Entity::Track->new(name => 'Track 2');

$tracklist->add_track(MusicBrainz::Server::Entity::TracklistTrack->new(position => 1, name => 'Track 1', track => $track1));
$tracklist->add_track(MusicBrainz::Server::Entity::TracklistTrack->new(position => 2, name => 'Track 2', track => $track2));
$tracklist->add_track(MusicBrainz::Server::Entity::TracklistTrack->new(position => 3, name => 'Track 1 (foo)', track => $track1));

ok( @{$tracklist->tracks} == 3 );
