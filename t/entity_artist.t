use strict;
use warnings;
use Test::More tests => 11;
use_ok 'MusicBrainz::Server::Entity::Artist';
use_ok 'MusicBrainz::Server::Entity::ArtistType';
use_ok 'MusicBrainz::Server::Entity::ArtistAlias';

my $artist = MusicBrainz::Server::Entity::Artist->new();
ok( defined $artist->begin_date );
ok( $artist->begin_date->is_empty );
ok( defined $artist->end_date );
ok( $artist->end_date->is_empty );

is( $artist->type_name, undef );
$artist->type(MusicBrainz::Server::Entity::ArtistType->new(id => 1, name => 'Person'));
is( $artist->type_name, 'Person' );
is( $artist->type->id, 1 );
is( $artist->type->name, 'Person' );
