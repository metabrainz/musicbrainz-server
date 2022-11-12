package t::MusicBrainz::Server::Entity::SearchResult;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::Entity::Artist;
use MusicBrainz::Server::Entity::Release;


use MusicBrainz::Server::Entity::SearchResult;

test all => sub {

my $searchresult = MusicBrainz::Server::Entity::SearchResult->new();
has_attribute_ok($searchresult, $_) for qw( position score );

my $artist = MusicBrainz::Server::Entity::Artist->new();
$searchresult->entity($artist);
ok( defined $searchresult->entity );

my $release = MusicBrainz::Server::Entity::Release->new();
$searchresult->extra( [{
    release => $release,
    track_position      => 1,
    medium_position     => 1,
    medium_track_count  => 1,
}] );
ok( defined $searchresult->extra );

};

1;
