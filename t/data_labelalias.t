#!/usr/bin/perl
use strict;
use Test::More tests => 10;

BEGIN { use_ok 'MusicBrainz::Server::Data::Label' }

use DateTime;
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Context->new();
MusicBrainz::Server::Test->prepare_test_database($c);

my $label_data = MusicBrainz::Server::Data::Label->new(c => $c);

my $alias = $label_data->alias->get_by_id(1);
ok(defined $alias, 'returns an object');
isa_ok($alias, 'MusicBrainz::Server::Entity::LabelAlias', 'not a label alias');
is($alias->name, 'Test Label Alias', 'alias name');
is($alias->label_id, 2);

$label_data->load($alias);

ok(defined $alias->label, 'didnt load label');
isa_ok($alias->label, 'MusicBrainz::Server::Entity::Label', 'not a label object');
is($alias->label->id, $alias->label_id, 'loaded label id');

my $alias_set = $label_data->alias->find_by_entity_id(2);
is(scalar @$alias_set, 1);
is($alias_set->[0]->name, 'Test Label Alias');
