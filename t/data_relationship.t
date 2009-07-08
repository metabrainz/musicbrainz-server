use strict;
use warnings;
use Test::More tests => 24;
use_ok 'MusicBrainz::Server::Data::Relationship';
use MusicBrainz::Server::Entity::Artist;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c);

my $rel_data = MusicBrainz::Server::Data::Relationship->new(c => $c);

my $artist1 = MusicBrainz::Server::Entity::Artist->new(id => 8);
my $artist2 = MusicBrainz::Server::Entity::Artist->new(id => 9);
$rel_data->load($artist1, $artist2);

ok( !$rel_data->load() );

is( scalar($artist1->all_relationships), 2 );
is( scalar($artist2->all_relationships), 1 );

my $rel = $artist2->relationships->[0];
is( $rel->link_id, 1 );
isnt( $rel->link, undef );
ok( !$rel->link->has_attribute('additional') );
ok( $rel->link->has_attribute('instrument') );
is( $rel->link->get_attribute('instrument')->[0], 'guitar' );
is( $rel->entity1->name, 'King of the Mountain' );
is( $rel->edits_pending, 1 );

for $rel ($artist1->all_relationships) {
    if ($rel->link_id == 2) {
        isnt( $rel->link, undef );
        ok( $rel->link->has_attribute('additional') );
        is( $rel->link->get_attribute('additional')->[0], 'additional' );
        ok( $rel->link->has_attribute('instrument') );
        is( $rel->link->get_attribute('instrument')->[0], 'string instruments' );
        is( $rel->entity1->name, 'π' );
        is( $rel->edits_pending, 0 );
    }
    else {
        isnt( $rel->link, undef );
        ok( !$rel->link->has_attribute('additional') );
        ok( $rel->link->has_attribute('instrument') );
        is( $rel->link->get_attribute('instrument')->[0], 'guitar' );
        is( $rel->entity1->name, 'King of the Mountain' );
        is( $rel->edits_pending, 0 );
    }
}
