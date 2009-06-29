#!/usr/bin/perl
use strict;
use Test::More tests => 17;

BEGIN { use_ok 'MusicBrainz::Server::Data::Artist' }

use DateTime;
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;
use Sql;

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c);

my $sql = Sql->new($c->dbh);
$sql->Begin;

my $artist_data = MusicBrainz::Server::Data::Artist->new(c => $c);

my $alias = $artist_data->alias->get_by_id(1);
ok(defined $alias, 'returns an object');
isa_ok($alias, 'MusicBrainz::Server::Entity::ArtistAlias', 'not an artist alias');
is($alias->name, 'Test Alias', 'alias name');
is($alias->artist_id, 4, 'artist id');

$artist_data->load($alias);

ok(defined $alias->artist, 'didnt load artist');
isa_ok($alias->artist, 'MusicBrainz::Server::Entity::Artist', 'not an artist object');
is($alias->artist->id, $alias->artist_id, 'loaded artist id');

my $alias_set = $artist_data->alias->find_by_entity_id(4);
is(scalar @$alias_set, 1);
is($alias_set->[0]->name, 'Test Alias');

$alias_set = $artist_data->alias->find_by_entity_id(3);
is(scalar @$alias_set, 0);

$artist_data->alias->merge(4, 3);

$alias_set = $artist_data->alias->find_by_entity_id(3);
is(scalar @$alias_set, 1);
is($alias_set->[0]->name, 'Test Alias');

$alias_set = $artist_data->alias->find_by_entity_id(5);
is(scalar @$alias_set, 1);

# Test merging aliases with identical names
$artist_data->alias->merge(5, 3);
is(scalar @$alias_set, 1, 'should only have 1 alias after merge');
is($alias_set->[0]->name, 'Test Alias');

$artist_data->alias->delete(4);
$alias_set = $artist_data->alias->find_by_entity_id(4);
is(scalar @$alias_set, 0);

$sql->Commit;
