package t::MusicBrainz::Server::Data::Alias;
use Test::Routine;
use Test::Moose;
use Test::More;

use DateTime;
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;
use Sql;

BEGIN {
    use MusicBrainz::Server::Data::Artist;
    use MusicBrainz::Server::Data::Label;
    use MusicBrainz::Server::Data::Work;
}

with 't::Context';

test all => sub {

my $test = shift;

MusicBrainz::Server::Test->prepare_test_database($test->c, '+artistalias');

$test->c->sql->begin;

# Artist data should do the alias role
my $artist_data = MusicBrainz::Server::Data::Artist->new(c => $test->c);
does_ok($artist_data, 'MusicBrainz::Server::Data::Role::Alias');
does_ok($artist_data->alias, 'MusicBrainz::Server::Data::Role::Editable');

# Make sure we can load specific aliases
my $alias = $artist_data->alias->get_by_id(1);
ok(defined $alias, 'returns an object');
isa_ok($alias, 'MusicBrainz::Server::Entity::ArtistAlias', 'not an artist alias');
is($alias->name, 'Alias 1', 'alias name');
is($alias->artist_id, 1, 'artist id');
ok(!$alias->locale, 'has no locale');

# Loading the artist from an alias
$artist_data->load($alias);
ok(defined $alias->artist, 'didnt load artist');
isa_ok($alias->artist, 'MusicBrainz::Server::Entity::Artist', 'not an artist object');
is($alias->artist->id, $alias->artist_id, 'loaded artist id');

# Find all aliases for an artist
my $alias_set = $artist_data->alias->find_by_entity_id(1);
is(scalar @$alias_set, 2);
is($alias_set->[0]->name, 'Alias 2');
is($alias_set->[0]->artist_id, 1);
is($alias_set->[0]->locale, 'en_GB');
is($alias_set->[1]->name, 'Alias 1');
is($alias_set->[1]->artist_id, 1);
is($alias_set->[1]->locale, undef);

# Attempt finding aliases for an artist with no aliases
$alias_set = $artist_data->alias->find_by_entity_id(2);
is(scalar @$alias_set, 0);

# Make sure we can check if an entity has aliases for a given locale
ok($artist_data->alias->has_locale(1, 'en_GB'), 'artist 1 has en_GB locale');

# Test merging aliases together
$artist_data->alias->merge(1, 2);

$alias_set = $artist_data->alias->find_by_entity_id(1);
is(scalar @$alias_set, 3);
is($alias_set->[0]->name, 'Alias 2');
is($alias_set->[1]->name, 'Alias 1');
is($alias_set->[2]->name, 'Empty Artist',
   'has the old artist as an alias');

$alias_set = $artist_data->alias->find_by_entity_id(2);
is(scalar @$alias_set, 0);

# Test merging aliases with identical names
$artist_data->alias->merge(1, 3);

$alias_set = $artist_data->alias->find_by_entity_id(1);
is(scalar @$alias_set, 4);
is($alias_set->[0]->name, 'Alias 2');
is($alias_set->[0]->locale, 'en_GB');
is($alias_set->[1]->name, 'Alias 1');
is($alias_set->[2]->locale, undef);
is($alias_set->[3]->name, 'Empty Artist');

$alias_set = $artist_data->alias->find_by_entity_id(3);
is(scalar @$alias_set, 0);

# Test deleting aliases
$artist_data->alias->delete_entities(1);
$alias_set = $artist_data->alias->find_by_entity_id(1);
is(scalar @$alias_set, 0);

# Test inserting new aliases
$artist_data->alias->insert({
    artist_id => 1,
    name => 'New alias',
    sort_name => 'New sort name',
    locale => 'en_AU',
    primary_for_locale => 0
});

$alias_set = $artist_data->alias->find_by_entity_id(1);
is(scalar @$alias_set, 1);
is($alias_set->[0]->name, 'New alias');
is($alias_set->[0]->locale, 'en_AU');
is($alias_set->[0]->sort_name, 'New sort name');
is($alias_set->[0]->primary_for_locale, 0);

$test->c->sql->commit;

# Make sure other data types support aliases
my $label_data = MusicBrainz::Server::Data::Label->new(c => $test->c);
does_ok($label_data, 'MusicBrainz::Server::Data::Role::Alias');

my $work_data = MusicBrainz::Server::Data::Work->new(c => $test->c);
does_ok($work_data, 'MusicBrainz::Server::Data::Role::Alias');

};

test 'Merging should not add aliases identical to new name' => sub {
    my $test = shift;
    my $c = $test->c;

    $c->sql->do(<<EOSQL);
INSERT INTO artist_name (id, name) VALUES (1, 'Name'), (2, 'Old name');
INSERT INTO artist (id, gid, name, sort_name, comment)
    VALUES (1, '945c079d-374e-4436-9448-da92dedef3cf', 1, 1, 'Artist 1'),
           (2, '73371ea0-7217-11de-8a39-0800200c9a66', 1, 1, 'Artist 2'),
           (3, '686cdcc0-7218-11de-8a39-0800200c9a66', 2, 2, '');
EOSQL

    $c->model('Artist')->alias->merge(1, 2, 3);

    my $aliases = $c->model('Artist')->alias->find_by_entity_id(1);
    is(@$aliases, 1);
    is($aliases->[0]->name, 'Old name', 'has old name alias',);
    ok(!(grep { $_->name eq 'Name' } @$aliases), 'does not have new name alias');
};

test 'Merging should not add aliases that already exist' => sub {
    my $test = shift;
    my $c = $test->c;

    $c->sql->do(<<EOSQL);
INSERT INTO artist_name (id, name) VALUES (1, 'Name'), (2, 'Old name'), (3, 'Foo name');
INSERT INTO artist (id, gid, name, sort_name)
    VALUES (1, '945c079d-374e-4436-9448-da92dedef3cf', 1, 1),
           (2, '73371ea0-7217-11de-8a39-0800200c9a66', 2, 2);
INSERT INTO artist_alias (artist, name, sort_name) VALUES (1, 2, 2);
EOSQL

    $c->model('Artist')->alias->merge(1, 2);

    my $aliases = $c->model('Artist')->alias->find_by_entity_id(1);
    is(@$aliases, 1);
    is($aliases->[0]->name, 'Old name', 'has old name alias',);
    ok(!(grep { $_->name eq 'Name' } @$aliases), 'does not have new name alias');
};

test 'Exists only checks a single entity' => sub {
    my $test = shift;
    my $c = $test->c;

    $c->sql->do(<<EOSQL);
INSERT INTO artist_name (id, name) VALUES (1, 'Name'), (2, 'Old name'), (3, 'Foo name');
INSERT INTO artist (id, gid, name, sort_name, comment)
    VALUES (1, '945c079d-374e-4436-9448-da92dedef3cf', 1, 1, ''),
           (2, '73371ea0-7217-11de-8a39-0800200c9a66', 2, 2, 'Artist 2'),
           (3, '1153890e-afdf-404c-85d1-aea98dfe576d', 2, 2, 'Artist 3');
INSERT INTO artist_alias (artist, name, sort_name) VALUES (1, 2, 2), (2, 3, 3);
EOSQL

    my $check_alias = sub {
        $c->model('Artist')->alias->exists({
            name => shift, locale => undef, type_id => undef, not_id => undef, entity => shift
        })
    };

    ok($check_alias->('Old name', 1));
    ok(!$check_alias->('Foo name', 1));

    ok(!$check_alias->('Old name', 2));
    ok($check_alias->('Foo name', 2));

    ok(!$check_alias->('Old name', 3));
    ok(!$check_alias->('Foo name', 3));
};

1;
