#!/usr/bin/perl
use strict;
use Test::More tests => 8;

BEGIN { use_ok 'MusicBrainz::Server::Data::LabelAlias' }

use DateTime;
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Data::Label;
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Context->new();
MusicBrainz::Server::Test->prepare_test_database($c);

my $alias_data = MusicBrainz::Server::Data::LabelAlias->new(c => $c);

my $alias = $alias_data->get_by_id(1);
ok(defined $alias, 'returns an object');
isa_ok($alias, 'MusicBrainz::Server::Entity::LabelAlias', 'not a label alias');
is($alias->name, 'Test Label Alias', 'alias name');
is($alias->label_id, 1);

my $label_data = MusicBrainz::Server::Data::Label->new(c => $c);
$label_data->load($alias);

ok(defined $alias->label, 'didnt load label');
isa_ok($alias->label, 'MusicBrainz::Server::Entity::Label', 'not a label object');
is($alias->label->id, $alias->label_id, 'loaded label id');