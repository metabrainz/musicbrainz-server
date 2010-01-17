#!/usr/bin/perl
use strict;
use warnings;
use Sql;
use Test::More;
use_ok 'MusicBrainz::Server::Data::Relationship';
use MusicBrainz::Server::Entity::Artist;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+relationships');

my $rel_data = $c->model('Relationship');

my $artist1 = MusicBrainz::Server::Entity::Artist->new(id => 1);
my $artist2 = MusicBrainz::Server::Entity::Artist->new(id => 2);
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
is( $rel->entity1->name, 'Track 1' );
is( $rel->edits_pending, 1 );

for $rel ($artist1->all_relationships) {
    if ($rel->link_id == 2) {
        isnt( $rel->link, undef );
        ok( $rel->link->has_attribute('additional') );
        is( $rel->link->get_attribute('additional')->[0], 'additional' );
        ok( $rel->link->has_attribute('instrument') );
        is( $rel->link->get_attribute('instrument')->[0], 'string instruments' );
        is( $rel->entity1->name, 'Track 2' );
        is( $rel->edits_pending, 0 );
    }
    else {
        isnt( $rel->link, undef );
        ok( !$rel->link->has_attribute('additional') );
        ok( $rel->link->has_attribute('instrument') );
        is( $rel->link->get_attribute('instrument')->[0], 'guitar' );
        is( $rel->entity1->name, 'Track 1' );
        is( $rel->edits_pending, 0 );
    }
}

my $sql = Sql->new($c->dbh);
$sql->begin;
$sql->do("INSERT INTO l_artist_recording (id, link, entity0, entity1) VALUES (4, 1, 2, 2)");
# Merge ARs for artist #2 to #1
$rel_data->merge_entities('artist', 1, 2);
$sql->commit;

$artist1->clear_relationships;
$artist2->clear_relationships;
$rel_data->load($artist1, $artist2);
# One duplicate AR was deleted, one was moved
is( scalar($artist1->all_relationships), 3 );
# Nothing left here
is( scalar($artist2->all_relationships), 0 );

$sql->begin;
# Delete artist-recording AR with ID 4
$rel_data->delete('artist', 'recording', 4);
$sql->commit;

$artist1->clear_relationships;
$rel_data->load($artist1);
is( scalar($artist1->all_relationships), 2 );

$sql->begin;
# Delete ARs for artist #2
$rel_data->delete_entities('artist', 1);
$sql->commit;

$artist1->clear_relationships;
$rel_data->load($artist1);
is( scalar($artist1->all_relationships), 0, 'Relationship->delete deleted all ARs' );

$sql->begin;
$rel = $rel_data->insert('artist', 'recording', {
    link_type_id => 1,
    begin_date => { year => 2008, month => 2, day => 3 },
    end_date => { year => 2008, month => 2, day => 8 },
    attributes => [ 1, 3, 4 ],
    entity0_id => 1,
    entity1_id => 1
});
$sql->commit;
is($rel->id, 100);

$artist1->clear_relationships;
$rel_data->load_subset([ 'artist' ], $artist1);
is(scalar($artist1->all_relationships), 0);

$artist1->clear_relationships;
$rel_data->load_subset([ 'recording' ], $artist1);
is(scalar($artist1->all_relationships), 1);

$artist1->clear_relationships;
$rel_data->load($artist1);
is(scalar($artist1->all_relationships), 1);

$rel = $artist1->relationships->[0];
is($rel->id, 100);
is($rel->link->id, 100);
is_deeply($rel->link->begin_date, { year => 2008, month => 2, day => 3 });
is_deeply($rel->link->end_date, { year => 2008, month => 2, day => 8 });
is($rel->phrase, 'performed additional guitar and string instruments on');

$sql->begin;
$rel_data->update('artist', 'recording', 100, {
    link_type_id => 1,
    begin_date => undef,
    end_date => undef,
    attributes => [ 3 ],
    entity0_id => 1,
    entity1_id => 1
});
$sql->commit;

$artist1->clear_relationships;
$rel_data->load($artist1);
is(scalar($artist1->all_relationships), 1);

$rel = $artist1->relationships->[0];
is($rel->id, 100);
is($rel->link->id, 101);
is_deeply($rel->link->begin_date, { });
is_deeply($rel->link->end_date, { });
is($rel->phrase, 'performed string instruments on');

$rel = $rel_data->get_by_id('artist', 'recording', 100);
is($rel->edits_pending, 0);
is_deeply(
    $rel_data->get_by_ids('artist', 'recording', 100),
    {
        100 => $rel
    });

$sql->begin;
$rel_data->adjust_edit_pending('artist', 'recording', +1, 100);
$sql->commit;

$rel = $rel_data->get_by_id('artist', 'recording', 100);
is($rel->edits_pending, 1);

$sql->begin;
$rel_data->adjust_edit_pending('artist', 'recording', -1, 100);
$sql->commit;

$rel = $rel_data->get_by_id('artist', 'recording', 100);
is($rel->edits_pending, 0);

done_testing;
