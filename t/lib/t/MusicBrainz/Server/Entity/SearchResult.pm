package t::MusicBrainz::Server::Entity::SearchResult;
use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::Entity::Artist;

use MusicBrainz::Server::Entity::SearchResult;

test all => sub {

my $searchresult = MusicBrainz::Server::Entity::SearchResult->new();
has_attribute_ok($searchresult, $_) for qw( position score );

my $artist = MusicBrainz::Server::Entity::Artist->new();
$searchresult->entity($artist);
ok( defined $searchresult->entity );

$searchresult->extra( [ $artist ] );
ok( defined $searchresult->extra );

};

1;
