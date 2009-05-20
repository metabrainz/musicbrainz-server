#!/usr/bin/perl
use strict;
use Test::More tests => 8;

BEGIN { use_ok 'MusicBrainz::Server::Data::ArtistAlias' }

use DateTime;
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Data::Artist;
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Context->new();
MusicBrainz::Server::Test->prepare_test_database($c);

my $alias_data = MusicBrainz::Server::Data::ArtistAlias->new(c => $c);

my $alias = $alias_data->get_by_id(1);
ok(defined $alias, 'returns an object');
isa_ok($alias, 'MusicBrainz::Server::Entity::ArtistAlias', 'not an artist alias');
is($alias->name, 'Test Alias', 'alias name');
is($alias->artist_id, 4, 'artist id');

my $artist_data = MusicBrainz::Server::Data::Artist->new(c => $c);
$artist_data->load($alias);

ok(defined $alias->artist, 'didnt load artist');
isa_ok($alias->artist, 'MusicBrainz::Server::Entity::Artist', 'not an artist object');
is($alias->artist->id, $alias->artist_id, 'loaded artist id');