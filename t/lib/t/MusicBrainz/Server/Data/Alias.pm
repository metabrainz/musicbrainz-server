package t::MusicBrainz::Server::Data::Alias;
use Test::Routine;
use Test::Moose;
use Test::More;
use Test::Memory::Cycle;

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
memory_cycle_ok($artist_data->alias, 'alias dao shouldnt leak after get_by_id');

# Loading the artist from an alias
$artist_data->load($alias);
ok(defined $alias->artist, 'didnt load artist');
isa_ok($alias->artist, 'MusicBrainz::Server::Entity::Artist', 'not an artist object');
is($alias->artist->id, $alias->artist_id, 'loaded artist id');
memory_cycle_ok($alias, 'alias shouldnt leak after loading');

# Find all aliases for an artist
my $alias_set = $artist_data->alias->find_by_entity_id(1);
is(scalar @$alias_set, 2);
is($alias_set->[0]->name, 'Alias 1');
is($alias_set->[0]->artist_id, 1);
is($alias_set->[0]->locale, undef);
is($alias_set->[1]->name, 'Alias 2');
is($alias_set->[1]->artist_id, 1);
is($alias_set->[1]->locale, 'en_GB');
memory_cycle_ok($alias, 'alias find_by_entity_id shouldnt leak');
memory_cycle_ok($alias_set, 'results of find_by_entity_id shouldnt leak');

# Attempt finding aliases for an artist with no aliases
$alias_set = $artist_data->alias->find_by_entity_id(2);
is(scalar @$alias_set, 0);

# Make sure we can check if an entity has aliases for a given locale
ok($artist_data->alias->has_locale(1, 'en_GB'), 'artist 1 has en_GB locale');
memory_cycle_ok($artist_data->alias, 'has_locale doesnt leak');

# Test merging aliases together
$artist_data->alias->merge(1, 2);
memory_cycle_ok($artist_data->alias, 'merge doesnt leak');

$alias_set = $artist_data->alias->find_by_entity_id(1);
is(scalar @$alias_set, 3);
is($alias_set->[0]->name, 'Alias 1');
is($alias_set->[1]->name, 'Alias 2');
is($alias_set->[2]->name, 'Empty Artist',
   'has the old artist as an alias');

$alias_set = $artist_data->alias->find_by_entity_id(2);
is(scalar @$alias_set, 0);

# Test merging aliases with identical names
$artist_data->alias->merge(1, 3);

$alias_set = $artist_data->alias->find_by_entity_id(1);
is(scalar @$alias_set, 4);
is($alias_set->[0]->name, 'Alias 1');
is($alias_set->[1]->name, 'Alias 2');
is($alias_set->[2]->name, 'Empty Artist');
is($alias_set->[3]->name, 'Name');


$alias_set = $artist_data->alias->find_by_entity_id(3);
is(scalar @$alias_set, 0);

# Test deleting aliases
$artist_data->alias->delete_entities(1);
$alias_set = $artist_data->alias->find_by_entity_id(1);
is(scalar @$alias_set, 0);

# Test inserting new aliases
$artist_data->alias->insert({ artist_id => 1, name => 'New alias', locale => 'en_AU' });
memory_cycle_ok($artist_data->alias, 'insert doesnt leak');

$alias_set = $artist_data->alias->find_by_entity_id(1);
is(scalar @$alias_set, 1);
is($alias_set->[0]->name, 'New alias');
is($alias_set->[0]->locale, 'en_AU');

$test->c->sql->commit;

# Make sure other data types support aliases
my $label_data = MusicBrainz::Server::Data::Label->new(c => $test->c);
does_ok($label_data, 'MusicBrainz::Server::Data::Role::Alias');

my $work_data = MusicBrainz::Server::Data::Work->new(c => $test->c);
does_ok($work_data, 'MusicBrainz::Server::Data::Role::Alias');

};

1;
