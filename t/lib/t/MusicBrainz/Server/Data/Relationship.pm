package t::MusicBrainz::Server::Data::Relationship;
use List::UtilsBy qw( nsort_by );

use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::Constants qw( :direction );
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
    MusicBrainz::Server::Test->prepare_test_database($c, <<~'EOSQL');
        INSERT INTO l_label_label (id, link, entity0, entity1)
            VALUES (1, 1, 2, 3), (2, 1, 1, 3);
        EOSQL

    $c->model('Relationship')->merge_entities('label', 1, [2, 3]);

    my $label = $c->model('Label')->get_by_id(1);
    $c->model('Relationship')->load($label);
    is(scalar($label->all_relationships) => 0, 'no relationships remain');
};

test 'Merge matching dated/undated rels on entity merge' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+relationship_merging');
    MusicBrainz::Server::Test->prepare_test_database($c, <<~'EOSQL');
        INSERT INTO l_label_label (id, link, entity0, entity1)
            VALUES (1, 1, 2, 3), (2, 2, 1, 3);
        EOSQL

    $c->model('Relationship')->merge_entities('label', 1, [2]);

    my $label = $c->model('Label')->get_by_id(1);
    $c->model('Relationship')->load($label);
    is(scalar($label->all_relationships) => 1, 'two relationships became one');
};

test 'Merge matching dated/undated rels on entity merge (3 entities)' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+relationship_merging');
    MusicBrainz::Server::Test->prepare_test_database($c, <<~'EOSQL');
        INSERT INTO label (id, name, gid, comment)
            VALUES (4, 3, 'e2a083a9-0042-4f8e-b4d2-8396350b95f7', 'label 4');
        INSERT INTO l_label_label (id, link, entity0, entity1)
            VALUES (1, 1, 2, 3), (2, 2, 1, 3), (3, 2, 4, 3);
        EOSQL

    $c->model('Relationship')->merge_entities('label', 1, [2]);

    my $label = $c->model('Label')->get_by_id(1);
    $c->model('Relationship')->load($label);
    is(scalar($label->all_relationships) => 1, 'three relationships became one');
};

test 'Merge matching dated/undated rels on entity merge (3 entities, some flipped direction)' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+relationship_merging');
    MusicBrainz::Server::Test->prepare_test_database($c, <<~'EOSQL');
        INSERT INTO label (id, name, gid, comment)
            VALUES (4, 3, 'e2a083a9-0042-4f8e-b4d2-8396350b95f7', 'label 4');
        INSERT INTO l_label_label (id, link, entity0, entity1)
            VALUES (1, 1, 2, 3), (2, 2, 3, 1), (3, 2, 3, 4);
        EOSQL

    $c->model('Relationship')->merge_entities('label', 1, [2]);

    my $label = $c->model('Label')->get_by_id(1);
    $c->model('Relationship')->load($label);
    is(scalar($label->all_relationships) => 2, 'three relationships became two (alternate directions should be preserved)');
};

test 'Merge matching undated rels on entity merge' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+relationship_merging');
    MusicBrainz::Server::Test->prepare_test_database($c, <<~'EOSQL');
        INSERT INTO l_label_label (id, link, entity0, entity1)
            VALUES (1, 1, 1, 3), (2, 1, 2, 3);
        EOSQL

    $c->model('Relationship')->merge_entities('label', 1, [2]);

    my $label = $c->model('Label')->get_by_id(1);
    $c->model('Relationship')->load($label);
    is(scalar($label->all_relationships) => 1, 'two relationships became one');
};

test 'Don\'t merge matching dated/undated rels on entity merge if they originate from the same entity' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+relationship_merging');
    MusicBrainz::Server::Test->prepare_test_database($c, <<~'EOSQL');
        INSERT INTO l_label_label (id, link, entity0, entity1)
            VALUES (1, 1, 2, 3), (2, 2, 1, 3), (3, 1, 1, 3);
        EOSQL

    $c->model('Relationship')->merge_entities('label', 1, [2]);

    my $label = $c->model('Label')->get_by_id(1);
    $c->model('Relationship')->load($label);
    is(scalar($label->all_relationships) => 2, 'three relationships, two on the same entity dated vs. undated, became two');
};

test 'Don\'t merge matching rels, other than attributes' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+relationship_merging');
    MusicBrainz::Server::Test->prepare_test_database($c, <<~'EOSQL');
        INSERT INTO l_artist_artist (id, link, entity0, entity1)
            VALUES (1, 3, 2, 3), (2, 4, 1, 3);
        EOSQL

    $c->model('Relationship')->merge_entities('artist', 1, [2]);

    my $artist = $c->model('Artist')->get_by_id(1);
    $c->model('Relationship')->load($artist);
    is(scalar($artist->all_relationships) => 2, 'two relationships that are the same other than attributes are not merged');
};

test 'Don\'t merge matching rels, other than link_order' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+relationship_merging');
    MusicBrainz::Server::Test->prepare_test_database($c, <<~'EOSQL');
        INSERT INTO l_artist_artist (id, link, link_order, entity0, entity1)
            VALUES (1, 1, 1, 2, 3), (2, 1, 2, 1, 3);
        EOSQL

    $c->model('Relationship')->merge_entities('artist', 1, [2]);

    my $artist = $c->model('Artist')->get_by_id(1);
    $c->model('Relationship')->load($artist);
    is(scalar($artist->all_relationships) => 2, 'two relationships that are the same other than link orders are not merged');
};

test 'Don\'t consider relationships with different link orders to be the same' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+relationships');

    my $exists = $c->model('Relationship')->exists('artist', 'recording', {
        entity0_id => 1,
        entity1_id => 1,
        link_order => 1,
        link_type_id => 148,
        attributes => [{ type => { id => 4 } }],
    });

    ok(!$exists, 'relationship with different link order is not the same');
};

test 'Entity credits are merged' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+relationship_merging');
    MusicBrainz::Server::Test->prepare_test_database($c, <<~'EOSQL');
        INSERT INTO label (id, name, gid)
            VALUES (4, 'D', '71a79efe-ab55-4a5a-a221-72062f5acb2f'),
                   (5, 'E', '36df2c0e-c56d-43e5-a031-4049480c5a40'),
                   (6, 'F', '2db8bc79-d7ec-4be5-9abe-2df3d59ead57'),
                   (7, 'G', 'a7f08565-8fd9-4770-8b07-9c4195225211'),
                   (8, 'H', '74927808-8334-41b9-a2a1-8a58ed1926c1'),
                   (9, 'I', '85ad4aec-8320-4d7e-86f7-5a81104fd077');

        INSERT INTO l_label_label (id, link, entity0, entity1, entity0_credit, entity1_credit)
            VALUES
                -- cases where the relationship already exists on the target entity:
                -- same values are kept, different values are dropped
                (1, 1, 1, 4, '', ''),
                (2, 1, 2, 4, 'kept1', 'dropped1'),
                (3, 1, 3, 4, 'kept1', 'dropped2'),

                -- empty source values are ignored
                (4, 1, 1, 5, '', ''),
                (5, 1, 2, 5, 'kept2', ''),
                (6, 1, 3, 5, '', 'kept3'),

                -- non-empty target values aren't overwritten
                (7, 1, 1, 6, 'kept4', 'kept5'),
                (8, 1, 2, 6, 'dropped3', 'dropped4'),

                -- or cleared
                (9, 1, 1, 7, 'kept6', 'kept7'),
                (10, 1, 2, 7, '', ''),

                -- cases where the relationships only exist on source entities:
                -- same values are kept, different values are dropped
                (11, 1, 2, 8, 'kept8', 'dropped5'),
                (12, 1, 3, 8, 'kept8', 'dropped6'),

                -- empty source values are ignored
                (14, 1, 2, 9, 'kept9', ''),
                (15, 1, 3, 9, '', 'kept10');
        EOSQL

    $c->model('Relationship')->merge_entities('label', 1, [2, 3], rename_credits => 1);

    my $label = $c->model('Label')->get_by_id(1);
    $c->model('Relationship')->load($label);

    my @relationships = nsort_by { $_->id } $label->all_relationships;
    is($relationships[0]->entity0_credit, 'kept1');
    is($relationships[0]->entity1_credit, '');
    is($relationships[1]->entity0_credit, 'kept2');
    is($relationships[1]->entity1_credit, 'kept3');
    is($relationships[2]->entity0_credit, 'kept4');
    is($relationships[2]->entity1_credit, 'kept5');
    is($relationships[3]->entity0_credit, 'kept6');
    is($relationships[3]->entity1_credit, 'kept7');
    is($relationships[4]->entity0_credit, 'kept8');
    is($relationships[4]->entity1_credit, '');
    is($relationships[5]->entity0_credit, 'kept9');
    is($relationships[5]->entity1_credit, 'kept10');
};

test 'Entity credits plus dates merge harmoniously' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+relationship_merging');
    MusicBrainz::Server::Test->prepare_test_database($c, <<~'EOSQL');
        INSERT INTO label (id, name, gid)
            VALUES (4, 'D', '71a79efe-ab55-4a5a-a221-72062f5acb2f');

        INSERT INTO l_label_label (id, link, entity0, entity1, entity0_credit, entity1_credit)
            VALUES
                -- The relationship on the target entity has a begin date and no credits.
                -- The relationship on the source entity has credits and no dates.
                (1, 2, 1, 3, '', ''),
                (2, 1, 2, 3, 'credit0', 'credit1'),

                -- The relationship on the target entity credits and no dates.
                -- The relationship on the source entity has a begin date and no credits.
                (3, 1, 1, 4, 'credit2', 'credit3'),
                (4, 2, 2, 4, '', '');
        EOSQL

    $c->model('Relationship')->merge_entities('label', 1, [2], rename_credits => 1);

    my $label = $c->model('Label')->get_by_id(1);
    $c->model('Relationship')->load($label);

    my @relationships = nsort_by { $_->id } $label->all_relationships;
    is($relationships[0]->entity0_credit, 'credit0');
    is($relationships[0]->entity1_credit, 'credit1');
    is($relationships[0]->link->begin_date->format, '1995');
    is($relationships[1]->entity0_credit, 'credit2');
    is($relationships[1]->entity1_credit, 'credit3');
    is($relationships[1]->link->begin_date->format, '1995');
};

test 'Duplicate relationships that only exist among source entities are merged' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+relationship_merging');
    MusicBrainz::Server::Test->prepare_test_database($c, <<~'EOSQL');
        INSERT INTO l_artist_label (id, link, entity0, entity1)
            VALUES (1, 5, 2, 1), (2, 5, 3, 1);
        EOSQL

    $c->model('Relationship')->merge_entities('artist', 1, [2, 3]);

    my $artist = $c->model('Artist')->get_by_id(1);
    $c->model('Relationship')->load($artist);

    is(scalar($artist->all_relationships), 1, 'one relationship remains');
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
is( $rel->direction, $DIRECTION_FORWARD );

for my $rel ($artist1->all_relationships) {
    if ($rel->link_id == 2) {
        isnt( $rel->link, undef );
        ok( $rel->link->has_attribute('additional') );
        is( $rel->link->get_attribute('additional')->[0], 'additional' );
        ok( $rel->link->has_attribute('instrument') );
        is( $rel->link->get_attribute('instrument')->[0], 'plucked string instruments' );
        is( $rel->entity1->name, 'Track 2' );
        is( $rel->edits_pending, 0 );
        is( $rel->direction, $DIRECTION_FORWARD );
    }
    else {
        isnt( $rel->link, undef );
        ok( !$rel->link->has_attribute('additional') );
        ok( $rel->link->has_attribute('instrument') );
        is( $rel->link->get_attribute('instrument')->[0], 'guitar' );
        is( $rel->entity1->name, 'Track 1' );
        is( $rel->edits_pending, 0 );
        is( $rel->direction, $DIRECTION_FORWARD );
    }
}

my $recording1 = MusicBrainz::Server::Entity::Recording->new(id => 1);
$rel_data->load($recording1);
is( scalar($recording1->all_relationships), 2 );
is( $recording1->relationships->[0]->direction, $DIRECTION_BACKWARD );
is( $recording1->relationships->[1]->direction, $DIRECTION_BACKWARD );

my $sql = $test->c->sql;
$sql->begin;
$sql->do('INSERT INTO l_artist_recording (id, link, entity0, entity1) VALUES (4, 1, 2, 2)');
# Merge ARs for artist #2 to #1
$rel_data->merge_entities('artist', 1, [2]);
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
    link_type_id => 148,
    begin_date => { year => 2008, month => 2, day => 3 },
    end_date => { year => 2008, month => 2, day => 8 },
    attributes => [
        { type => { id => 1 } },
        { type => { id => 302 } },
        { type => { id => 229 } },
    ],
    entity0_id => 1,
    entity1_id => 1
});
$sql->commit;
is($rel->id, 4);

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
is($rel->id, 4);
is($rel->link->id, 5);
is_deeply($rel->link->begin_date, { year => 2008, month => 2, day => 3 });
is_deeply($rel->link->end_date, { year => 2008, month => 2, day => 8 });
is($rel->phrase, 'additional <a href="/instrument/63021302-86cd-4aee-80df-2270d54f4978">guitar</a> and ' .
                 '<a href="/instrument/b879ca9a-bf4b-41f8-b1a3-aa109f2e3bea">plucked string instruments</a>');

$sql->begin;
$rel_data->update('artist', 'recording', 4, {
    link_type_id => 148,
    begin_date => undef,
    end_date => undef,
    ended => 0,
    attributes => [{ type => { id => 302 } }],
    entity0_id => 1,
    entity1_id => 1
});
$sql->commit;

$artist1->clear_relationships;
$rel_data->load($artist1);
is(scalar($artist1->all_relationships), 1);

$rel = $artist1->relationships->[0];
is($rel->id, 4);
is($rel->link->id, 6);
is_deeply($rel->link->begin_date, { });
is_deeply($rel->link->end_date, { });
is($rel->phrase,
   '<a href="/instrument/b879ca9a-bf4b-41f8-b1a3-aa109f2e3bea">' .
       'plucked string instruments' .
   '</a>',
   'phrase'
);

$rel = $rel_data->get_by_id('artist', 'recording', 4);
is($rel->edits_pending, 0);

$sql->begin;
$rel_data->adjust_edit_pending('artist', 'recording', +1, 4);
$sql->commit;

$rel = $rel_data->get_by_id('artist', 'recording', 4);
is($rel->edits_pending, 1);

$sql->begin;
$rel_data->adjust_edit_pending('artist', 'recording', -1, 4);
$sql->commit;

$rel = $rel_data->get_by_id('artist', 'recording', 4);
is($rel->edits_pending, 0);

};

1;
