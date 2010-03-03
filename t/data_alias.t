#!/usr/bin/perl
use strict;
use Test::More;
use Test::Moose;
use DateTime;
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;
use Sql;

BEGIN {
    use_ok 'MusicBrainz::Server::Data::Artist';
    use_ok 'MusicBrainz::Server::Data::Label';
}

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+artistalias');

my $sql = Sql->new($c->dbh);
$sql->begin;

# Artist data should do the alias role
my $artist_data = MusicBrainz::Server::Data::Artist->new(c => $c);
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
is($alias_set->[0]->name, 'Alias 1');
is($alias_set->[0]->artist_id, 1);
is($alias_set->[0]->locale, undef);
is($alias_set->[1]->name, 'Alias 2');
is($alias_set->[1]->artist_id, 1);
is($alias_set->[1]->locale, 'en_GB');

# Attempt finding aliases for an artist with no aliases
$alias_set = $artist_data->alias->find_by_entity_id(2);
is(scalar @$alias_set, 0);

# Make sure we can check if an entity has a given alias
ok($artist_data->alias->has_alias(1, 'Alias 1'), 'artist 1 has Alias 1 alias');
ok(!$artist_data->alias->has_alias(1, 'Alias Foo'), 'artist 1 does not have Alias Foo alias');

# Test merging aliases together
$artist_data->alias->merge(1, 2);

$alias_set = $artist_data->alias->find_by_entity_id(1);
is(scalar @$alias_set, 2);
is($alias_set->[0]->name, 'Alias 1');
is($alias_set->[1]->name, 'Alias 2');

$alias_set = $artist_data->alias->find_by_entity_id(2);
is(scalar @$alias_set, 0);

# Test merging aliases with identical names
$artist_data->alias->merge(1, 3);

$alias_set = $artist_data->alias->find_by_entity_id(1);
is(scalar @$alias_set, 2);
is($alias_set->[0]->name, 'Alias 1');
is($alias_set->[1]->name, 'Alias 2');

$alias_set = $artist_data->alias->find_by_entity_id(3);
is(scalar @$alias_set, 0);

# Test deleting aliases
$artist_data->alias->delete_entities(1);
$alias_set = $artist_data->alias->find_by_entity_id(1);
is(scalar @$alias_set, 0);

# Test inserting new aliases
$artist_data->alias->insert({ artist_id => 1, name => 'New alias', locale => 'en_AU' });
$alias_set = $artist_data->alias->find_by_entity_id(1);
is(scalar @$alias_set, 1);
is($alias_set->[0]->name, 'New alias');
is($alias_set->[0]->locale, 'en_AU');

$sql->commit;

# Make sure other data types support aliases
my $label_data = MusicBrainz::Server::Data::Label->new(c => $c);
does_ok($label_data, 'MusicBrainz::Server::Data::Role::Alias');

done_testing;
