package t::MusicBrainz::Server::Entity::Artist;
use Test::Routine;
use Test::Moose;
use Test::More;

use Hook::LexWrap;
use MusicBrainz::Server::Entity::Artist;
use MusicBrainz::Server::Entity::ArtistType;
use MusicBrainz::Server::Entity::ArtistAlias;

use MusicBrainz::Server::Constants qw( $DARTIST_ID $VARTIST_ID $VARTIST_GID );

test all => sub {

my $artist = MusicBrainz::Server::Entity::Artist->new();
ok( defined $artist->begin_date );
ok( $artist->begin_date->is_empty );
ok( defined $artist->end_date );
ok( $artist->end_date->is_empty );

is( $artist->type_name, undef );
is( $artist->last_updated , undef );
$artist->type(MusicBrainz::Server::Entity::ArtistType->new(id => 1, name => 'Person'));
is( $artist->type_name, 'Person' );
is( $artist->type->id, 1 );
is( $artist->type->name, 'Person' );

$artist->edits_pending(2);
is( $artist->edits_pending, 2 );

ok(MusicBrainz::Server::Entity::Artist->new( id => $DARTIST_ID )->is_special_purpose);
ok(MusicBrainz::Server::Entity::Artist->new( id => $VARTIST_ID )->is_special_purpose);
ok(MusicBrainz::Server::Entity::Artist->new( gid => $VARTIST_GID )->is_special_purpose);
ok(!MusicBrainz::Server::Entity::Artist->new( id => 5 )->is_special_purpose);
ok(!MusicBrainz::Server::Entity::Artist->new( gid => '7527f6c2-d762-4b88-b5e2-9244f1e34c46' )->is_special_purpose);

};

1;
