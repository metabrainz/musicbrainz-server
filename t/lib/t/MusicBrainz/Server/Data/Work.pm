package t::MusicBrainz::Server::Data::Work;
use Test::Routine;
use Test::Fatal;
use Test::More;

use MusicBrainz::Server::Data::Work;
use MusicBrainz::Server::Data::WorkType;
use MusicBrainz::Server::Data::Search;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;

with 't::Context';

test 'Test find_by_iswc' => sub {
    my $test = shift;
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+work');

    {
        my @works = $test->c->model('Work')->find_by_iswc('T-000.000.001-0');
        is(@works, 1, 'Found 1 work');
        is($works[0]->id, 1, 'Found work with ID 1');
    }

    {
        my @works = $test->c->model('Work')->find_by_iswc('T-000.000.002-0');
        is(@works, 1, 'Found 1 work');
        is($works[0]->id, 2, 'Found work with ID 1');
    }

    {
        my @works = $test->c->model('Work')->find_by_iswc('T-123.321.002-0');
        is(@works, 0, 'Found 0 works with unknown ISWC');
    }
};

test all => sub {

my $test = shift;
MusicBrainz::Server::Test->prepare_test_database($test->c, '+work');

my $work_data = MusicBrainz::Server::Data::Work->new(c => $test->c);

my $work = $work_data->get_by_id(1);
is ( $work->id, 1 );
is ( $work->gid, "745c079d-374e-4436-9448-da92dedef3ce" );
is ( $work->name, "Dancing Queen" );
is ( $work->type_id, 1 );
is ( $work->edits_pending, 0 );

$work = $work_data->get_by_gid("745c079d-374e-4436-9448-da92dedef3ce");
is ( $work->id, 1 );
is ( $work->gid, "745c079d-374e-4436-9448-da92dedef3ce" );
is ( $work->name, "Dancing Queen" );
is ( $work->type_id, 1 );
is ( $work->edits_pending, 0 );

is ( $work->type, undef );
MusicBrainz::Server::Data::WorkType->new(c => $test->c)->load($work);
is ( $work->type->name, "Composition" );

my $annotation = $work_data->annotation->get_latest(1);
is ( $annotation->text, "Annotation" );


$work = $work_data->get_by_gid('28e73402-5666-4d74-80ab-c3734dc699ea');
is ( $work->id, 1 );

$work = $work_data->get_by_gid('ffffffff-ffff-ffff-ffff-ffffffffffff');
is ( $work, undef );


my $search = MusicBrainz::Server::Data::Search->new(c => $test->c);
my ($results, $hits) = $search->search("work", "queen", 10);
is( $hits, 1 );
is( scalar(@$results), 1 );
is( $results->[0]->position, 1 );
is( $results->[0]->entity->name, "Dancing Queen" );


$test->c->sql->begin;

$work = $work_data->insert({
        name => 'Traits',
        type_id => 1,
        comment => 'Drum & bass track',
    });

isa_ok($work, 'MusicBrainz::Server::Entity::Work');
ok($work->id > 1);

$work = $work_data->get_by_id($work->id);
is($work->name, 'Traits');
is($work->comment, 'Drum & bass track');
is($work->type_id, 1);
ok(defined $work->gid);

$work_data->update($work->id, {
        name => 'Traits (remix)',
    });

$work = $work_data->get_by_id($work->id);
is($work->name, 'Traits (remix)');

$work_data->delete($work->id);

$work = $work_data->get_by_id($work->id);
ok(!defined $work);

$test->c->sql->commit;

# Both #1 and #2 are in the DB
$work = $work_data->get_by_id(1);
ok(defined $work);
$work = $work_data->get_by_id(2);
ok(defined $work);

# Merge #2 into #1
$test->c->sql->begin;
$work_data->merge(1, 2);
$test->c->sql->commit;

# Only #1 is now in the DB
$work = $work_data->get_by_id(1);
ok(defined $work);
$work = $work_data->get_by_id(2);
ok(!defined $work);

};

test 'Merge with funky relationships' => sub {
    my $test = shift;

    MusicBrainz::Server::Test->prepare_test_database($test->c, <<'EOSQL');
INSERT INTO artist (id, gid, name, sort_name)
    VALUES (1, '5f9913b0-7219-11de-8a39-0800200c9a66', 'Artist', 'Artist');

INSERT INTO work (id, gid, name)
    VALUES (1, '145c079d-374e-4436-9448-da92dedef3cf', 'Target'),
           (2, '245c079d-374e-4436-9448-da92dedef3cf', 'Merge 1'),
           (3, '345c079d-374e-4436-9448-da92dedef3cf', 'Merge 2');

INSERT INTO link_type
    (id, gid, entity_type0, entity_type1, name, link_phrase, reverse_link_phrase,
     long_link_phrase)
    VALUES (1, '7610b0e9-40c1-48b3-b06c-2c1d30d9dc3e', 'artist', 'work', 'instrument',
            'performed',
            'performed by',
            'performer');
INSERT INTO link (id, link_type, attribute_count) VALUES (1, 1, 0);
INSERT INTO l_artist_work (id, entity0, link, entity1)
    VALUES (1, 1, 1, 2),
           (2, 1, 1, 3);
EOSQL

    $test->c->model('Work')->merge(1, 2, 3);

    my $final_work = $test->c->model('Work')->get_by_id(1);
    $test->c->model('Relationship')->load($final_work);
    is($final_work->all_relationships => 1,
       'Merged work has a single relationship');
    is($final_work->relationships->[0]->link_id => 1,
       'Relationship is of link type 1');
    is($final_work->relationships->[0]->entity0_id => 1,
       'Points to artist 1');
    is($final_work->relationships->[0]->entity1_id => 1,
       'Originates from work 1');
};

test 'Loading work attributes for works with no attributes' => sub {
    my $test = shift;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+work');

    my $work = $test->c->model('Work')->get_by_id(1);
    is exception { $test->c->model('Work')->load_attributes($work) }, undef;

    is($work->all_attributes, 0, 'work has no attributes')
};

test 'Loading work attributes for works with free text attributes' => sub {
    my $test = shift;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+work');
    $test->c->sql->do(<<EOSQL);
INSERT INTO work_attribute_type (id, name, free_text)
VALUES (1, 'Attribute', true);
EOSQL

    $test->c->model('Work')->set_attributes(
        1,
        {
            attribute_type_id => 1,
            attribute_text => 'Value'
        }
    );

    my $work = $test->c->model('Work')->get_by_id(1);
    is exception { $test->c->model('Work')->load_attributes($work) }, undef;

    is($work->all_attributes, 1, 'work has 1 attribute');
    is($work->attributes->[0]->type->name, 'Attribute',
        'has correct attribute name');
    is($work->attributes->[0]->value, 'Value', 'has correct attribute value');
};

test 'Loading work attributes for works with finite values' => sub {
    my $test = shift;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+work');
    $test->c->sql->do(<<EOSQL);
INSERT INTO work_attribute_type (id, name, free_text)
VALUES (1, 'Attribute', false);
INSERT INTO work_attribute_type_allowed_value (id, work_attribute_type, value)
VALUES (1, 1, 'Value'), (2, 1, 'Value 2');
EOSQL

    $test->c->model('Work')->set_attributes(
        1,
        {
            attribute_type_id => 1,
            attribute_value_id => 1
        }
    );

    my $work = $test->c->model('Work')->get_by_id(1);
    is exception { $test->c->model('Work')->load_attributes($work) }, undef;

    is($work->all_attributes, 1, 'work has 1 attribute');
    is($work->attributes->[0]->type->name, 'Attribute',
        'has correct attribute name');
    is($work->attributes->[0]->value, 'Value', 'has correct attribute value');
};

test 'Multiple attributes for a work' => sub {
    my $test = shift;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+work');
    $test->c->sql->do(<<EOSQL);
INSERT INTO work_attribute_type (id, name, free_text)
VALUES (1, 'Attribute', false), (2, 'Type two', true);
INSERT INTO work_attribute_type_allowed_value (id, work_attribute_type, value)
VALUES (1, 1, 'Value'), (2, 1, 'Value 2');
EOSQL

    $test->c->model('Work')->set_attributes(
        1,
        {
            attribute_type_id => 1,
            attribute_value_id => 2
        },
        {
            attribute_type_id => 2,
            attribute_text => 'Anything you want'
        }
    );

    my $work = $test->c->model('Work')->get_by_id(1);
    is exception { $test->c->model('Work')->load_attributes($work) }, undef;

    is($work->all_attributes, 2, 'work has 2 attributes');
};

test 'Determining allowed values for work attributes' => sub {
    my $test = shift;

    $test->c->sql->do(<<EOSQL);
INSERT INTO work_attribute_type (id, name, free_text)
VALUES
  (1, 'Attribute', false),
  (2, 'Free attribute', true),
  (3, 'Attribute 3', false);
INSERT INTO work_attribute_type_allowed_value (id, work_attribute_type, value)
VALUES (1, 1, 'Value'), (2, 1, 'Value 2'), (3, 3, 'Value 3');
EOSQL

    my %allowed_values = $test->c->model('Work')->allowed_attribute_values(1..3);

    ok($allowed_values{1}->{allows_value}->(1), 'Attribute #1 allows value #1');
    ok($allowed_values{1}->{allows_value}->(2), 'Attribute #1 allows value #2');
    ok(!$allowed_values{1}->{allows_value}->(3), 'Attribute #1 disallows value #3');

    ok($allowed_values{2}->{allows_value}->('Anything you want'),
        'Attribute #2 allows arbitrary text');

    ok($allowed_values{3}->{allows_value}->(3), 'Attribute #3 allows value #3');
};

1;
