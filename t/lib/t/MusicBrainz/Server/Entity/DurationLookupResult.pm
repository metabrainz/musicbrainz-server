package t::MusicBrainz::Server::Entity::DurationLookupResult;
use Test::Routine;
use Test::Moose;

BEGIN { use MusicBrainz::Server::Entity::DurationLookupResult; }

test all => sub {

my $artist = MusicBrainz::Server::Entity::DurationLookupResult->new();
has_attribute_ok($artist, $_) for qw( distance medium_id medium );

};

1;
