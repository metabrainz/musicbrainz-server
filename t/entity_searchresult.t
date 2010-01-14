use strict;
use warnings;
use Test::More;
use Test::Moose;
use MusicBrainz::Server::Entity::Artist;

use_ok 'MusicBrainz::Server::Entity::SearchResult';

my $searchresult = MusicBrainz::Server::Entity::SearchResult->new();
has_attribute_ok($searchresult, $_) for qw( position score );

my $artist = MusicBrainz::Server::Entity::Artist->new();
$searchresult->entity($artist);
ok( defined $searchresult->entity );

$searchresult->extra( [ $artist ] );
ok( defined $searchresult->extra );

done_testing;
