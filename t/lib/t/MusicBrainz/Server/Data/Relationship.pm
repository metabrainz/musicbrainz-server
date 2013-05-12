package t::MusicBrainz::Server::Data::Relationship;
use Test::Routine;
use Test::Moose;
use Test::More;

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

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+relationship_merging');
    MusicBrainz::Server::Test->prepare_test_database($c, <<'EOSQL');
INSERT INTO l_label_label (id, link, entity0, entity1)
    VALUES (1, 1, 2, 3), (2, 1, 1, 3);
EOSQL

    $c->model('Relationship')->merge_entities('label', 1, 2, 3);

    my $label = $c->model('Label')->get_by_id(1);
    $c->model('Relationship')->load($label);
    is (scalar($label->all_relationships) => 0, 'no relationships remain');
};

test 'Merge matching dated/undated rels on entity merge' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+relationship_merging');
    MusicBrainz::Server::Test->prepare_test_database($c, <<'EOSQL');
INSERT INTO l_label_label (id, link, entity0, entity1)
    VALUES (1, 1, 2, 3), (2, 2, 1, 3);
EOSQL

    $c->model('Relationship')->merge_entities('label', 1, 2);

    my $label = $c->model('Label')->get_by_id(1);
    $c->model('Relationship')->load($label);
    is (scalar($label->all_relationships) => 1, 'two relationships became one');
};

test 'Merge matching dated/undated rels on entity merge (3 entities)' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+relationship_merging');
    MusicBrainz::Server::Test->prepare_test_database($c, <<'EOSQL');
INSERT INTO label (id, name, sort_name, gid, comment)
    VALUES (4, 3, 3, 'e2a083a9-0042-4f8e-b4d2-8396350b95f7', 'label 4');
INSERT INTO l_label_label (id, link, entity0, entity1)
    VALUES (1, 1, 2, 3), (2, 2, 1, 3), (3, 2, 4, 3);
EOSQL

    $c->model('Relationship')->merge_entities('label', 1, 2);

    my $label = $c->model('Label')->get_by_id(1);
    $c->model('Relationship')->load($label);
    is (scalar($label->all_relationships) => 1, 'three relationships became one');
};

test 'Merge matching dated/undated rels on entity merge (3 entities, some flipped direction)' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+relationship_merging');
    MusicBrainz::Server::Test->prepare_test_database($c, <<'EOSQL');
INSERT INTO label (id, name, sort_name, gid, comment)
    VALUES (4, 3, 3, 'e2a083a9-0042-4f8e-b4d2-8396350b95f7', 'label 4');
INSERT INTO l_label_label (id, link, entity0, entity1)
    VALUES (1, 1, 2, 3), (2, 2, 3, 1), (3, 2, 3, 4);
EOSQL

    $c->model('Relationship')->merge_entities('label', 1, 2);

    my $label = $c->model('Label')->get_by_id(1);
    $c->model('Relationship')->load($label);
    is (scalar($label->all_relationships) => 2, 'three relationships became two (alternate directions should be preserved)');
};

test 'Don\'t merge matching dated/undated rels on entity merge if they originate from the same entity' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+relationship_merging');
    MusicBrainz::Server::Test->prepare_test_database($c, <<'EOSQL');
INSERT INTO l_label_label (id, link, entity0, entity1)
    VALUES (1, 1, 2, 3), (2, 2, 1, 3), (3, 1, 1, 3);
EOSQL

    $c->model('Relationship')->merge_entities('label', 1, 2);

    my $label = $c->model('Label')->get_by_id(1);
    $c->model('Relationship')->load($label);
    is (scalar($label->all_relationships) => 2, 'three relationships, two on the same entity dated vs. undated, became two');
};

test 'Don\'t merge matching rels, other than attributes' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+relationship_merging');
    MusicBrainz::Server::Test->prepare_test_database($c, <<'EOSQL');
INSERT INTO l_artist_artist (id, link, entity0, entity1)
    VALUES (1, 3, 2, 3), (2, 4, 1, 3);
EOSQL

    $c->model('Relationship')->merge_entities('artist', 1, 2);

    my $artist = $c->model('Artist')->get_by_id(1);
    $c->model('Relationship')->load($artist);
    is (scalar($artist->all_relationships) => 2, 'two relationships that are the same other than attributes are not merged');
};

test all => sub {

my $test = shift;
MusicBrainz::Server::Test->prepare_test_database($test->c, '+relationships');

my $rel_data = $test->c->model('Relationship');

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
is(scalar($artist1->all_relationships), 0, 'filter to just artist rels');

$artist1->clear_relationships;
$rel_data->load_subset([ 'recording' ], $artist1);
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
    ended => 0,
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
is($rel->phrase, 'performed string instruments on', 'phrase');

$rel = $rel_data->get_by_id('artist', 'recording', 100);
is($rel->edits_pending, 0);

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

};

1;
