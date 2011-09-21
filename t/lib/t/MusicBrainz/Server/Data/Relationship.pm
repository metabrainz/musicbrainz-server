package t::MusicBrainz::Server::Data::Relationship;
use Test::Routine;
use Test::Moose;
use Test::More;
use Test::Memory::Cycle;

use MusicBrainz::Server::Data::Relationship;
use MusicBrainz::Server::Entity::Artist;
use MusicBrainz::Server::Entity::Recording;
use MusicBrainz::Server::Entity::Relationship;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;

with 't::Context';

test 'Relationships between merged entities' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, <<'EOSQL');
INSERT INTO label_name (id, name) VALUES (1, 'A'), (2, 'B'), (3, 'C');
INSERT INTO label (id, name, sort_name, gid)
    VALUES (1, 1, 1, '9b335b20-5f88-11e0-80e3-0800200c9a66'),
           (2, 2, 2, 'a2b31070-5f88-11e0-80e3-0800200c9a66'),
           (3, 3, 3, 'a9de8b40-5f88-11e0-80e3-0800200c9a66');

INSERT INTO link_type (id, entity_type0, entity_type1, name, gid, link_phrase,
                       short_link_phrase, reverse_link_phrase)
    VALUES (1, 'label', 'label', 'label AR', 'ff68bcc0-5f88-11e0-80e3-0800200c9a66',
            'phrase', 'short', 'reverse');
INSERT INTO link (id, link_type) VALUES (1, 1);

INSERT INTO l_label_label (id, link, entity0, entity1)
    VALUES (1, 1, 2, 3), (2, 1, 1, 3);
EOSQL

    $c->model('Relationship')->merge_entities('label', 1, 2, 3);

    my $label = $c->model('Label')->get_by_id(1);
    $c->model('Relationship')->load($label);
    is (scalar($label->all_relationships) => 0);
};

test all => sub {

my $test = shift;
MusicBrainz::Server::Test->prepare_test_database($test->c, '+relationships');

my $rel_data = $test->c->model('Relationship');
memory_cycle_ok($rel_data);

my $artist1 = MusicBrainz::Server::Entity::Artist->new(id => 1);
my $artist2 = MusicBrainz::Server::Entity::Artist->new(id => 2);
$rel_data->load($artist1, $artist2);
memory_cycle_ok($rel_data);
memory_cycle_ok($artist1);
memory_cycle_ok($artist2);

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
is( $rel->direction, $MusicBrainz::Server::Entity::Relationship::DIRECTION_FORWARD );

for $rel ($artist1->all_relationships) {
    if ($rel->link_id == 2) {
        isnt( $rel->link, undef );
        ok( $rel->link->has_attribute('additional') );
        is( $rel->link->get_attribute('additional')->[0], 'additional' );
        ok( $rel->link->has_attribute('instrument') );
        is( $rel->link->get_attribute('instrument')->[0], 'string instruments' );
        is( $rel->entity1->name, 'Track 2' );
        is( $rel->edits_pending, 0 );
        is( $rel->direction, $MusicBrainz::Server::Entity::Relationship::DIRECTION_FORWARD );
    }
    else {
        isnt( $rel->link, undef );
        ok( !$rel->link->has_attribute('additional') );
        ok( $rel->link->has_attribute('instrument') );
        is( $rel->link->get_attribute('instrument')->[0], 'guitar' );
        is( $rel->entity1->name, 'Track 1' );
        is( $rel->edits_pending, 0 );
        is( $rel->direction, $MusicBrainz::Server::Entity::Relationship::DIRECTION_FORWARD );
    }
}

my $recording1 = MusicBrainz::Server::Entity::Recording->new(id => 1);
$rel_data->load($recording1);
is( scalar($recording1->all_relationships), 2 );
is( $recording1->relationships->[0]->direction, $MusicBrainz::Server::Entity::Relationship::DIRECTION_BACKWARD );
is( $recording1->relationships->[1]->direction, $MusicBrainz::Server::Entity::Relationship::DIRECTION_BACKWARD );

my $sql = $test->c->sql;
$sql->begin;
$sql->do("INSERT INTO l_artist_recording (id, link, entity0, entity1) VALUES (4, 1, 2, 2)");
# Merge ARs for artist #2 to #1
$rel_data->merge_entities('artist', 1, 2);
memory_cycle_ok($rel_data);
$test->c->sql->commit;

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
memory_cycle_ok($rel_data);
$sql->commit;

$artist1->clear_relationships;
$rel_data->load($artist1);
is( scalar($artist1->all_relationships), 2 );

$sql->begin;
# Delete ARs for artist #2
$rel_data->delete_entities('artist', 1);
memory_cycle_ok($rel_data);
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
memory_cycle_ok($rel_data);
$sql->commit;
is($rel->id, 100);

$artist1->clear_relationships;
$rel_data->load_subset([ 'artist' ], $artist1);
memory_cycle_ok($rel_data);
is(scalar($artist1->all_relationships), 0, 'filter to just artist rels');

$artist1->clear_relationships;
$rel_data->load_subset([ 'recording' ], $artist1);
memory_cycle_ok($rel_data);
is(scalar($artist1->all_relationships), 1, 'filter to just recording rels');

$artist1->clear_relationships;
$rel_data->load($artist1);
is(scalar($artist1->all_relationships), 1, 'allow all rels');

$rel = $artist1->relationships->[0];
is($rel->id, 100);
is($rel->link->id, 100);
is_deeply($rel->link->begin_date, { year => 2008, month => 2, day => 3 });
is_deeply($rel->link->end_date, { year => 2008, month => 2, day => 8 });
is($rel->phrase, 'performed Additional guitar and string instruments on');

$sql->begin;
$rel_data->update('artist', 'recording', 100, {
    link_type_id => 1,
    begin_date => undef,
    end_date => undef,
    attributes => [ 3 ],
    entity0_id => 1,
    entity1_id => 1
});
memory_cycle_ok($rel_data);
$sql->commit;

$artist1->clear_relationships;
$rel_data->load($artist1);
is(scalar($artist1->all_relationships), 1);

$rel = $artist1->relationships->[0];
is($rel->id, 100);
is($rel->link->id, 101);
is_deeply($rel->link->begin_date, { });
is_deeply($rel->link->end_date, { });
is($rel->phrase, 'performed string instruments on', 'phrase');

$rel = $rel_data->get_by_id('artist', 'recording', 100);
is($rel->edits_pending, 0);

$sql->begin;
$rel_data->adjust_edit_pending('artist', 'recording', +1, 100);
memory_cycle_ok($rel_data);
$sql->commit;

$rel = $rel_data->get_by_id('artist', 'recording', 100);
is($rel->edits_pending, 1);

$sql->begin;
$rel_data->adjust_edit_pending('artist', 'recording', -1, 100);
$sql->commit;

$rel = $rel_data->get_by_id('artist', 'recording', 100);
is($rel->edits_pending, 0);

};

1;
