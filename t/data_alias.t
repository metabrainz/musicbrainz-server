#!/usr/bin/perl
use strict;
use Test::More tests => 26;
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
$sql->Begin;

# Artist data should do the alias role
my $artist_data = MusicBrainz::Server::Data::Artist->new(c => $c);
does_ok($artist_data, 'MusicBrainz::Server::Data::AliasRole');

# Make sure we can load specific aliases
my $alias = $artist_data->alias->get_by_id(1);
ok(defined $alias, 'returns an object');
isa_ok($alias, 'MusicBrainz::Server::Entity::ArtistAlias', 'not an artist alias');
is($alias->name, 'Alias 1', 'alias name');
is($alias->artist_id, 1, 'artist id');

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
is($alias_set->[1]->name, 'Alias 2');
is($alias_set->[1]->artist_id, 1);

# Attempt finding aliases for an artist with no aliases
$alias_set = $artist_data->alias->find_by_entity_id(2);
is(scalar @$alias_set, 0);

# Test merging aliases together
$artist_data->alias->merge(2, 1);

$alias_set = $artist_data->alias->find_by_entity_id(1);
is(scalar @$alias_set, 2);
is($alias_set->[0]->name, 'Alias 1');
is($alias_set->[1]->name, 'Alias 2');

$alias_set = $artist_data->alias->find_by_entity_id(2);
is(scalar @$alias_set, 0);

# Test merging aliases with identical names
$artist_data->alias->merge(3, 1);

$alias_set = $artist_data->alias->find_by_entity_id(1);
is(scalar @$alias_set, 2);
is($alias_set->[0]->name, 'Alias 1');
is($alias_set->[1]->name, 'Alias 2');

$alias_set = $artist_data->alias->find_by_entity_id(3);
is(scalar @$alias_set, 0);

# Test deleting aliases
$artist_data->alias->delete(1);
$alias_set = $artist_data->alias->find_by_entity_id(1);
is(scalar @$alias_set, 0);

$sql->Commit;

# Make sure other data types support aliases
my $label_data = MusicBrainz::Server::Data::Label->new(c => $c);
does_ok($label_data, 'MusicBrainz::Server::Data::AliasRole');
